extends Node2D
class_name InfiniteBackground

@export var background_texture: Texture2D

var camera: Camera2D
var tile_size: Vector2
var tiles: Array[Sprite2D] = []

func _ready():
	print("--- BACKGROUND INFINITO INICIANDO ---")
	if not background_texture:
		print("❌ ERRO: Arraste a textura do background no Inspector!")
		return

	tile_size = background_texture.get_size()
	print("Tamanho do tile detectado: ", tile_size)

	await get_tree().process_frame
	find_camera()
	create_tile_grid()

func find_camera():
	var cameras_in_group = get_tree().get_nodes_in_group("camera")
	if not cameras_in_group.is_empty():
		camera = cameras_in_group[0]
		print("✅ Câmera encontrada: ", camera.name)
	else:
		print("❌ Câmera não encontrada no grupo 'camera'.")

func create_tile_grid():
	for y in range(-1, 2): # -1, 0, 1
		for x in range(-1, 2): # -1, 0, 1
			var tile = Sprite2D.new()
			tile.texture = background_texture
			tile.position = Vector2(x * tile_size.x, y * tile_size.y)
			tile.centered = true
			add_child(tile)
			tiles.append(tile)
	print("✅ Grid de 3x3 tiles criado.")

func _process(_delta):
	if not camera:
		return

	var camera_pos = camera.global_position

	for tile in tiles:
		var distance_to_camera = tile.global_position - camera_pos

		if distance_to_camera.x < -tile_size.x * 1.5:
			tile.position.x += tile_size.x * 3

		elif distance_to_camera.x > tile_size.x * 1.5:
			tile.position.x -= tile_size.x * 3

		if distance_to_camera.y < -tile_size.y * 1.5:
			tile.position.y += tile_size.y * 3

		elif distance_to_camera.y > tile_size.y * 1.5:
			tile.position.y -= tile_size.y * 3
