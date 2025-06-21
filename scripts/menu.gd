# MainMenu.gd
extends Control
class_name MainMenu

@onready var continue_button: Button = $ButtonsContainer/Continue
@onready var continue_button_shadow: Control = $ButtonsContainer/Continue/Shadow

func _ready() -> void:
	if Globals.has_save_file():
		continue_button.disabled = false
		if continue_button_shadow:
			continue_button_shadow.show()
	else:
		continue_button.disabled = true
		if continue_button_shadow:
			continue_button_shadow.hide()

	for button_node in get_tree().get_nodes_in_group("button"):
		if button_node is Button:
			var button: Button = button_node as Button
			button.pressed.connect(_on_button_pressed.bind(button))
		else:
			print("WARN: MainMenu - Node ", button_node.name, " in group 'button' is not a Button.")


func _on_button_pressed(button: Button) -> void:
	print("MainMenu: Botão '", button.name, "' pressionado.") # Adicionar print para debug
	match button.name:
		"NewGame":
			var start_level_path: String = "res://scenes/Main.tscn" # MUDE PARA SUA PRIMEIRA CENA
			var initial_player_pos: Vector2 = Vector2(100, 300)    # MUDE PARA A POSIÇÃO INICIAL
			var initial_max_stamina: float = 100.0
			
			Globals.reset_for_new_game(start_level_path, initial_player_pos, initial_max_stamina)
			print("MainMenu (NewGame): Globals resetado. Tentando mudar para cena: ", Globals.current_level_scene_path)
			var err_new_game: Error = get_tree().change_scene_to_file(Globals.current_level_scene_path)
			if err_new_game != OK:
				printerr("MainMenu (NewGame): Erro ao mudar de cena para '", Globals.current_level_scene_path, "': ", err_new_game)

		"Continue":
			print("MainMenu (Continue): Tentando carregar o jogo...")
			if Globals.load_game():
				print("MainMenu (Continue): Jogo carregado com sucesso. Tentando mudar para cena: ", Globals.current_level_scene_path)
				if ResourceLoader.exists(Globals.current_level_scene_path): # Verifica se o caminho da cena é válido
					var err_continue: Error = get_tree().change_scene_to_file(Globals.current_level_scene_path)
					if err_continue != OK:
						printerr("MainMenu (Continue): Erro ao mudar de cena para '", Globals.current_level_scene_path, "': ", err_continue)
				else:
					printerr("MainMenu (Continue): ERRO CRÍTICO - Caminho da cena salvo ('", Globals.current_level_scene_path, "') não existe ou é inválido!")
					# O que fazer aqui? Talvez deletar o save e desabilitar o botão?
					Globals.delete_save_file()
					continue_button.disabled = true
					if continue_button_shadow: continue_button_shadow.hide()
					# Poderia mostrar uma mensagem de erro para o usuário aqui
			else:
				printerr("MainMenu (Continue): Falha ao carregar o jogo (Globals.load_game() retornou false).")
				continue_button.disabled = true
				if continue_button_shadow:
					continue_button_shadow.hide()
				# Globals.delete_save_file() # Já é feito dentro de load_game se houver erro de parse ou dados faltando

		"Quit":
			get_tree().quit()
