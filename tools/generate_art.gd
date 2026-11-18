extends SceneTree

## One-off art generator. Creates detailed pixel-art sprite sheets as PNG files.
## Run with: Godot --headless --path <project> --script res://tools/generate_art.gd
##
## These are ORIGINAL procedurally drawn placeholders inspired by the Khushal
## concept sheet. They are NOT final hand-crafted artwork. They give the game
## properly sized, animated, fully visible characters now, and an artist can
## replace the PNG files later without changing any gameplay code.

const FW := 128
const FH := 128

const ANIM_FRAMES: Dictionary = {
	"idle": 4, "walk": 6, "run": 6, "jump": 4, "crouch": 2,
	"attack_1": 5, "attack_2": 5, "block": 2, "hit": 3,
	"knockback": 3, "ko": 3, "sp1_cast": 6, "sp2_cast": 6,
}

const EXPRESSIONS: Array = ["normal", "childish", "surprised", "angry", "sad", "smirk"]

const KHUSHAL: Dictionary = {
	"skin": Color(0.92, 0.63, 0.42), "skin_dark": Color(0.72, 0.44, 0.28),
	"hair": Color(0.15, 0.10, 0.08), "hair_hi": Color(0.32, 0.20, 0.14),
	"shirt": Color(0.94, 0.94, 0.89), "shirt_dark": Color(0.73, 0.75, 0.74),
	"pants": Color(0.17, 0.18, 0.23), "pants_hi": Color(0.28, 0.30, 0.36),
	"shoe": Color(0.97, 0.97, 0.95), "shoe_dark": Color(0.70, 0.71, 0.73),
	"bag": Color(0.12, 0.34, 0.62), "bag_hi": Color(0.22, 0.50, 0.76),
	"plaster": Color(0.97, 0.87, 0.70), "ink": Color(0.12, 0.09, 0.08),
	"mouth": Color(0.50, 0.20, 0.18), "accent": Color(1.0, 0.80, 0.25),
}

const RIVAL: Dictionary = {
	"skin": Color(0.80, 0.58, 0.43), "skin_dark": Color(0.61, 0.40, 0.28),
	"hair": Color(0.09, 0.09, 0.12), "hair_hi": Color(0.24, 0.24, 0.30),
	"shirt": Color(0.52, 0.13, 0.17), "shirt_dark": Color(0.35, 0.08, 0.12),
	"pants": Color(0.20, 0.20, 0.24), "pants_hi": Color(0.31, 0.31, 0.36),
	"shoe": Color(0.16, 0.16, 0.19), "shoe_dark": Color(0.10, 0.10, 0.12),
	"bag": Color(0.28, 0.10, 0.13), "bag_hi": Color(0.42, 0.16, 0.19),
	"plaster": Color(0.90, 0.83, 0.70), "ink": Color(0.08, 0.06, 0.07),
	"mouth": Color(0.40, 0.12, 0.12), "accent": Color(0.75, 0.25, 0.90),
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Generating original placeholder sprite sheets ===")
	_generate_character("khushal", KHUSHAL)
	_generate_character("rival", RIVAL)
	print("=== Done ===")
	quit()


func _generate_character(folder: String, pal: Dictionary) -> void:
	var base := "res://assets/characters/" + folder
	_dir(base)
	for anim in ANIM_FRAMES.keys():
		var count: int = ANIM_FRAMES[anim]
		var sheet := Image.create(FW * count, FH, false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0, 0, 0, 0))
		for f in count:
			var frame := Image.create(FW, FH, false, Image.FORMAT_RGBA8)
			frame.fill(Color(0, 0, 0, 0))
			_draw_frame(frame, str(anim), f, count, pal)
			sheet.blit_rect(frame, Rect2i(0, 0, FW, FH), Vector2i(f * FW, 0))
		var path := base + "/" + str(anim) + ".png"
		var err := sheet.save_png(ProjectSettings.globalize_path(path))
		if err != OK:
			push_error("Failed to save " + path + " error " + str(err))
		else:
			print("  saved ", path, " (", count, " frames)")

	# Face overlay: eyes and mouths only, aligned to the head at (64, 38).
	var face_sheet := Image.create(FW * EXPRESSIONS.size(), FH, false, Image.FORMAT_RGBA8)
	face_sheet.fill(Color(0, 0, 0, 0))
	for i in EXPRESSIONS.size():
		var face := Image.create(FW, FH, false, Image.FORMAT_RGBA8)
		face.fill(Color(0, 0, 0, 0))
		_draw_face(face, str(EXPRESSIONS[i]), pal)
		face_sheet.blit_rect(face, Rect2i(0, 0, FW, FH), Vector2i(i * FW, 0))
	var face_path := base + "/face.png"
	var ferr := face_sheet.save_png(ProjectSettings.globalize_path(face_path))
	if ferr != OK:
		push_error("Failed to save " + face_path)
	else:
		print("  saved ", face_path, " (", EXPRESSIONS.size(), " expressions)")


func _dir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


# ---------------------------------------------------------------------------
# Drawing primitives (no external libraries)
# ---------------------------------------------------------------------------

func _put(img: Image, x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	img.set_pixel(x, y, c)


func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			_put(img, xx, yy, c)


func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
			var dx := (float(xx) - cx) / rx
			var dy := (float(yy) - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				_put(img, xx, yy, c)


func _limb(img: Image, a: Vector2, b: Vector2, thickness: float, c: Color) -> void:
	var dist := a.distance_to(b)
	var steps := maxi(int(dist), 2)
	var r := maxf(thickness * 0.5, 1.0)
	for i in steps + 1:
		var t := float(i) / float(steps)
		var px := lerpf(a.x, b.x, t)
		var py := lerpf(a.y, b.y, t)
		_ellipse(img, px, py, r, r, c)


func _poly(img: Image, pts: Array, c: Color) -> void:
	if pts.size() < 3:
		return
	var miny := 9999
	var maxy := -9999
	for p in pts:
		miny = mini(miny, int(p.y))
		maxy = maxi(maxy, int(p.y))
	for y in range(miny, maxy + 1):
		var xs: Array = []
		for i in pts.size():
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[(i + 1) % pts.size()]
			if (a.y <= y and b.y > y) or (b.y <= y and a.y > y):
				var t := (float(y) - a.y) / (b.y - a.y)
				xs.append(a.x + t * (b.x - a.x))
		xs.sort()
		var i2 := 0
		while i2 + 1 < xs.size():
			var x0 := int(round(xs[i2]))
			var x1 := int(round(xs[i2 + 1]))
			for x in range(x0, x1 + 1):
				_put(img, x, y, c)
			i2 += 2


# ---------------------------------------------------------------------------
# Pose data for every animation frame
# ---------------------------------------------------------------------------

func _pose(anim: String, f: int, n: int) -> Dictionary:
	var t := float(f) / float(maxi(n - 1, 1))
	var p: Dictionary = {
		"bob": 0.0, "lean": 0.0, "crouch": 0.0,
		"leg_swing": 0.0, "leg_lift": 0.0, "kick": 0.0,
		"arm": 0.0, "extend": 0.0, "aura": "", "head": 0.0,
	}
	match anim:
		"idle":
			p.bob = sin(t * TAU) * 1.5
			p.arm = sin(t * TAU) * 1.5
		"walk":
			p.leg_swing = sin(t * TAU) * 10.0
			p.leg_lift = maxf(0.0, cos(t * TAU)) * 5.0
			p.arm = -sin(t * TAU) * 8.0
			p.bob = absf(sin(t * TAU)) * 2.0
		"run":
			p.leg_swing = sin(t * TAU) * 15.0
			p.leg_lift = maxf(0.0, cos(t * TAU)) * 9.0
			p.arm = -sin(t * TAU) * 12.0
			p.lean = 6.0
			p.bob = absf(sin(t * TAU)) * 3.0
		"jump":
			p.leg_lift = 11.0
			p.leg_swing = 5.0
			p.arm = -9.0
			p.bob = -3.0
		"crouch":
			p.crouch = 17.0
			p.leg_swing = 4.0
		"attack_1":
			p.extend = [0, 7, 17, 27, 20][f]
			p.lean = 4.0
			p.arm = -4.0
		"attack_2":
			p.kick = [0, 8, 21, 33, 23][f]
			p.lean = -5.0
			p.leg_lift = 6.0
		"block":
			p.extend = 5.0
			p.arm = -12.0
			p.crouch = 5.0
		"hit":
			p.lean = -[0, 6, 10][f]
			p.arm = [0, 8, 13][f]
			p.bob = [0, 1, 2][f]
		"knockback":
			p.lean = -[0, 10, 16][f]
			p.leg_swing = -[0, 6, 10][f]
			p.arm = [0, 12, 18][f]
		"ko":
			p.crouch = 32.0
			p.lean = -12.0
		"sp1_cast":
			p.extend = [0, 8, 16, 23, 27, 18][f]
			p.bob = -[0, 2, 4, 6, 8, 3][f]
			p.arm = -6.0
			p.aura = "gold"
		"sp2_cast":
			p.extend = [0, 6, 12, 18, 24, 14][f]
			p.crouch = [0, 2, 6, 10, 12, 5][f]
			p.aura = "purple"
	return p


# ---------------------------------------------------------------------------
# Full character drawing
# ---------------------------------------------------------------------------

func _draw_frame(img: Image, anim: String, f: int, n: int, pal: Dictionary) -> void:
	var p := _pose(anim, f, n)

	if p.aura == "gold":
		_draw_aura(img, f, n, Color(1.0, 0.78, 0.22, 0.75), Color(1.0, 0.95, 0.65, 0.55))
	elif p.aura == "purple":
		_draw_aura(img, f, n, Color(0.70, 0.18, 0.90, 0.75), Color(0.95, 0.25, 0.75, 0.50))

	var hip := Vector2(64.0 + p.lean * 0.30, 84.0 + p.crouch + p.bob)
	var neck := Vector2(64.0 + p.lean, 52.0 + p.crouch + p.bob)
	var sh_f := neck + Vector2(11, 2)
	var sh_b := neck + Vector2(-11, 2)
	var hand_f := sh_f + Vector2(9 + p.extend, 14 - p.arm * 0.55)
	var hand_b := sh_b + Vector2(-9 - p.extend * 0.25, 14 + p.arm * 0.55)
	var hip_f := hip + Vector2(7, 0)
	var hip_b := hip + Vector2(-7, 0)
	var foot_f := hip_f + Vector2(7 + p.leg_swing + p.kick, 36 - p.leg_lift)
	var foot_b := hip_b + Vector2(-7 - p.leg_swing, 36)

	# Back leg and shoe.
	_limb(img, hip_b, foot_b, 11, pal.pants)
	_limb(img, hip_b, foot_b, 5, pal.pants_hi)
	_ellipse(img, foot_b.x + 2, foot_b.y, 8, 4, pal.shoe_dark)

	# Backpack behind the torso.
	_rect(img, 43, int(neck.y + 5), 15, 30, pal.bag)
	_rect(img, 45, int(neck.y + 7), 11, 26, pal.bag_hi)
	_rect(img, 47, int(neck.y + 17), 8, 8, pal.bag)
	# Backpack strap over the shoulder.
	_limb(img, sh_b, sh_b + Vector2(6, -10), 4, pal.bag_hi)

	# Back arm.
	_limb(img, sh_b, hand_b, 9, pal.shirt_dark)
	_ellipse(img, hand_b.x, hand_b.y, 5, 5, pal.skin_dark)

	# Torso (shirt) with a shaded side.
	_poly(img, [
		sh_b + Vector2(-2, -3), sh_f + Vector2(2, -3),
		hip + Vector2(13, 3), hip + Vector2(-13, 3),
	], pal.shirt)
	_poly(img, [
		sh_f + Vector2(-1, -3), sh_f + Vector2(2, -3),
		hip + Vector2(13, 3), hip + Vector2(3, 3),
	], pal.shirt_dark)
	# Collar and buttons.
	_poly(img, [
		neck + Vector2(-7, -1), neck + Vector2(0, 7), neck + Vector2(-10, 3),
	], pal.shirt)
	_poly(img, [
		neck + Vector2(7, -1), neck + Vector2(0, 7), neck + Vector2(10, 3),
	], pal.shirt_dark)
	_rect(img, 64, int(neck.y + 13), 2, 2, pal.shirt_dark)
	_rect(img, 64, int(neck.y + 21), 2, 2, pal.shirt_dark)

	# Head base (face features are drawn on the separate face layer).
	var hy := 38
	_ellipse(img, 64, hy, 15, 16, pal.skin)
	_ellipse(img, 64, hy + 9, 8, 6, pal.skin_dark)
	# Ear.
	_ellipse(img, 49, hy + 2, 3, 4, pal.skin_dark)
	# Messy wavy hair, built from overlapping masses and highlight strands.
	_ellipse(img, 64, hy - 10, 17, 11, pal.hair)
	_ellipse(img, 52, hy - 7, 9, 9, pal.hair)
	_ellipse(img, 77, hy - 6, 8, 9, pal.hair)
	_ellipse(img, 60, hy - 14, 8, 6, pal.hair)
	_ellipse(img, 70, hy - 13, 7, 6, pal.hair)
	_ellipse(img, 47, hy - 1, 5, 7, pal.hair)
	_ellipse(img, 81, hy, 4, 6, pal.hair)
	_limb(img, Vector2(54, hy - 13), Vector2(61, hy - 16), 2, pal.hair_hi)
	_limb(img, Vector2(66, hy - 16), Vector2(74, hy - 12), 2, pal.hair_hi)
	_limb(img, Vector2(76, hy - 8), Vector2(80, hy - 3), 2, pal.hair_hi)
	_limb(img, Vector2(50, hy - 4), Vector2(47, hy + 2), 2, pal.hair_hi)
	# Cheek bandage (Khushal's distinguishing mark).
	_rect(img, 72, hy + 5, 7, 5, pal.plaster)
	_rect(img, 73, hy + 3, 2, 9, pal.plaster)
	_rect(img, 75, hy + 6, 3, 1, pal.skin_dark)

	# Front leg and shoe.
	_limb(img, hip_f, foot_f, 12, pal.pants)
	_limb(img, hip_f, foot_f, 5, pal.pants_hi)
	_ellipse(img, foot_f.x + 3, foot_f.y, 9, 5, pal.shoe)
	_rect(img, int(foot_f.x - 3), int(foot_f.y + 3), 13, 2, pal.shoe_dark)
	_limb(img, Vector2(foot_f.x + 1, foot_f.y - 3), Vector2(foot_f.x + 6, foot_f.y - 2), 1, pal.shoe_dark)

	# Front arm and fist.
	_limb(img, sh_f, hand_f, 10, pal.shirt)
	_limb(img, sh_f + Vector2(0, 9), hand_f, 5, pal.shirt_dark)
	_ellipse(img, hand_f.x, hand_f.y, 6, 6, pal.skin)
	_ellipse(img, hand_f.x + 2, hand_f.y - 1, 3, 3, pal.skin_dark)


func _draw_aura(img: Image, f: int, n: int, outer: Color, inner: Color) -> void:
	var t := float(f) / float(maxi(n - 1, 1))
	var radius := 24.0 + t * 34.0
	_ellipse(img, 64, 72, radius, radius * 1.25, outer)
	_ellipse(img, 64, 72, radius * 0.6, radius * 0.8, inner)
	for i in 8:
		var a := float(i) / 8.0 * TAU + t
		var x := 64.0 + cos(a) * radius * 1.3
		var y := 72.0 + sin(a) * radius * 1.4
		_limb(img, Vector2(64, 72), Vector2(x, y), 2, inner)


func _draw_face(img: Image, expression: String, pal: Dictionary) -> void:
	var hy := 38
	var ink: Color = pal.ink
	match expression:
		"normal":
			_ellipse(img, 58, hy - 1, 2, 3, ink)
			_ellipse(img, 70, hy - 1, 2, 3, ink)
			_limb(img, Vector2(55, hy - 6), Vector2(61, hy - 5), 1, pal.hair)
			_limb(img, Vector2(67, hy - 5), Vector2(73, hy - 6), 1, pal.hair)
			_limb(img, Vector2(60, hy + 9), Vector2(68, hy + 9), 1, pal.mouth)
		"childish":
			_limb(img, Vector2(55, hy), Vector2(58, hy - 3), 1, ink)
			_limb(img, Vector2(58, hy - 3), Vector2(61, hy), 1, ink)
			_limb(img, Vector2(67, hy), Vector2(70, hy - 3), 1, ink)
			_limb(img, Vector2(70, hy - 3), Vector2(73, hy), 1, ink)
			_ellipse(img, 64, hy + 10, 5, 4, ink)
			_ellipse(img, 64, hy + 12, 3, 1, Color(0.85, 0.30, 0.30))
		"surprised":
			_ellipse(img, 58, hy - 1, 4, 5, Color(1, 1, 1))
			_ellipse(img, 70, hy - 1, 4, 5, Color(1, 1, 1))
			_ellipse(img, 58, hy, 2, 3, ink)
			_ellipse(img, 70, hy, 2, 3, ink)
			_ellipse(img, 64, hy + 10, 3, 4, ink)
		"angry":
			_limb(img, Vector2(54, hy - 6), Vector2(61, hy - 3), 2, pal.hair)
			_limb(img, Vector2(74, hy - 6), Vector2(67, hy - 3), 2, pal.hair)
			_limb(img, Vector2(56, hy), Vector2(60, hy + 1), 2, ink)
			_limb(img, Vector2(72, hy), Vector2(68, hy + 1), 2, ink)
			_limb(img, Vector2(59, hy + 10), Vector2(69, hy + 8), 2, pal.mouth)
		"sad":
			_limb(img, Vector2(55, hy - 5), Vector2(61, hy - 3), 1, pal.hair)
			_limb(img, Vector2(73, hy - 5), Vector2(67, hy - 3), 1, pal.hair)
			_limb(img, Vector2(56, hy - 1), Vector2(61, hy + 1), 1, ink)
			_limb(img, Vector2(72, hy - 1), Vector2(67, hy + 1), 1, ink)
			_limb(img, Vector2(59, hy + 11), Vector2(69, hy + 9), 1, pal.mouth)
		"smirk":
			_ellipse(img, 58, hy - 1, 2, 3, ink)
			_limb(img, Vector2(67, hy - 4), Vector2(73, hy - 5), 1, pal.hair)
			_limb(img, Vector2(68, hy), Vector2(73, hy - 1), 1, ink)
			_limb(img, Vector2(59, hy + 9), Vector2(69, hy + 7), 1, pal.mouth)
