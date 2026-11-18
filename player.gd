
extends CharacterBody2D

# Player movement settings
@export var move_speed: float = 300.0
@export var jump_velocity: float = -500.0

# Get gravity from project settings
var gravity: float = float(
	ProjectSettings.get_setting(
        "physics/2d/default_gravity"
	)
)

func _physics_process(delta: float) -> void:

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get horizontal movement
	var direction = Input.get_axis(
		"move_left",
        "move_right"
	)

	velocity.x = direction * move_speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Apply movement and collision
	move_and_slide()

func _ready() -> void:
	var body = $Polygon2D

	body.color = Color.BLACK

	body.polygon = PackedVector2Array([
		Vector2(-12, -88),
		Vector2(-6, -88),
		Vector2(0, -80),
		Vector2(6, -88),
		Vector2(12, -88),
		Vector2(10, -72),
		Vector2(18, -60),
		Vector2(12, -55),
		Vector2(7, -65),
		Vector2(7, -42),
		Vector2(16, -12),
		Vector2(9, -8),
		Vector2(0, -35),
		Vector2(-9, -8),
		Vector2(-16, -12),
		Vector2(-7, -42),
		Vector2(-7, -65),
		Vector2(-12, -55),
		Vector2(-18, -60),
		Vector2(-10, -72)
	])
