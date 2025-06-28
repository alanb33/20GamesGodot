extends TextureRect

const base_game_countdown: float = 3.0
var timer: Timer = null

func _start_countdown():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.start(base_game_countdown)

func _on_timeout():
	timer.queue_free()
	queue_free()

func _ready() -> void:
	_start_countdown()
