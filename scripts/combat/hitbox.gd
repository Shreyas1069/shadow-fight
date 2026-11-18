extends Area2D
class_name Hitbox

## Temporary damage area created during an attack's "active" window.
## It hits each target only once and then removes itself.

var damage: int = 0
var knockback: float = 0.0
var hitstun: float = 0.0
var owner_fighter: Fighter
var _hit_ids: Dictionary = {}


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 2          # layer 2 = Hurtbox
	area_entered.connect(_on_area_entered)


func configure(owner: Fighter, amount: int, push: float, stun: float) -> void:
	owner_fighter = owner
	damage = amount
	knockback = push
	hitstun = stun


func _on_area_entered(area: Area2D) -> void:
	if not area is Hurtbox:
		return
	var id := area.get_instance_id()
	if _hit_ids.has(id):
		return
	var target: Fighter = (area as Hurtbox).fighter
	if target == null or target == owner_fighter:
		return
	if target.is_dead():
		return

	_hit_ids[id] = true
	var direction := 1
	if owner_fighter != null:
		direction = owner_fighter.facing
	target.take_damage(damage, knockback * float(direction), hitstun)
