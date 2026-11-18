extends Resource
class_name CharacterData

## Reusable stats and references for one character. Add a new fighter by
## defining one of these in CharacterLibrary -- no controller changes needed.

@export var id: String = "khushal"
@export var display_name: String = "Khushal"
@export var tagline: String = "Punjabi schoolboy"
@export var max_health: int = 100
@export var move_speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var defense: float = 1.0
@export var attack_1: AttackData
@export var attack_2: AttackData
@export var sp1: AbilityData
@export var sp2: AbilityData
