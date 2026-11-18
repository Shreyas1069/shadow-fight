extends CharacterBody2D
class_name Fighter

## Shared base class for every fighter.
##
## It owns movement, facing, animation, health, hit detection, blocking,
## knockback and the two special abilities. Controllers (keyboard / touch / AI)
## feed it a FighterIntent; this script never reads Input directly.

signal health_changed(current: int, maximum: int)
signal cooldown_changed(slot: int, remaining: float, total: float)
signal defeated

const EFFECT_SCENE := preload("res://scenes/combat/special_effect.tscn")

# --- Inspector settings ----------------------------------------------------
@export var character_id: String = "khushal"
@export var is_dummy: bool = false
@export var opponent_path: NodePath

# --- Scene references ------------------------------------------------------
@onready var visual_root: Node2D = $VisualRoot
@onready var body_sprite: AnimatedSprite2D = $VisualRoot/Body
@onready var face_sprite: AnimatedSprite2D = $VisualRoot/Face
@onready var shadow_sprite: Sprite2D = $VisualRoot/Shadow
@onready var hitbox_pivot: Marker2D = $HitboxPivot
@onready var opponent: Fighter = get_node_or_null(opponent_path) as Fighter

# --- Public runtime state --------------------------------------------------
var data: CharacterData
var health: int = 100
var max_health: int = 100
var facing: int = 1
var current_state: String = "idle"
var intent: FighterIntent = FighterIntent.new()
var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))

# --- Internal state --------------------------------------------------------
var _reaction_timer: float = 0.0
var _expression: String = "normal"
var _attack: AttackData
var _ability: AbilityData
var _ability_slot: int = -1
var _phase: String = ""              # "" / startup / active / recovery
var _phase_timer: float = 0.0
var _active_hitbox: Hitbox
var _cooldowns: Array = [0.0, 0.0]
var _flash: float = 0.0
var _was_on_floor: bool = true


func _ready() -> void:
	data = CharacterLibrary.get_data(character_id)
	max_health = data.max_health
	health = max_health

	body_sprite.sprite_frames = SpriteLibrary.body_frames(data.id)
	face_sprite.sprite_frames = SpriteLibrary.face_frames(data.id)
	if shadow_sprite.texture == null:
		shadow_sprite.texture = PlaceholderArt.shadow_texture()

	# Align the 128px sprite sheet so the drawn feet sit at the body origin.
	body_sprite.offset = Vector2(0, -120)
	face_sprite.offset = Vector2(0, -120)

	_default_expression()
	health_changed.emit(health, max_health)
	_update_animation()


func is_dead() -> bool:
	return health <= 0


## Called by controllers once per physics frame.
func set_intent(value: FighterIntent) -> void:
	intent = value


func get_cooldown(slot: int) -> float:
	if slot < 0 or slot >= _cooldowns.size():
		return 0.0
	return _cooldowns[slot]


func get_cooldown_total(slot: int) -> float:
	if data == null:
		return 1.0
	return data.sp1.cooldown if slot == 0 else data.sp2.cooldown


func get_ability_name(slot: int) -> String:
	if data == null:
		return "SPECIAL"
	return data.sp1.display_name if slot == 0 else data.sp2.display_name


func _physics_process(delta: float) -> void:
	_update_cooldowns(delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	_was_on_floor = is_on_floor()
	_update_action(delta)

	var busy := _phase != "" or _reaction_timer > 0.0 or is_dead()

	if not is_dummy and not busy:
		var axis := intent.move_axis
		var target := axis * data.move_speed
		var control := 1800.0 if is_on_floor() else 1100.0
		var brake := 2200.0 if is_on_floor() else 1300.0

		if absf(axis) > 0.01 and not intent.block_held and not intent.crouch_held:
			velocity.x = move_toward(velocity.x, target, control * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, brake * delta)

		if absf(axis) > 0.01:
			facing = 1 if axis > 0.0 else -1

		if intent.jump_pressed and is_on_floor() and not intent.crouch_held:
			velocity.y = data.jump_velocity
	else:
		velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)

	move_and_slide()

	# Turn toward the opponent when standing still.
	if opponent != null and not opponent.is_dead() and absf(velocity.x) < 12.0:
		if current_state in ["idle", "block", "crouch"]:
			facing = 1 if opponent.global_position.x > global_position.x else -1

	visual_root.scale.x = float(facing)

	_determine_state(delta)
	_update_animation()

	_flash = maxf(0.0, _flash - delta)
	visual_root.modulate = Color(1, 1, 1) if _flash <= 0.0 else Color(1, 0.45, 0.45)


func _update_cooldowns(delta: float) -> void:
	for i in _cooldowns.size():
		if _cooldowns[i] > 0.0:
			_cooldowns[i] = maxf(0.0, _cooldowns[i] - delta)
			cooldown_changed.emit(i, _cooldowns[i], get_cooldown_total(i))


# ---------------------------------------------------------------------------
# Attacks and abilities
# ---------------------------------------------------------------------------

func _try_attack(attack: AttackData, ability: bool, slot: int) -> void:
	if _phase != "" or _reaction_timer > 0.0 or is_dead() or is_dummy:
		return
	if attack == null:
		return
	if ability and _cooldowns[slot] > 0.0:
		return

	if ability:
		_cooldowns[slot] = attack.cooldown
		cooldown_changed.emit(slot, attack.cooldown, attack.cooldown)

	_attack = attack
	_ability = attack as AbilityData if ability else null
	_ability_slot = slot if ability else -1
	_phase = "startup"
	_phase_timer = attack.startup
	current_state = attack.anim_name
	set_expression("angry")


func _update_action(delta: float) -> void:
	if _phase == "" or _attack == null:
		return

	_phase_timer -= delta
	if _phase_timer > 0.0:
		return

	match _phase:
		"startup":
			_phase = "active"
			_phase_timer = _attack.active
			_spawn_hitbox()
			if _ability != null:
				_spawn_effect()
		"active":
			_phase = "recovery"
			_phase_timer = _attack.recovery
			_remove_hitbox()
		"recovery":
			_phase = ""
			_attack = null
			_ability = null
			_ability_slot = -1
			_remove_hitbox()


func _spawn_hitbox() -> void:
	_remove_hitbox()
	var hb := Hitbox.new()
	var shape := RectangleShape2D.new()
	shape.size = _attack.hitbox_size
	var col := CollisionShape2D.new()
	col.shape = shape
	hb.add_child(col)
	hb.position = Vector2(_attack.hitbox_offset.x * float(facing), _attack.hitbox_offset.y)
	add_child(hb)
	hb.configure(self, _attack.damage, _attack.knockback, _attack.hitstun)
	_active_hitbox = hb


func _remove_hitbox() -> void:
	if is_instance_valid(_active_hitbox):
		_active_hitbox.queue_free()
	_active_hitbox = null


func _spawn_effect() -> void:
	if _ability == null:
		return
	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	var fx := EFFECT_SCENE.instantiate() as SpecialEffect
	if fx == null:
		return
	parent.add_child(fx)
	fx.effect_type = _ability.effect_type

	var x := global_position.x + 95.0 * float(facing)
	var y := global_position.y
	if opponent != null:
		x = opponent.global_position.x + 24.0 * float(facing)
		y = opponent.global_position.y
	fx.global_position = Vector2(x, y)
	fx.play(_ability.active + _ability.recovery + 0.35)


# ---------------------------------------------------------------------------
# Damage, blocking and knockback
# ---------------------------------------------------------------------------

func take_damage(amount: int, push_x: float, stun: float) -> void:
	if is_dead():
		return

	var dealt := maxf(1.0, float(amount) / data.defense)
	if current_state == "block":
		dealt *= 0.25
		push_x *= 0.20
		stun *= 0.20

	health = maxi(0, health - int(dealt))
	health_changed.emit(health, max_health)
	_flash = 0.16
	set_expression("surprised")
	_cancel_action()

	if health <= 0:
		current_state = "ko"
		_reaction_timer = 999.0
		defeated.emit()
		return

	current_state = "knockback" if absf(push_x) > 320.0 else "hit"
	_reaction_timer = maxf(stun, 0.12)
	velocity.x = push_x
	velocity.y = -minf(absf(push_x) * 0.30, 190.0)


func _cancel_action() -> void:
	_phase = ""
	_attack = null
	_ability = null
	_ability_slot = -1
	_phase_timer = 0.0
	_remove_hitbox()


# ---------------------------------------------------------------------------
# State and animation
# ---------------------------------------------------------------------------

func _determine_state(delta: float) -> void:
	if _reaction_timer > 0.0:
		_reaction_timer -= delta
		return

	if _phase != "" and _attack != null:
		current_state = _attack.anim_name
		return

	if is_dead():
		current_state = "ko"
		return

	var new_state := "idle"
	if not is_on_floor():
		new_state = "jump" if velocity.y < 0.0 else "fall"
	elif is_dummy:
		new_state = "idle"
	elif intent.block_held:
		new_state = "block"
	elif intent.attack_1_pressed:
		_try_attack(data.attack_1, false, -1)
		return
	elif intent.attack_2_pressed:
		_try_attack(data.attack_2, false, -1)
		return
	elif intent.sp1_pressed:
		_try_attack(data.sp1, true, 0)
		return
	elif intent.sp2_pressed:
		_try_attack(data.sp2, true, 1)
		return
	elif intent.crouch_held:
		new_state = "crouch"
	elif absf(velocity.x) > 12.0:
		new_state = "run" if absf(velocity.x) > data.move_speed * 0.75 else "walk"

	current_state = new_state

	match current_state:
		"attack_1", "attack_2", "sp1_cast", "sp2_cast":
			set_expression("angry")
		"hit", "knockback":
			set_expression("surprised")
		"block", "crouch", "ko":
			set_expression("sad")
		_:
			_default_expression()


func _default_expression() -> void:
	var expression := "childish" if data != null and data.id == "khushal" else "normal"
	set_expression(expression)


func set_expression(value: String) -> void:
	if value == _expression:
		return
	if face_sprite.sprite_frames != null and face_sprite.sprite_frames.has_animation(value):
		_expression = value
		face_sprite.play(value)


func _update_animation() -> void:
	if body_sprite.sprite_frames == null:
		return
	if not body_sprite.sprite_frames.has_animation(current_state):
		current_state = "idle"
	if String(body_sprite.animation) != current_state:
		body_sprite.play(current_state)
