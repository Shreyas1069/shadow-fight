extends Control
class_name OnScreenJoystick

## Lightweight on-screen joystick for the left side of the screen.
##
## It only does work when a touch/mouse event arrives, so it costs almost
## nothing on low-end phones. Mouse support is included so you can test it in
## the Godot editor on PC without an Android device.

signal vector_changed(value: Vector2)

@export var deadzone: float = 0.18
@export var max_radius: float = 55.0
@export var knob_radius: float = 20.0

## Public read-only-ish value consumed by TouchController.
var axis: Vector2 = Vector2.ZERO

var _center: Vector2 = Vector2.ZERO
var _touch_index: int = -1
var _mouse_down: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_center = size * 0.5
	resized.connect(_on_resized)
	queue_redraw()


func _on_resized() -> void:
	_center = size * 0.5
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed and _touch_index == -1:
			_touch_index = t.index
			_center = t.position
			_set_vector(Vector2.ZERO)
			accept_event()
		elif not t.pressed and t.index == _touch_index:
			_touch_index = -1
			_center = size * 0.5
			_set_vector(Vector2.ZERO)
			accept_event()

	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == _touch_index:
			_set_vector(d.position - _center)
			accept_event()

	elif event is InputEventMouseButton:
		var m := event as InputEventMouseButton
		if m.button_index == MOUSE_BUTTON_LEFT:
			_mouse_down = m.pressed
			_center = m.position if m.pressed else size * 0.5
			_set_vector(Vector2.ZERO)
			accept_event()

	elif event is InputEventMouseMotion and _mouse_down:
		_set_vector((event as InputEventMouseMotion).position - _center)
		accept_event()


func _set_vector(offset: Vector2) -> void:
	if max_radius <= 0.0:
		return
	if offset.length() > max_radius:
		offset = offset.limit_length(max_radius)

	var strength := offset.length() / max_radius
	axis = Vector2.ZERO if strength < deadzone else offset / max_radius

	vector_changed.emit(axis)
	queue_redraw()


func _draw() -> void:
	var base := _center if (_touch_index != -1 or _mouse_down) else size * 0.5
	draw_circle(base, max_radius, Color(1, 1, 1, 0.07))
	draw_arc(base, max_radius, 0.0, TAU, 32, Color(1, 1, 1, 0.35), 2.0)
	draw_circle(base + axis * max_radius, knob_radius, Color(1.0, 0.78, 0.25, 0.75))
