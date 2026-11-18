extends CanvasLayer
class_name HUD

## Readable HUD for PC and mobile: names, health bars and SP readiness.

@export var p1_path: NodePath
@export var p2_path: NodePath

@onready var p1_name: Label = $Root/P1Name
@onready var p1_fill: ColorRect = $Root/P1BarFill
@onready var p1_sp1: Label = $Root/P1SP1
@onready var p1_sp2: Label = $Root/P1SP2
@onready var p2_name: Label = $Root/P2Name
@onready var p2_fill: ColorRect = $Root/P2BarFill
@onready var p2_sp1: Label = $Root/P2SP1
@onready var p2_sp2: Label = $Root/P2SP2

const BAR_WIDTH := 420.0

var p1: Fighter
var p2: Fighter


func _ready() -> void:
	p1 = get_node(p1_path) as Fighter
	p2 = get_node(p2_path) as Fighter
	if p1 == null or p2 == null:
		push_error("HUD could not find the fighters")
		return

	p1.health_changed.connect(_on_health_changed)
	p2.health_changed.connect(_on_health_changed)
	p1_name.text = p1.data.display_name
	p2_name.text = p2.data.display_name
	_update_bars()


func _process(_delta: float) -> void:
	if p1 == null or p2 == null:
		return
	_update_sp(p1_sp1, p1, 0)
	_update_sp(p1_sp2, p1, 1)
	_update_sp(p2_sp1, p2, 0)
	_update_sp(p2_sp2, p2, 1)


func _on_health_changed(_current: int, _maximum: int) -> void:
	_update_bars()


func _update_bars() -> void:
	var w1 := BAR_WIDTH * clampf(float(p1.health) / float(p1.max_health), 0.0, 1.0)
	var w2 := BAR_WIDTH * clampf(float(p2.health) / float(p2.max_health), 0.0, 1.0)
	# P1 drains from the right. P2 drains from the left (right edge stays put).
	p1_fill.size.x = w1
	p2_fill.offset_left = -30.0 - w2


func _update_sp(label: Label, fighter: Fighter, slot: int) -> void:
	var short := "SP1" if slot == 0 else "SP2"
	var remaining := fighter.get_cooldown(slot)
	if remaining > 0.0:
		label.text = "%s  %.1fs" % [short, remaining]
		label.modulate = Color(0.55, 0.55, 0.62)
	else:
		label.text = "%s  READY" % short
		label.modulate = Color(1.0, 0.82, 0.25) if slot == 0 else Color(0.90, 0.40, 1.0)
