extends Resource
class_name AttackData

## Timing and damage for one basic attack.
## startup -> active (hitbox exists) -> recovery. This is what stops players
## from attacking continuously without animation timing.

@export var anim_name: String = "attack_1"
@export var damage: int = 8
@export var startup: float = 0.10
@export var active: float = 0.10
@export var recovery: float = 0.18
@export var hitbox_size: Vector2 = Vector2(44, 30)
@export var hitbox_offset: Vector2 = Vector2(48, -56)
@export var knockback: float = 190.0
@export var hitstun: float = 0.28
