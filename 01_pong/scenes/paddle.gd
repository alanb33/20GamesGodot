class_name Paddle
extends Area2D

var _moving: bool = false

@onready var half_size: Vector2 = $Sprite2D.texture.get_size() / 2
const MOVE_SPEED: float = 500.0

@export var player_controlled: bool = false
@export var ball: Ball = null
const _deviation: float = 0.1

enum Side {
	LEFT,
	RIGHT
}

@export var side: Paddle.Side

# CPU-related movement predictions for imperfect guesses
var y_movement_required: float = 0.0
const y_buffer: float = 5.0
const MAX_ACCURACY_DISTANCE: float = 1000.0
const SPEED_IMPACT: float = 2.0
const SPEED_IMPACT_CUSHION: float = 1.25

func _handle_paddle_movement(delta: float) -> void:
	if player_controlled:
		_handle_player_movement(delta)
	else:
		_handle_cpu_movement(delta)
	
	_clamp_y_position()
		
func _clamp_y_position():
	var viewport_h = get_viewport_rect().size.y
	position.y = clamp(position.y, 0 + half_size.y, viewport_h - half_size.y)
		
func _handle_cpu_movement(delta: float) -> void:
	assert(ball != null, "CPU movement called but no ball assigned")
	
	# If the ball is headed our way...
	# If we're above the destination
	if (y_movement_required < -y_buffer || y_movement_required > y_buffer):
		var movement = MOVE_SPEED * delta
		var y_dir = y_movement_required / abs(y_movement_required)
		position.y += y_dir * movement
		if y_movement_required < 0:
			y_movement_required += movement
		else:
			y_movement_required -= movement
		
	
func _handle_player_movement(delta: float) -> void:
	var dir = Input.get_axis("move_paddle_up", "move_paddle_down")
	position.y += dir * MOVE_SPEED * delta

func _on_ball_bounce(new_ball_dir: float):
	if (new_ball_dir > 0 && side == Side.RIGHT) || (new_ball_dir < 0 && side == Side.LEFT):
		# Calculate accurate ball destination
		var ball_angle: float = atan2(ball.dir.y, ball.dir.x)
		var dist_to_ball = abs(position.x - ball.position.x)
		var ball_y_dest_from_origin: float = tan(ball_angle) * dist_to_ball
		
		# Reverse the Y calculation so a left-side paddle works
		if side == Side.LEFT:
			ball_y_dest_from_origin = -ball_y_dest_from_origin
		
		var destination_y_absolute: float = ball.position.y + ball_y_dest_from_origin
		var accurate_movement = destination_y_absolute - position.y
		
		# Calculate margin of error based on distance and speed
		var accuracy: float = clamp(dist_to_ball / MAX_ACCURACY_DISTANCE, 0.01, 1)
		var base_margin: float = (1 - accuracy) / 2
		var speed_factor: float = ball.speed_ratio * SPEED_IMPACT
		speed_factor = 1.0 if ball.speed_ratio <= SPEED_IMPACT_CUSHION else speed_factor
		var error_range: float = base_margin * speed_factor
		
		# Apply randomized error to movement prediction
		y_movement_required = accurate_movement * randf_range(
			1 - error_range, 
			1 + error_range
		)

func _on_body_entered(other: Node2D):
	if other is Ball:
		other.paddle_bounce(position, half_size)

## Godot Functions

func _physics_process(delta: float) -> void:
	_handle_paddle_movement(delta)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if not player_controlled:
		assert(ball, "Ball is not assigned to CPU-controlled paddle")
		ball.bounce.connect(_on_ball_bounce)
