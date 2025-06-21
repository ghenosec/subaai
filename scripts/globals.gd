extends Node

var score: int = 0
var bananas: int = 0
var player_current_stamina: float = 100.0
var player_max_stamina: float = 100.0
var collected_item_ids: Array[String] = []
var current_level_scene_path: String = "res://scenes/Main.tscn"

const SAVE_FILE_PATH: String = "user://autosave.json"
const AUTOSAVE_INTERVAL: float = 15.0

var is_loading_from_save: bool = false
var loaded_save_data: Dictionary = {}
var autosave_timer: Timer

signal stats_updated

func _ready():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.one_shot = false
	autosave_timer.timeout.connect(save_game)
	add_child(autosave_timer)

func start_autosave():
	if autosave_timer.is_stopped():
		autosave_timer.start()

func stop_autosave():
	autosave_timer.stop()

func reset_for_new_game(
	start_level_path: String, initial_pos: Vector2, initial_max_stamina: float
):
	is_loading_from_save = false
	loaded_save_data = {}
	current_level_scene_path = start_level_path
	score = 0
	bananas = 0
	player_max_stamina = initial_max_stamina
	player_current_stamina = initial_max_stamina
	collected_item_ids.clear()
	if has_save_file():
		delete_save_file()

func save_game():
	var player_node = get_tree().get_first_node_in_group("player")
	var platform_manager = get_tree().get_first_node_in_group("platform_manager")
	if not player_node or not platform_manager:
		return

	var save_data: Dictionary = {
		"player_stats": {
			"position": player_node.global_position,
			"stamina": player_node.current_stamina,
			"max_stamina": player_node.max_stamina,
			"score": player_node.score,
			"bananas": bananas
		},
		"world_state": {
			"current_level": get_tree().current_scene.scene_file_path,
			"collected_items": collected_item_ids,
			"platforms": platform_manager.get_platforms_data()
		}
	}
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

func load_game():
	if not has_save_file():
		return false
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parse_result: Variant = JSON.parse_string(content)
		if parse_result:
			is_loading_from_save = true
			loaded_save_data = parse_result
			var world_data = loaded_save_data.get("world_state", {})
			current_level_scene_path = world_data.get(
				"current_level", "res://scenes/Main.tscn"
			)
			return true
	return false

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file():
	if has_save_file():
		DirAccess.open("user://").remove(SAVE_FILE_PATH.get_file())

func update_player_score(new_score: int):
	score = new_score
	stats_updated.emit()

func update_player_bananas(new_bananas_count: int):
	bananas = new_bananas_count
	stats_updated.emit()

func mark_item_as_collected(item_id: String):
	if not collected_item_ids.has(item_id):
		collected_item_ids.append(item_id)

func is_item_collected(item_id: String) -> bool:
	return collected_item_ids.has(item_id)
