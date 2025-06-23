class_name WiggleButton
extends Button

var cur_speed: float = 0.0
const wiggle_speed: float = 2.5
const hover_amplifier: float = 2.0

var _speed_up: float = 1.0
var delta_accumulation: float = 0.0
const range_reducer: float = 5.0

func _center_pivot() -> void:
	# Godot doesn't let you center a pivot from Inspector but you can do it from code
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

## TODO: How do I make a base signal emit a custom value? Can condense these.
func _decrease_speed():
	_speed_up = 1.0

func _increase_speed():
	_speed_up *= hover_amplifier

func _link_press_amplifier() -> void:
	button_down.connect(_increase_speed)
	button_up.connect(_decrease_speed)

func _ready() -> void:
	_center_pivot()
	_link_press_amplifier()

func _wiggle(delta: float) -> void:
	delta_accumulation += delta
	rotation = (sin(delta_accumulation * cur_speed  * _speed_up) / range_reducer)

func _process(delta: float) -> void:
	if is_hovered():
		cur_speed = wiggle_speed
	else:
		cur_speed = 0.0
	if cur_speed > 0.0:
		_wiggle(delta)
