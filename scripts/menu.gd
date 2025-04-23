extends Control
class_name MainMenu


var _has_save: bool = false 
var audio_click: AudioStreamPlayer2D

func _ready() -> void:
	if _has_save == false:
		$ButtonsContainer/Continue.disabled = true
		$ButtonsContainer/Continue/Shadow.hide()

	

	for _button in get_tree().get_nodes_in_group("button"):
		_button.pressed.connect(_on_button_pressed.bind(_button))

func _on_button_pressed(_button: Button) -> void:
	match _button.name:
		"NewGame":
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
		"Continue":
			get_tree().change_scene_to_file("res://scenes/level_loaded.tscn")
		"Quit":
			get_tree().quit()
