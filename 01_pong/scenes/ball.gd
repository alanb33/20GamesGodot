class_name Ball
extends CharacterBody2D

@onready var body: float = $Pieces/BodyBase.texture.get_size().y
@onready var half_body: float = body / 2

var preset_dir: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO

const BALL_ANGLE_BOOST: float = 0.25

const BASE_SPEED: float = 500.0
var CURRENT_SPEED: float = BASE_SPEED
var speed_ratio: float:
	get:
		return CURRENT_SPEED / BASE_SPEED

const RESERVE_TIME: float = 1.0

signal score_event(ball_dir: Vector2)
signal bounce(new_ball_dir_x: float)

## Public Functions

func paddle_bounce(paddle_pos: Vector2, paddle_half: Vector2):
	var paddle_top: float = paddle_pos.y - paddle_half.y - body
	var paddle_bottom: float = paddle_pos.y + paddle_half.y + body
	if position.y < paddle_top or position.y > paddle_bottom:
		# We're hitting the top or bottom edge... so only a Y reflection like we hit a wall!
		dir.y = -dir.y
	else:
		# We're against the vertical surface of the paddle, so horizontal reflection is ok.
		dir.x = -dir.x
		
		# If we hit the end quarters, increase the angle.
		var paddle_quarter = paddle_half.y / 2
		var upper_quarter_start = paddle_pos.y - paddle_quarter
		var lower_quarter_start = paddle_pos.y + paddle_quarter
		
		if position.y < upper_quarter_start or position.y > lower_quarter_start:
			if position.y < paddle_pos.y:
				# We're above the paddle center, so angle upwards
				dir.y = -abs(dir.y) - BALL_ANGLE_BOOST
			else:
				dir.y = abs(dir.y) + BALL_ANGLE_BOOST
			dir.y *= 1.25
			
	CURRENT_SPEED *= 1.1
	bounce.emit(dir.x)

func preset_direction():
	var h_dir = _get_h_dir()
	var angle = _get_angle()
	preset_dir = Vector2(h_dir, angle).normalized()

func serve_ball():
	dir = preset_dir
	bounce.emit(dir.x)
	
## Private Functions
	
func _check_for_collisions():
	_check_for_walls()
	_check_for_goals()
	
func _check_for_goals():
	var min_x = -body
	var max_x = get_viewport_rect().size.x + body
	
	if position.x < min_x or position.x > max_x:
		_score()
		_reset_ball()
	
func _check_for_walls():
	var min_y = half_body
	var max_y = get_viewport_rect().size.y - half_body
	
	if position.y < min_y or position.y > max_y:
		position.y = clamp(position.y, min_y, max_y)
		dir.y = -dir.y
		bounce.emit(dir.x)
	
func _get_h_dir() -> int:
	var h_dir: int = randi_range(0, 1)
	if h_dir == 0:
		h_dir = -1
	return h_dir

func _get_angle() -> float:
	var angle: float = cos(randf_range(PI/2, -PI))
	return cos(randf_range(PI/2, -PI))

func _move(delta: float) -> void:
	position += dir * CURRENT_SPEED * delta
	_check_for_collisions()

func _reset_ball():
	var screen_size = get_viewport_rect().size
	dir = Vector2.ZERO
	preset_direction()
	CURRENT_SPEED = BASE_SPEED
	position = screen_size / 2
	
	var serve_timer: Timer = Timer.new()
	add_child(serve_timer)
	serve_timer.start(RESERVE_TIME)
	await serve_timer.timeout
	serve_timer.queue_free()

func _score():
	score_event.emit(dir)
		
## Godot Functions

func _physics_process(delta: float) -> void:
	_move(delta)
	
func _ready():
	preset_direction()
