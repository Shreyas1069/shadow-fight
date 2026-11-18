extends Area2D
class_name Hurtbox

## The area that can be hit. Hitboxes look for this type of node.

@onready var fighter: Fighter = get_parent() as Fighter
