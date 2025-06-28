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
const SPEED_IMPACT: float = 1.5

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
		## NOTE: This is totally broken if the AI paddle is on the left side, but not critical to
		## fix currently.
		
		# If it's moving our way...
		var ball_angle: float = atan2(ball.dir.y, ball.dir.x)
		
		# if ball_angle is negative, we're going upwards
		# if ball_angle is position, we're going downwards
		
		# Get distance to the ball for accuracy calculations
		var dist_to_ball = abs(position.x - ball.position.x)
		
		# The relative destination of the ball from its bounce
		var ball_y_dest_from_origin: float = tan(ball_angle) * dist_to_ball
		
		# The absolute destination of the ball
		var destination_y_absolute: float = ball.position.y + ball_y_dest_from_origin
		
		# Calculate the movement required by the paddle
		var accurate_movement = destination_y_absolute - position.y
		
		# Get the distance-based accuracy range for the margin of error
		var accuracy: float = clamp(dist_to_ball / MAX_ACCURACY_DISTANCE, 0.01, 1)
		var margin_of_error: float = 1 - accuracy
		
		# Speed of the ball is also a factor, multiplied by the SPEED_IMPACT to represent how much
		# of an impact speed has on its positional calculations.
		var upper_margin: float = 1 + (margin_of_error / 2) * (ball.speed_ratio * SPEED_IMPACT)
		var lower_margin: float = 1 - (margin_of_error / 2) * (ball.speed_ratio * SPEED_IMPACT)
		
		# The final movement prediction for the paddle!
		y_movement_required = randf_range(accurate_movement * lower_margin, accurate_movement * upper_margin)

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
