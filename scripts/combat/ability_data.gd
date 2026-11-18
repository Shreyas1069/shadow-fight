extends AttackData
class_name AbilityData

## A special ability is an attack with extra data: a cooldown, a display name
## and a visual effect theme. It inherits all timing/damage fields from
## AttackData so both basic attacks and specials use the same combat pipeline.

@export var display_name: String = "Special"
@export var cooldown: float = 6.0
@export var effect_type: String = "gold"       # "gold" or "purple"
