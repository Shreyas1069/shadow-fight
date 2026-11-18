extends Node
class_name KeyboardController

## Turns keyboard input into a FighterIntent for one fighter.
## Player 1 uses scheme 1, Player 2 uses scheme 2. Both run the exact same
## fighter code -- only the action names change.

@export var fighter_path: NodePath
@export_range(1, 2, 1) var scheme: int = 1

@onready var fighter: Fighter = get_node(fighter_path)


func _physics_process(_delta: float) -> void:
	if fighter == null:
		return

	var prefix := "p1_" if scheme == 1 else "p2_"
	var intent := FighterIntent.new()

	intent.move_axis = Input.get_axis(prefix + "move_left", prefix + "move_right")
	intent.jump_pressed = Input.is_action_just_pressed(prefix + "jump")
	intent.crouch_held = Input.is_action_pressed(prefix + "crouch")
	intent.block_held = Input.is_action_pressed(prefix + "block")
	intent.attack_1_pressed = Input.is_action_just_pressed(prefix + "attack_1")
	intent.attack_2_pressed = Input.is_action_just_pressed(prefix + "attack_2")
	intent.sp1_pressed = Input.is_action_just_pressed(prefix + "sp1")
	intent.sp2_pressed = Input.is_action_just_pressed(prefix + "sp2")

	fighter.set_intent(intent)
