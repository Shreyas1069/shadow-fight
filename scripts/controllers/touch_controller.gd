extends Node
class_name TouchController

## Reads the virtual joystick and on-screen buttons and produces the exact
## same FighterIntent that the keyboard controller produces.
##
## It only sends an intent when there is actual touch activity. That way a
## player testing with a mouse on PC is not blocked by an idle touch layer.

@export var fighter_path: NodePath
@export var joystick_path: NodePath
@export var jump_button_path: NodePath
@export var block_button_path: NodePath
@export var attack_1_button_path: NodePath
@export var attack_2_button_path: NodePath
@export var sp1_button_path: NodePath
@export var sp2_button_path: NodePath

@onready var fighter: Fighter = get_node(fighter_path)
@onready var joystick: OnScreenJoystick = get_node(joystick_path)
@onready var block_button: TouchButton = get_node(block_button_path)

var _jump := false
var _attack_1 := false
var _attack_2 := false
var _sp1 := false
var _sp2 := false


func _ready() -> void:
	_connect_tap(jump_button_path, _on_jump_tapped)
	_connect_tap(attack_1_button_path, _on_attack_1_tapped)
	_connect_tap(attack_2_button_path, _on_attack_2_tapped)
	_connect_tap(sp1_button_path, _on_sp1_tapped)
	_connect_tap(sp2_button_path, _on_sp2_tapped)


func _connect_tap(path: NodePath, callback: Callable) -> void:
	var button := get_node(path) as TouchButton
	if button != null:
		button.tapped.connect(callback)


func _on_jump_tapped() -> void:
	_jump = true


func _on_attack_1_tapped() -> void:
	_attack_1 = true


func _on_attack_2_tapped() -> void:
	_attack_2 = true


func _on_sp1_tapped() -> void:
	_sp1 = true


func _on_sp2_tapped() -> void:
	_sp2 = true


func _physics_process(_delta: float) -> void:
	if fighter == null or joystick == null:
		return

	var axis_x: float = joystick.axis.x
	var blocking := block_button != null and block_button.is_held

	# Ignore an idle touch layer so keyboard input still works on PC.
	var active := (
		absf(axis_x) > 0.01
		or _jump or _attack_1 or _attack_2 or _sp1 or _sp2
		or blocking
	)
	if not active:
		return

	var intent := FighterIntent.new()
	intent.move_axis = axis_x
	intent.jump_pressed = _jump
	intent.attack_1_pressed = _attack_1
	intent.attack_2_pressed = _attack_2
	intent.sp1_pressed = _sp1
	intent.sp2_pressed = _sp2
	intent.block_held = blocking

	# These are edge-triggered: clear them after they have been consumed.
	_jump = false
	_attack_1 = false
	_attack_2 = false
	_sp1 = false
	_sp2 = false

	fighter.set_intent(intent)
