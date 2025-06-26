extends Control
class_name MainMenu

var _has_save: bool = false 

func _ready() -> void:
	if _has_save == false:
		$ButtonsContainer/Continue.disabled = true
		$ButtonsContainer/Continue/Shadow.hide()

	for _button in get_tree().get_nodes_in_group("button"):
		_button.pressed.connect(_on_button_pressed.bind(_button))

func _on_button_pressed(_button: Button) -> void:
	match _button.name:
		"NewGame":
			get_tree().change_scene_to_file("res://scenes/Level.tscn")
		"Continue":
			get_tree().change_scene_to_file("res://scenes/level_loaded.tscn")
		"Options":
			get_tree().change.scene_to_file("res://scenes/options.tscn")
