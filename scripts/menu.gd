extends Control
class_name MainMenu

@onready var continue_button: Button = $ButtonsContainer/Continue
@onready var continue_button_shadow: Control = $ButtonsContainer/Continue/Shadow
@onready var new_game_button: Button = $ButtonsContainer/NewGame
@onready var quit_button: Button = $ButtonsContainer/Quit

const GAME_SCENE_PATH: String = "res://scenes/Main.tscn"

func _ready() -> void:
	continue_button.disabled = not Globals.has_save_file()
	if continue_button_shadow:
		continue_button_shadow.visible = not continue_button.disabled

	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
	var initial_player_pos: Vector2 = Vector2(576, 500)
	var initial_max_stamina: float = 100.0
	Globals.reset_for_new_game(
		GAME_SCENE_PATH, initial_player_pos, initial_max_stamina
	)
	get_tree().change_scene_to_file(Globals.current_level_scene_path)

func _on_continue_pressed() -> void:
	if Globals.load_game():
		if ResourceLoader.exists(Globals.current_level_scene_path):
			get_tree().change_scene_to_file(Globals.current_level_scene_path)
		else:
			Globals.delete_save_file()
			continue_button.disabled = true
			if continue_button_shadow:
				continue_button_shadow.hide()
	else:
		continue_button.disabled = true
		if continue_button_shadow:
			continue_button_shadow.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
