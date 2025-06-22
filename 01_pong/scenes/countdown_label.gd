class_name CountdownLabel
extends Control

@onready var label: Label = $Label
var delta_accumulation: float = 0.0

var wiggle_speed: float = 5.0
const range_reducer: float = 3.0

var countdown_timer: Timer = null
var clock_value = 3

signal countdown_finished

func do_countdown(start_value: int):
	if countdown_timer:
		_reset_timer()
	_show_clock()
	_update_value(start_value)
	countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.start(1.0)
	countdown_timer.timeout.connect(_on_countdown_timer_tick)

## Private Functions

func _hide_clock():
	visible = false

func _show_clock():
	visible = true
	
func _reset_timer():
	clock_value = 3
	label.text = "3"
	countdown_timer.stop()
	countdown_timer.queue_free()
	countdown_timer = null

func _update_value(new_value: int):
	assert(new_value > 0, "Received an update value, but it's %d (must be above 0)" % new_value)
	clock_value = new_value
	if new_value == 1:
		label.text = "And..."
	else:
		label.text = str(new_value)

func _on_countdown_timer_tick():
	clock_value -= 1
	match clock_value:
		-1:
			# End countdown
			_hide_clock()
			_reset_timer()
		0:
			# Flavor text
			label.text = "Serve!"
			countdown_finished.emit()
		1:
			# Flavor text
			label.text = "And..."
		_:
			label.text = str(clock_value)

func _process(delta: float) -> void:
	delta_accumulation += delta
	label.rotation = sin(delta_accumulation * wiggle_speed) / range_reducer
	
func _ready() -> void:
	_hide_clock()
