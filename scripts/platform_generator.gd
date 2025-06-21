# platform_generator.gd (VERSÃO DE TESTE DA CÂMERA)
extends Node

@export var platform_scene: PackedScene
@export var player: CharacterBody2D

# Vamos gerar a primeira plataforma em uma posição fixa para o teste
var test_position = Vector2(960, 800) # Meio da tela, um pouco acima do jogador

func _ready():
	print("--- [TESTE DE CÂMERA] Iniciado.")
	
	if not platform_scene or not is_instance_valid(player):
		print("--- [ERRO] Player ou Platform Scene não definidos!")
		return

	print("--- [TESTE DE CÂMERA] Gerando uma única plataforma em: ", test_position)
	
	var platform = platform_scene.instantiate()
	get_parent().add_child(platform)
	platform.global_position = test_position
	
	print("--- [TESTE DE CÂMERA] Plataforma de teste criada.")
