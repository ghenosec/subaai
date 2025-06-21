# smooth_camera_up.gd
extends Camera2D

# Arraste o nó do Player para cá
@export var target: Node2D

# Guarda a maior altura que o jogador já alcançou
var max_y: float = INF # Começa com infinito

func _ready():
	if target:
		# Define a posição inicial da câmera e a altura máxima
		global_position = target.global_position
		max_y = target.global_position.y


func _process(_delta):
	if not target:
		return

	# A posição Y diminui conforme subimos
	if target.global_position.y < max_y:
		max_y = target.global_position.y

	# A câmera segue o jogador no eixo X, mas só sobe no eixo Y
	global_position.x = target.global_position.x
	global_position.y = max_y
