# Globals.gd
extends Node

# --- Game State ---
var bananas: int = 0 # Contagem total de bananas coletadas
var score: int = 0
var current_level_scene_path: String = "res://scenes/Main.tscn"
var player_runtime_position: Vector2 = Vector2.ZERO
var player_current_stamina: float = 100.0
var player_max_stamina: float = 100.0
var collected_item_ids: Array[String] = [] # NOVO: Para rastrear IDs de itens coletados (como bananas)

const SAVE_FILE_PATH: String = "user://savegame.json"
var is_loading_from_save: bool = false
var _reset_loading_flag_next_frame: bool = false

signal player_stats_changed

func _process(_delta: float) -> void:
	if _reset_loading_flag_next_frame:
		is_loading_from_save = false
		_reset_loading_flag_next_frame = false
		# print("Globals: Flag 'is_loading_from_save' resetada para false.") # Descomente para debug

func reset_for_new_game(start_level_path: String, initial_pos: Vector2, initial_max_stamina: float) -> void:
	bananas = 0
	score = 0
	current_level_scene_path = start_level_path
	player_runtime_position = initial_pos
	player_max_stamina = initial_max_stamina
	player_current_stamina = player_max_stamina
	collected_item_ids.clear() # Limpa a lista de itens coletados
	is_loading_from_save = false
	_reset_loading_flag_next_frame = false
	print("Globals: Estado resetado para novo jogo.")
	save_game()

func save_game() -> void:
	var current_tree: SceneTree = get_tree()
	if current_tree and current_tree.current_scene: # Verifica se current_scene não é null
		# Tenta encontrar o jogador pelo grupo, que é mais robusto que um caminho fixo
		var players_in_scene: Array = current_tree.get_nodes_in_group("player")
		if not players_in_scene.is_empty():
			var player_node: Node2D = players_in_scene[0] as Node2D # Pega o primeiro jogador encontrado
			if player_node and player_node.has_method("get_global_position"): # Node2D tem get_global_position
				player_runtime_position = player_node.get_global_position()
				print("Globals.save_game(): Posição do jogador atualizada de player_node para: ", player_runtime_position)	

	var save_data: Dictionary = {
		"bananas": bananas,
		"score": score,
		"current_level_scene_path": current_level_scene_path,
		"player_runtime_position_x": player_runtime_position.x,
		"player_runtime_position_y": player_runtime_position.y,
		"player_current_stamina": player_current_stamina,
		"player_max_stamina": player_max_stamina,
		"collected_item_ids": collected_item_ids, # Salva os IDs dos itens
	}

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string: String = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Globals: Jogo salvo. Posição: ", player_runtime_position, " Itens Coletados: ", collected_item_ids.size())
	else:
		printerr("Globals: Erro ao salvar o jogo! Não foi possível abrir o arquivo: ", SAVE_FILE_PATH)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		printerr("Globals: Nenhum arquivo de save encontrado.")
		return false

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()

		var parse_result: Variant = JSON.parse_string(json_string)
		if parse_result == null:
			printerr("Globals: Erro ao parsear o arquivo de save JSON.")
			delete_save_file()
			return false

		var data: Dictionary = parse_result as Dictionary

		if not (data.has("bananas") and data.has("score") and \
				data.has("current_level_scene_path") and \
				data.has("player_runtime_position_x") and \
				data.has("player_runtime_position_y") and \
				data.has("player_current_stamina") and \
				data.has("player_max_stamina")):
			printerr("Globals: Arquivo de save está com dados faltando.")
			delete_save_file()
			return false

		bananas = data["bananas"]
		score = data["score"]
		current_level_scene_path = data["current_level_scene_path"]
		player_runtime_position = Vector2(data["player_runtime_position_x"], data["player_runtime_position_y"])
		player_current_stamina = data["player_current_stamina"]
		player_max_stamina = data["player_max_stamina"]
		
		# Carrega IDs de itens coletados, se existirem no save
		if data.has("collected_item_ids"):
			var loaded_ids_generic: Array = data["collected_item_ids"] as Array # Carrega como Array genérico
			collected_item_ids.clear() # Limpa o array tipado existente
			for item_id_variant in loaded_ids_generic:
				if item_id_variant is String: # Verifica se cada item é uma String
					collected_item_ids.append(item_id_variant as String)
				else:
					printerr("Globals: Item não string encontrado em collected_item_ids no save: ", item_id_variant)
		else:
			collected_item_ids.clear()

		is_loading_from_save = true
		_reset_loading_flag_next_frame = true
		print("Globals: Jogo carregado. Posição: ", player_runtime_position, " Itens Coletados: ", collected_item_ids.size())
		return true
	else:
		printerr("Globals: Erro ao carregar o jogo!")
		return false

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file() -> void:
	if has_save_file():
		var dir: DirAccess = DirAccess.open("user://")
		if dir:
			var err: Error = dir.remove(SAVE_FILE_PATH.get_file())
			if err == OK: print("Globals: Arquivo de save deletado.")
			else: printerr("Globals: Erro ao deletar arquivo de save: ", err)
		else: printerr("Globals: Não foi possível acessar 'user://' para deletar.")

func update_player_score(new_score: int) -> void:
	score = new_score
	player_stats_changed.emit()
	save_game()

func update_player_bananas(new_bananas_count: int) -> void:
	bananas = new_bananas_count # Isso é a contagem total
	player_stats_changed.emit()
	save_game() # Salva quando a contagem de bananas muda

func update_player_stamina(current_stam: float, max_stam: float) -> void:
	player_current_stamina = current_stam
	player_max_stamina = max_stam
	# Não salvar aqui para evitar saves excessivos, Player.restore_stamina já salva.

func update_player_position(pos: Vector2) -> void:
	if player_runtime_position != pos:
		player_runtime_position = pos
		# Não salvar a cada frame. Salvar em pontos chave ou ao sair.
		# print("Globals: Posição do jogador atualizada para: ", player_runtime_position)

func update_current_level(scene_path: String) -> void:
	if current_level_scene_path != scene_path:
		current_level_scene_path = scene_path
		# save_game() # Salvar ao mudar de nível é uma boa ideia, mas LevelScript já faz isso no _ready

# --- Funções para itens coletáveis ---
func mark_item_as_collected(item_id: String) -> void:
	if not collected_item_ids.has(item_id):
		collected_item_ids.append(item_id)
		print("Globals: Item '", item_id, "' marcado como coletado.")
		# O save_game() geralmente é chamado pela ação que coleta o item (ex: update_player_bananas)
		# Se não for, chame save_game() aqui.

func is_item_collected(item_id: String) -> bool:
	return collected_item_ids.has(item_id)
