extends Camera2D
class_name CameraController

@export var follow_speed: float = 5.0
@export var vertical_offset: float = -150.0

var player: Node2D

func _ready():
	print("=== CAMERA DEBUG INICIANDO ===")
	
	# FORÇA o zoom para o valor correto, ignorando o Inspector
	self.zoom = Vector2.ONE # Vector2.ONE é o mesmo que Vector2(1.0, 1.0)
	print("Zoom da câmera forçado para: ", self.zoom)
	
	# Garante que esta câmera é a ativa
	add_to_group("camera")
	make_current()
	
	# Aguarda um frame para garantir que o player já existe
	await get_tree().process_frame
	find_player()
	
	print("Configuração da câmera finalizada.")

func find_player():
	print("Procurando pelo player...")
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("✅ Player encontrado: ", player.name)
		# Posiciona a câmera imediatamente no player ao iniciar
		self.global_position = player.global_position + Vector2(0, vertical_offset)
		print("✅ Câmera posicionada em: ", self.global_position)
	else:
		print("❌ ERRO: Player não encontrado no grupo 'player'!")

func _process(delta):
	if not player or not is_instance_valid(player):
		return # Não faz nada se não houver player
	
	# Calcula a posição alvo da câmera
	var target_position = Vector2(
		player.global_position.x,
		player.global_position.y + vertical_offset
	)
	
	# Move a câmera suavemente para a posição alvo
	global_position = global_position.lerp(target_position, follow_speed * delta)
