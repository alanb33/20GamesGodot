class_name GameScreen
extends Node2D

@onready var particle_scene: PackedScene = preload("res://scenes/FurShredderParticles.tscn")

@onready var countdown: CountdownLabel = $CanvasLayer/CountdownLabel
@onready var ball: Ball = $Ball

@onready var paddle_left: Paddle = $PaddleLeft
@onready var paddle_right: Paddle = $PaddleRight

enum Side {
	LEFT,
	RIGHT
}

var scores = {
	Side.LEFT: 0,
	Side.RIGHT: 0
}

const WINNING_SCORE = 5

## Private Functions

func _increase_score(side: GameScreen.Side):
	scores[side] += 1
	
func _is_game_over():
	for side in scores:
		if scores[side] >= WINNING_SCORE:
			match side:
				Side.LEFT:
					print("The home team wins!!")
				Side.RIGHT:
					print("The visitor team wins!!")
			return true
	return false

func _on_ball_score_event(ball_dir: Vector2):
	if ball_dir.x < 0:
		_increase_score(Side.LEFT)
	else:
		_increase_score(Side.RIGHT)
	if not _is_game_over():
		countdown.do_countdown(1)
		
	var particles: CPUParticles2D = particle_scene.instantiate()
	add_child(particles)
	particles.position = ball.position
	if ball_dir.x < 0:
		particles.look_at(paddle_right.position)
	else:
		particles.look_at(paddle_left.position)
	particles.emitting = true
	particles.one_shot = true
	
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()
	

func _on_countdown_finished():
	ball.serve_ball()

## Godot Functions

func _ready():
	ball.score_event.connect(_on_ball_score_event)
	countdown.countdown_finished.connect(_on_countdown_finished)
	
func _input(event: InputEvent):
	if Input.is_action_just_pressed("ui_end"):
		countdown.do_countdown(3)
