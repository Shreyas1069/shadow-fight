extends Node2D
class_name SpecialEffect

## Procedural placeholder VFX for the two special attacks.
## Gold = Papa From Heaven, purple = Mumma From Grave.
## These are deliberately simple shapes, not final artwork. An artist can
## replace this scene with animated sprites later without touching gameplay.

@export var effect_type: String = "gold"

var _time := 0.0
var _duration := 1.2
var _playing := false


func play(duration: float) -> void:
	_duration = maxf(duration, 0.1)
	_time = 0.0
	_playing = true
	visible = true


func _process(delta: float) -> void:
	if not _playing:
		return
	_time += delta
	if _time >= _duration:
		_playing = false
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := clampf(_time / _duration, 0.0, 1.0)
	var fade := 1.0 - smoothstep(0.75, 1.0, t)
	if effect_type == "gold":
		_draw_gold(t, fade)
	else:
		_draw_purple(t, fade)


# ---------------------------------------------------------------------------
# SP1 - Papa From Heaven (gold / divine)
# ---------------------------------------------------------------------------

func _draw_gold(t: float, fade: float) -> void:
	# 1. Ground prayer circle.
	var ring := 18.0 + t * 46.0
	_draw_ring(Vector2(0, 0), ring, Color(1.0, 0.80, 0.25, 0.85 * fade), 3.0)
	_draw_ring(Vector2(0, 0), ring * 0.6, Color(1.0, 0.95, 0.70, 0.7 * fade), 2.0)

	# 2. Pillars of light descending from above.
	if t > 0.08:
		var strength := clampf((t - 0.08) * 3.0, 0.0, 1.0) * fade
		for i in 5:
			var x := float(i - 2) * 22.0
			var a := 0.12 * strength
			draw_rect(Rect2(x - 5, -300, 10, 300), Color(1.0, 0.85, 0.35, a))

	# 3. Golden figure descending.
	if t > 0.18 and t < 0.78:
		var fall := clampf((t - 0.18) / 0.38, 0.0, 1.0)
		var y := lerpf(-240.0, -72.0, fall)
		_draw_angel(Vector2(0, y), fade)

	# 4. Impact burst.
	if t > 0.52:
		var burst := clampf((t - 0.52) / 0.30, 0.0, 1.0)
		var radius := 12.0 + burst * 120.0
		_draw_ring(Vector2(0, -30), radius, Color(1.0, 0.90, 0.45, 0.9 * (1.0 - burst) * fade), 5.0)
		for i in 12:
			var a := float(i) / 12.0 * TAU
			var inner := radius * 0.7
			var outer := radius * 1.25
			draw_line(
				Vector2(cos(a) * inner, -30 + sin(a) * inner),
				Vector2(cos(a) * outer, -30 + sin(a) * outer),
				Color(1.0, 0.95, 0.60, 0.8 * (1.0 - burst) * fade), 3.0
			)


func _draw_angel(pos: Vector2, alpha: float) -> void:
	var gold := Color(1.0, 0.82, 0.30, alpha)
	var bright := Color(1.0, 0.96, 0.72, alpha)
	# Wings.
	draw_colored_polygon([
		pos + Vector2(-12, -28), pos + Vector2(-58, -52), pos + Vector2(-40, -8), pos + Vector2(-10, 0),
	], bright)
	draw_colored_polygon([
		pos + Vector2(12, -28), pos + Vector2(58, -52), pos + Vector2(40, -8), pos + Vector2(10, 0),
	], bright)
	# Robe.
	draw_colored_polygon([
		pos + Vector2(-16, -18), pos + Vector2(16, -18),
		pos + Vector2(26, 28), pos + Vector2(-26, 28),
	], gold)
	# Head.
	draw_circle(pos + Vector2(0, -34), 12, gold)
	# Halo.
	_draw_ring(pos + Vector2(0, -52), 15, bright, 3.0)


# ---------------------------------------------------------------------------
# SP2 - Mumma From Grave (purple / supernatural)
# ---------------------------------------------------------------------------

func _draw_purple(t: float, fade: float) -> void:
	# 1. Grave marker on the ground.
	if t < 0.5:
		var glow := Color(0.75, 0.18, 0.95, 0.8 * fade)
		_draw_ring(Vector2(0, 0), 24.0 + t * 30.0, glow, 3.0)
		draw_rect(Rect2(-14, -46, 28, 46), Color(0.20, 0.10, 0.26, fade))
		draw_circle(Vector2(0, -46), 14, Color(0.20, 0.10, 0.26, fade))
		draw_rect(Rect2(-3, -38, 6, 22), Color(0.85, 0.25, 0.95, fade))
		draw_rect(Rect2(-9, -32, 18, 6), Color(0.85, 0.25, 0.95, fade))

	# 2. Grave erupts - ground shards.
	if t > 0.12 and t < 0.62:
		var e := clampf((t - 0.12) / 0.30, 0.0, 1.0)
		for i in 7:
			var x := float(i - 3) * 18.0
			var h := 40.0 + e * 70.0 * absf(sin(float(i) * 1.7))
			draw_colored_polygon([
				Vector2(x - 7, 0), Vector2(x + 7, 0), Vector2(x + 2, -h),
			], Color(0.35, 0.10, 0.42, 0.9 * (1.0 - e * 0.4) * fade))

	# 3. Dark figure emerging and standing.
	if t > 0.25:
		var rise := clampf((t - 0.25) / 0.42, 0.0, 1.0)
		var y := lerpf(30.0, -60.0, rise)
		_draw_mumma(Vector2(0, y), fade)

	# 4. Devil punishment impact.
	if t > 0.58:
		var burst := clampf((t - 0.58) / 0.30, 0.0, 1.0)
		var radius := 14.0 + burst * 130.0
		_draw_ring(Vector2(0, -40), radius, Color(0.95, 0.20, 0.35, 0.9 * (1.0 - burst) * fade), 5.0)
		for i in 10:
			var a := float(i) / 10.0 * TAU + t
			draw_line(
				Vector2(cos(a) * radius * 0.6, -40 + sin(a) * radius * 0.6),
				Vector2(cos(a) * radius * 1.2, -40 + sin(a) * radius * 1.2),
				Color(0.95, 0.25, 0.55, 0.85 * (1.0 - burst) * fade), 3.0
			)


func _draw_mumma(pos: Vector2, alpha: float) -> void:
	var dark := Color(0.16, 0.07, 0.20, alpha)
	var red := Color(0.95, 0.20, 0.30, alpha)
	# Flowing hair / cloak.
	draw_colored_polygon([
		pos + Vector2(-18, -44), pos + Vector2(-38, 10), pos + Vector2(-20, 40),
		pos + Vector2(20, 40), pos + Vector2(38, 10), pos + Vector2(18, -44),
	], dark)
	# Dress.
	draw_colored_polygon([
		pos + Vector2(-14, -16), pos + Vector2(14, -16),
		pos + Vector2(26, 42), pos + Vector2(-26, 42),
	], Color(0.30, 0.08, 0.18, alpha))
	# Head.
	draw_circle(pos + Vector2(0, -48), 13, Color(0.42, 0.22, 0.24, alpha))
	# Glowing eyes.
	draw_circle(pos + Vector2(-5, -49), 2.5, red)
	draw_circle(pos + Vector2(5, -49), 2.5, red)
	# Reaching arm.
	draw_line(pos + Vector2(8, -16), pos + Vector2(48, -34), Color(0.42, 0.22, 0.24, alpha), 7)


func _draw_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	draw_arc(center, radius, 0.0, TAU, 40, color, width)
