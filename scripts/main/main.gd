extends Node2D

## Small helper for the Milestone 1 test scene.
## F2 shows/hides the on-screen touch controls so they can be tested on PC.

@onready var mobile_controls: CanvasLayer = $MobileControls


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_touch") and mobile_controls != null:
		mobile_controls.visible = not mobile_controls.visible
