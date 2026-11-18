extends Button
class_name TouchButton

## A touch button that reports both tap and hold.
##
## Tap actions (attacks, specials, jump) use the "tapped" signal.
## Hold actions (block) read the "is_held" variable.

signal tapped

var is_held: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)


func _on_button_down() -> void:
	is_held = true


func _on_button_up() -> void:
	is_held = false


func _on_pressed() -> void:
	tapped.emit()
