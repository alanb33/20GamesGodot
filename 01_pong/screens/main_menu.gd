extends Control

@onready var play_button: Button = $MenuPanel/VBoxContainer/PlayButton
@onready var exit_button: Button = $MenuPanel/VBoxContainer/ExitButton

const game_scene_filepath: String = "res://screens/game_screen.tscn"

var _fade_in: bool = false

func _do_game_transition():
	$MenuPanel.visible = false
	_fade_in = true

func _on_exit_button_pressed():
	get_tree().quit()
	
func _on_play_button_pressed():
	_do_game_transition()

func _link_buttons():
	exit_button.pressed.connect(_on_exit_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)

func _ready():
	_link_buttons()
	GameVars.goal_score = GameVars.base_goal_score
	
func _input(event: InputEvent):
	if Input.is_action_just_pressed("ui_accept"):
		_do_game_transition()

func _process(delta: float) -> void:
	if _fade_in:
		var fade: Panel = $BG/FadePanel
		fade.modulate.a -= delta
		if fade.modulate.a <= 0.0:
			get_tree().change_scene_to_file(game_scene_filepath)
