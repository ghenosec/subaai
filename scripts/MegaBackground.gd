extends Node2D
class_name MegaBackground

@export var background_texture: Texture2D
@export var parallax_factor: float = 0.8 

var camera: Camera2D
var initial_position: Vector2

func _ready():
	print("=== MEGA BACKGROUND INICIANDO (VERSÃO SIMPLES) ===")
	
	if not background_texture:
		print("❌ ERRO: Arraste a textura BG.png no Inspector!")
		return
	
	var sprite = Sprite2D.new()
	sprite.texture = background_texture
	sprite.centered = true
	add_child(sprite)
	
	await get_tree().process_frame
	find_camera()
	
	if camera:
		initial_position = global_position - (camera.global_position * parallax_factor)

func find_camera():
	var cameras_in_group = get_tree().get_nodes_in_group("camera")
	if not cameras_in_group.is_empty():
		camera = cameras_in_group[0]
		print("✅ Câmera encontrada: ", camera.name)
	else:
		print("❌ Câmera não encontrada no grupo 'camera'.")

func _process(_delta):
	if not camera:
		return
	
	global_position = initial_position + (camera.global_position * parallax_factor)
