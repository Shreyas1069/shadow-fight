extends RefCounted
class_name PlaceholderArt

## Builds simple pixel-art placeholders in memory at runtime.
##
## No image files are needed yet. These sprites exist only so the animation
## architecture can be tested. Later, real artwork replaces these SpriteFrames
## resources without changing any gameplay code.
##
## Every frame is a 96x96 transparent image with the character's feet at the
## bottom. That matches the final art convention agreed for the project.

const FRAME_SIZE := 96

## Two temporary colour themes so the two test fighters look different.
## Palette 0 is inspired by Khushal's schoolboy look (white shirt, blue bag).
const PALETTES: Array = [
	{
		"skin": Color(0.93, 0.72, 0.52),
		"hair": Color(0.20, 0.13, 0.10),
		"shirt": Color(0.92, 0.92, 0.86),
		"pants": Color(0.18, 0.19, 0.24),
		"shoes": Color(0.95, 0.95, 0.95),
		"bag": Color(0.16, 0.36, 0.62),
	},
	{
		"skin": Color(0.80, 0.60, 0.45),
		"hair": Color(0.10, 0.10, 0.12),
		"shirt": Color(0.55, 0.14, 0.18),
		"pants": Color(0.22, 0.22, 0.26),
		"shoes": Color(0.20, 0.20, 0.22),
		"bag": Color(0.30, 0.10, 0.12),
	},
]

const BODY_CLIPS: Dictionary = {
	"idle": 2,
	"walk": 4,
	"run": 4,
	"jump": 2,
	"fall": 2,
	"crouch": 2,
	"attack_1": 3,
	"attack_2": 3,
	"block": 2,
	"hit": 2,
	"ko": 2,
	"sp1_cast": 3,
	"sp2_cast": 3,
}

const EXPRESSIONS: Array = [
	"normal", "childish", "surprised", "angry", "sad", "smirk"
]


## All body animations, ready to assign to an AnimatedSprite2D.
static func body_frames(palette_index: int = 0) -> SpriteFrames:
	var pal: Dictionary = PALETTES[clampi(palette_index, 0, PALETTES.size() - 1)]
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	for clip_name in BODY_CLIPS.keys():
		var frame_count: int = BODY_CLIPS[clip_name]
		frames.add_animation(clip_name)
		frames.set_animation_speed(clip_name, 8.0)
		for i in frame_count:
			frames.add_frame(clip_name, _body_image(str(clip_name), i, pal))

	return frames


## Facial expression animations. Kept separate from the body so a fighter can
## run and look surprised at the same time.
static func face_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	for expression in EXPRESSIONS:
		frames.add_animation(expression)
		frames.set_animation_speed(expression, 1.0)
		frames.add_frame(expression, _face_image(str(expression)))

	return frames


## A cheap soft shadow drawn under the fighter.
static func shadow_texture() -> ImageTexture:
	var img := Image.create(FRAME_SIZE, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in FRAME_SIZE:
		var d := absf(x - 48.0) / 48.0
		var h := int(20.0 * (1.0 - d * d))
		for y in range(24 - h, 24):
			img.set_pixel(x, y, Color(0, 0, 0, 0.30 * (1.0 - d * d)))
	return ImageTexture.create_from_image(img)


## -------------------------------------------------------------------------
## Drawing helpers
## -------------------------------------------------------------------------

static func _body_image(anim: String, frame: int, pal: Dictionary) -> ImageTexture:
	var img := Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var skin: Color = pal["skin"]
	var hair: Color = pal["hair"]
	var shirt: Color = pal["shirt"]
	var pants: Color = pal["pants"]
	var shoes: Color = pal["shoes"]
	var bag: Color = pal["bag"]

	var bob := 0
	var leg_swing := 0
	var arm_swing := 0
	var arm_extend := 0
	var leg_extend := 0
	var crouch := 0

	match anim:
		"idle":
			bob = 1 if frame % 2 == 1 else 0
		"walk":
			leg_swing = [4, 0, -4, 0][frame]
			arm_swing = -leg_swing
		"run":
			leg_swing = [7, 0, -7, 0][frame]
			arm_swing = -leg_swing
			bob = 2 if frame % 2 == 1 else 0
		"jump":
			bob = -8
			leg_swing = 5
		"fall":
			bob = -4
			leg_swing = -4
		"crouch":
			crouch = 18
		"attack_1":
			arm_extend = [0, 16, 22][frame]
		"attack_2":
			leg_extend = [0, 18, 26][frame]
		"block":
			arm_extend = 8
		"hit":
			arm_swing = 6
			bob = 2
		"ko":
			crouch = 40
		"sp1_cast", "sp2_cast":
			arm_extend = [4, 14, 22][frame]
			bob = -2

	var top := 8 + bob + crouch

	# Backpack sits behind the torso.
	_rect(img, 24, top + 26, 12, 24, bag)

	# Head, hair, cheek bandage.
	_rect(img, 36, top, 24, 24, skin)
	_rect(img, 33, top - 4, 30, 10, hair)
	_rect(img, 34, top + 2, 6, 8, hair)
	_rect(img, 54, top + 14, 7, 5, Color(0.95, 0.88, 0.72))

	# Torso.
	_rect(img, 33, top + 26, 30, 30, shirt)

	# Arms. The front arm stretches for attacks and block.
	_rect(img, 24 - int(arm_extend / 2), top + 30 + arm_swing, 10, 22, skin)
	_rect(img, 62, top + 30 - arm_swing, 10 + arm_extend, 9, skin)

	# Legs and shoes.
	_rect(img, 38 + leg_swing, top + 56, 9, 26, pants)
	_rect(img, 49 - leg_swing, top + 56, 9, 26, pants)
	_rect(img, 36 + leg_extend, top + 78, 13, 6, shoes)
	_rect(img, 48 + leg_extend, top + 78, 13, 6, shoes)

	# Simple face. The separate Face sprite draws over this.
	_rect(img, 42, top + 11, 3, 3, Color(0.10, 0.08, 0.10))
	_rect(img, 52, top + 11, 3, 3, Color(0.10, 0.08, 0.10))
	_rect(img, 46, top + 19, 6, 2, Color(0.45, 0.20, 0.18))

	return ImageTexture.create_from_image(img)


static func _face_image(expression: String) -> ImageTexture:
	var img := Image.create(FRAME_SIZE, FRAME_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var skin := Color(0.93, 0.72, 0.52)
	var hair := Color(0.20, 0.13, 0.10)
	var ink := Color(0.10, 0.08, 0.10)

	# This plate exactly covers the head drawn by _body_image at idle.
	_rect(img, 36, 8, 24, 24, skin)
	_rect(img, 33, 4, 30, 10, hair)
	_rect(img, 34, 10, 6, 8, hair)
	_rect(img, 54, 22, 7, 5, Color(0.95, 0.88, 0.72))

	match expression:
		"normal":
			_rect(img, 42, 19, 3, 3, ink)
			_rect(img, 52, 19, 3, 3, ink)
			_rect(img, 46, 27, 6, 2, ink)
		"childish":
			_rect(img, 41, 19, 5, 2, ink)
			_rect(img, 51, 19, 5, 2, ink)
			_rect(img, 44, 26, 10, 5, ink)
			_rect(img, 46, 29, 6, 2, Color(0.85, 0.30, 0.30))
		"surprised":
			_rect(img, 41, 18, 5, 5, Color(1, 1, 1))
			_rect(img, 42, 19, 3, 3, ink)
			_rect(img, 51, 18, 5, 5, Color(1, 1, 1))
			_rect(img, 52, 19, 3, 3, ink)
			_rect(img, 47, 27, 4, 4, ink)
		"angry":
			_rect(img, 40, 16, 7, 2, ink)
			_rect(img, 50, 18, 7, 2, ink)
			_rect(img, 42, 20, 3, 3, ink)
			_rect(img, 52, 20, 3, 3, ink)
			_rect(img, 45, 28, 8, 2, ink)
		"sad":
			_rect(img, 42, 20, 3, 2, ink)
			_rect(img, 52, 20, 3, 2, ink)
			_rect(img, 44, 27, 7, 2, ink)
		"smirk":
			_rect(img, 42, 19, 3, 3, ink)
			_rect(img, 52, 18, 3, 2, ink)
			_rect(img, 47, 27, 7, 2, ink)

	return ImageTexture.create_from_image(img)


static func _rect(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	var x0 := clampi(x, 0, img.get_width() - 1)
	var y0 := clampi(y, 0, img.get_height() - 1)
	var x1 := clampi(x + w, 0, img.get_width())
	var y1 := clampi(y + h, 0, img.get_height())
	if x1 <= x0 or y1 <= y0:
		return
	img.fill_rect(Rect2i(x0, y0, x1 - x0, y1 - y0), color)
