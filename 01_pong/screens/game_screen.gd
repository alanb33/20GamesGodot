class_name GameScreen
extends Node2D

@onready var particle_scene: PackedScene = preload("res://scenes/FurShredderParticles.tscn")

@onready var countdown: CountdownLabel = $CanvasLayer/CountdownLabel
@onready var ball: Ball = $Ball

@onready var paddle_left: Paddle = $PaddleLeft
@onready var paddle_right: Paddle = $PaddleRight

@onready var score_left: ScoreLabel = $CanvasLayer/ScoreLeft
@onready var score_right: ScoreLabel = $CanvasLayer/ScoreRight
@onready var score_element: Dictionary = {
	Side.LEFT: score_left,
	Side.RIGHT: score_right
}

enum Side {
	LEFT,
	RIGHT
}

var scores = {
	Side.LEFT: 0,
	Side.RIGHT: 0
}

var _game_over: bool = false

## Private Functions

func _do_play_again_transition():
	pass

func _increase_score(side: GameScreen.Side):
	var scoring_side: GameScreen.Side = Side.LEFT
	if side == Side.LEFT:
		scoring_side = Side.RIGHT
		
	scores[scoring_side] += 1
	score_element[scoring_side].set_score(scores[scoring_side])
	
func _is_game_over():
	for side in scores:
		if scores[side] >= GameVars.goal_score:
			match side:
				Side.LEFT:
					_win_game(Side.LEFT)
				Side.RIGHT:
					_win_game(Side.RIGHT)
			return true
	return false

func _on_ball_score_event(ball_dir: Vector2):
	if ball_dir.x < 0:
		_increase_score(Side.LEFT)
	else:
		_increase_score(Side.RIGHT)
		
	if not _is_game_over():
		print("Game is not over")
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
	
func _win_game(winner: GameScreen.Side):
	var winner_string: String = ""
	match winner:
		Side.LEFT:
			winner_string = "Home"
		Side.RIGHT:
			winner_string = "Visitor"
	print("%s Team wins!!" % winner_string)
	_do_play_again_transition()

## Godot Functions

func _ready():
	ball.score_event.connect(_on_ball_score_event)
	countdown.countdown_finished.connect(_on_countdown_finished)
	
	countdown.do_countdown(3)
