class_name Paddle
extends Area2D

var _moving: bool = false

@onready var half_size: Vector2 = $Sprite2D.texture.get_size() / 2
const MOVE_SPEED: float = 500.0

@export var player_controlled: bool = false

func _handle_paddle_movement(delta: float) -> void:
	if player_controlled:
		var dir = Input.get_axis("move_paddle_up", "move_paddle_down")
		position.y += dir * MOVE_SPEED * delta
		var viewport_h = get_viewport_rect().size.y
		position.y = clamp(position.y, 0 + half_size.y, viewport_h - half_size.y)

func _on_body_entered(other: Node2D):
	if other is Ball:
		print("Detected ball entry, bouncing")
		other.paddle_bounce(position, half_size)

## Godot Functions

func _physics_process(delta: float) -> void:
	_handle_paddle_movement(delta)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
