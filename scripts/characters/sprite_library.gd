extends RefCounted
class_name SpriteLibrary

## Builds SpriteFrames from the PNG sprite sheets in assets/characters/.
##
## Every frame is 128x128 with the feet at y=120. Because the artwork lives in
## real PNG files, an artist can replace a sheet and the game picks it up with
## no code changes.

const FRAME_W := 128
const FRAME_H := 128

const CLIP_FRAMES: Dictionary = {
	"idle": 4, "walk": 6, "run": 6, "jump": 4, "crouch": 2,
	"attack_1": 5, "attack_2": 5, "block": 2, "hit": 3,
	"knockback": 3, "ko": 3, "sp1_cast": 6, "sp2_cast": 6,
}

const CLIP_SPEED: Dictionary = {
	"idle": 7.0, "walk": 10.0, "run": 14.0, "jump": 8.0, "crouch": 6.0,
	"attack_1": 14.0, "attack_2": 14.0, "block": 6.0, "hit": 12.0,
	"knockback": 12.0, "ko": 7.0, "sp1_cast": 10.0, "sp2_cast": 10.0,
}

const EXPRESSIONS: Array = ["normal", "childish", "surprised", "angry", "sad", "smirk"]


static func body_frames(character_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	for clip in CLIP_FRAMES.keys():
		var path := "res://assets/characters/%s/%s.png" % [character_id, clip]
		var texture := load(path) as Texture2D
		if texture == null:
			push_warning("Sprite sheet missing: " + path)
			continue

		frames.add_animation(clip)
		frames.set_animation_speed(clip, CLIP_SPEED[clip])
		for i in int(CLIP_FRAMES[clip]):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(float(i * FRAME_W), 0.0, float(FRAME_W), float(FRAME_H))
			frames.add_frame(clip, atlas)

	return frames


static func face_frames(character_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	var path := "res://assets/characters/%s/face.png" % character_id
	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("Face sheet missing: " + path)
		return frames

	for i in EXPRESSIONS.size():
		var name := str(EXPRESSIONS[i])
		frames.add_animation(name)
		frames.set_animation_speed(name, 1.0)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(float(i * FRAME_W), 0.0, float(FRAME_W), float(FRAME_H))
		frames.add_frame(name, atlas)

	return frames
