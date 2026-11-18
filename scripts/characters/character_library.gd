extends RefCounted
class_name CharacterLibrary

## All character definitions live here for now. Later these can become .tres
## resource files without changing the Fighter, controllers or HUD.

static func get_data(id: String) -> CharacterData:
	match id:
		"khushal":
			return _khushal()
		"rival":
			return _rival()
		_:
			return _rival()


static func _khushal() -> CharacterData:
	var data := CharacterData.new()
	data.id = "khushal"
	data.display_name = "KHUSHAL"
	data.tagline = "Punjabi schoolboy - childish and expressive"
	data.max_health = 100
	data.move_speed = 310.0
	data.jump_velocity = -510.0
	data.defense = 1.0

	var punch := AttackData.new()
	punch.anim_name = "attack_1"
	punch.damage = 8
	punch.startup = 0.08
	punch.active = 0.10
	punch.recovery = 0.16
	punch.hitbox_size = Vector2(56, 32)
	punch.hitbox_offset = Vector2(66, -56)
	punch.knockback = 190.0
	punch.hitstun = 0.26
	data.attack_1 = punch

	var kick := AttackData.new()
	kick.anim_name = "attack_2"
	kick.damage = 12
	kick.startup = 0.13
	kick.active = 0.11
	kick.recovery = 0.24
	kick.hitbox_size = Vector2(58, 30)
	kick.hitbox_offset = Vector2(62, -40)
	kick.knockback = 280.0
	kick.hitstun = 0.34
	data.attack_2 = kick

	var sp1 := AbilityData.new()
	sp1.display_name = "PAPA FROM HEAVEN"
	sp1.anim_name = "sp1_cast"
	sp1.cooldown = 7.0
	sp1.damage = 26
	sp1.startup = 0.45
	sp1.active = 0.70
	sp1.recovery = 0.40
	sp1.effect_type = "gold"
	sp1.hitbox_size = Vector2(150, 150)
	sp1.hitbox_offset = Vector2(110, -70)
	sp1.knockback = 440.0
	sp1.hitstun = 0.60
	data.sp1 = sp1

	var sp2 := AbilityData.new()
	sp2.display_name = "MUMMA FROM GRAVE"
	sp2.anim_name = "sp2_cast"
	sp2.cooldown = 8.0
	sp2.damage = 30
	sp2.startup = 0.50
	sp2.active = 0.75
	sp2.recovery = 0.45
	sp2.effect_type = "purple"
	sp2.hitbox_size = Vector2(160, 150)
	sp2.hitbox_offset = Vector2(115, -65)
	sp2.knockback = 480.0
	sp2.hitstun = 0.65
	data.sp2 = sp2

	return data


static func _rival() -> CharacterData:
	var data := CharacterData.new()
	data.id = "rival"
	data.display_name = "OPPONENT"
	data.tagline = "Training dummy"
	data.max_health = 140
	data.move_speed = 260.0
	data.jump_velocity = -480.0
	data.defense = 1.15

	var punch := AttackData.new()
	punch.anim_name = "attack_1"
	punch.damage = 6
	punch.startup = 0.12
	punch.active = 0.10
	punch.recovery = 0.20
	data.attack_1 = punch

	var kick := AttackData.new()
	kick.anim_name = "attack_2"
	kick.damage = 10
	data.attack_2 = kick

	var sp1 := AbilityData.new()
	sp1.effect_type = "purple"
	sp1.display_name = "DUMMY SP1"
	data.sp1 = sp1

	var sp2 := AbilityData.new()
	sp2.effect_type = "purple"
	sp2.display_name = "DUMMY SP2"
	data.sp2 = sp2

	return data
