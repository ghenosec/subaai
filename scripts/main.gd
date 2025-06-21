# LevelScript.gd (ou Main.gd, etc.)
extends Node2D

@export var default_player_start_position: Vector2 = Vector2(100, 100)
@onready var player: CharacterBody2D = get_node_or_null("Player") # Ajuste o caminho se necessário

func _ready() -> void:
	if not player:
		printerr("LevelScript: Nó Player não encontrado na cena! Verifique o caminho: Player")
		return

	var scene_path: String = get_tree().current_scene.scene_file_path
	print("LevelScript: _ready() para cena: ", scene_path)
	print("LevelScript: Globals.is_loading_from_save no início de _ready(): ", Globals.is_loading_from_save)

	Globals.update_current_level(scene_path) # Informa aos Globals qual é o nível atual

	if Globals.is_loading_from_save:
		print("LevelScript: Carregando jogo. Posição salva em Globals: ", Globals.player_runtime_position)
		player.global_position = Globals.player_runtime_position
		print("LevelScript: Posição do jogador restaurada para: ", player.global_position)
	else:
		# Novo jogo ou transição normal de nível (sem save/load direto)
		print("LevelScript: Novo jogo/nível. Posição padrão do nível: ", default_player_start_position)
		player.global_position = default_player_start_position
		Globals.update_player_position(player.global_position) # Atualiza Globals com a pos inicial
		print("LevelScript: Jogador posicionado em: ", player.global_position)
		print("LevelScript: Globals.player_runtime_position após setar pos inicial: ", Globals.player_runtime_position)

	# A flag is_loading_from_save é resetada por Globals._process no próximo frame.
	# Salva o estado ao entrar no nível (com a posição correta e o nível atualizado)
	print("LevelScript: Chamando Globals.save_game() no final de _ready().")
	Globals.save_game()
