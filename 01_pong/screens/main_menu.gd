extends Control

@onready var play_button: Button = $MenuPanel/VBoxContainer/PlayButton
@onready var exit_button: Button = $MenuPanel/VBoxContainer/ExitButton

const game_scene: PackedScene = preload("res://screens/game_screen.tscn")

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

func _process(delta: float) -> void:
	if _fade_in:
		var fade: Panel = $BG/FadePanel
		fade.modulate.a -= delta
		if fade.modulate.a <= 0.0:
			get_tree().change_scene_to_packed(game_scene)
