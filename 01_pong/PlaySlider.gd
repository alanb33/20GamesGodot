extends HSlider

@export var text_label: Label

func _on_drag_ended(changed: bool):
	if changed:
		if text_label:
			text_label.text = "Play to %d" % value
			GameVars.goal_score = value

func _link_signals() -> void:
	drag_ended.connect(_on_drag_ended)

func _ready() -> void:
	_link_signals()
