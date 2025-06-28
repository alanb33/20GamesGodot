class_name PlayAgainScreen
extends CanvasLayer

var _fading_in: bool = false

@onready var win_string_label: Label = $Control/MenuPanel/VBoxContainer/Label
@onready var rematch_button: Button = $Control/MenuPanel/VBoxContainer/RematchButton
@onready var main_menu_button: Button = $Control/MenuPanel/VBoxContainer/MainMenuButton
@onready var exit_button: Button = $Control/MenuPanel/VBoxContainer/ExitButton
@onready var master_node: Control = $Control

var main_menu_scene_filepath: String = "res://screens/main_menu.tscn"

signal do_rematch

## Public Functions

func do_transition(win_string: String) -> void:
	master_node.set_process(true)
	master_node.visible = true
	win_string_label.text = win_string
	_fading_in = true
	
## Private Functions

func _link_buttons() -> void:
	rematch_button.pressed.connect(_on_rematch_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_rematch_button_pressed() -> void:
	do_rematch.emit()
	master_node.modulate.a = 0.0
	master_node.set_process(false)
	
func _on_main_menu_button_pressed() -> void:
	print("mm butt pressed")
	var error = get_tree().change_scene_to_file(main_menu_scene_filepath)
	if error:
		print(error)
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
## Godot Functions

func _process(delta: float) -> void:
	if _fading_in:
		master_node.modulate.a += delta
		if master_node.modulate.a >= 1.0:
			master_node.modulate.a = 1.0
			_fading_in = false
	
func _ready() -> void:
	master_node.set_process(false)
	master_node.visible = false
	_link_buttons()
