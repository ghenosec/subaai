extends Node2D
class_name PlatformManager

@export var platform_scene: PackedScene = preload(
	"res://scenes/tronco_plataform.tscn"
)
@export var banana_scene: PackedScene = preload("res://scenes/banana.tscn")

@export_category("Geração de Fileiras")
@export var min_platforms_per_row: int = 2
@export var max_platforms_per_row: int = 3
@export var row_vertical_spacing: float = 280.0
@export var row_vertical_variance: float = 25.0
@export var horizontal_padding: float = 150.0

@export_category("Parâmetros Gerais")
@export var screen_width: float = 1152.0
@export var generation_distance: float = 1500.0
@export var cleanup_distance_below_camera: float = 2000.0
@export var banana_spawn_chance: float = 0.25
@export var breakable_platform_chance: float = 0.25

var platforms: Array[Node2D] = []
var bananas: Array[Node2D] = []
var last_row_y: float = 0.0
var player: Node2D
var camera: Camera2D

func _ready():
	await get_tree().process_frame
	find_player()
	find_camera()

	# MUDANÇA CRÍTICA: Decide se gera um novo mundo ou carrega um existente
	if Globals.is_loading_from_save:
		recreate_world_from_save()
	else:
		generate_initial_platforms()

func find_player():
	player = get_tree().get_first_node_in_group("player")
	if player and not Globals.is_loading_from_save:
		last_row_y = player.global_position.y

func find_camera():
	camera = get_tree().get_first_node_in_group("camera")

func _process(_delta):
	if not player:
		return
	generate_platforms_ahead()
	cleanup_old_platforms()

# --- NOVAS FUNÇÕES DE SAVE/LOAD ---

# Coleta os dados de todas as plataformas ativas
func get_platforms_data() -> Array:
	var data_array: Array = []
	for platform in platforms:
		if is_instance_valid(platform):
			var platform_data = {
				"position": platform.global_position,
				"scale": platform.scale,
				"is_breakable": platform.is_platform_breakable()
			}
			data_array.append(platform_data)
	return data_array

# Recria o mundo a partir dos dados salvos
func recreate_world_from_save():
	print("Recriando mundo a partir do save...")
	var world_data = Globals.loaded_save_data.get("world_state", {})
	var platform_data_array = world_data.get("platforms", [])

	if platform_data_array.is_empty():
		print("Nenhum dado de plataforma no save. Gerando mundo inicial.")
		generate_initial_platforms()
		return

	var highest_platform_y = 10000.0 # Um valor inicial alto

	for platform_data in platform_data_array:
		var platform = platform_scene.instantiate()
		platform.global_position = platform_data["position"]
		platform.scale = platform_data["scale"]
		if platform_data["is_breakable"]:
			platform.setup_as_breakable()
		
		add_child(platform)
		platforms.append(platform)

		# Encontra a plataforma mais alta para continuar a geração a partir dela
		if platform.global_position.y < highest_platform_y:
			highest_platform_y = platform.global_position.y
	
	# Define a altura da última fileira para que a geração continue corretamente
	last_row_y = highest_platform_y
	print("Mundo recriado com ", platforms.size(), " plataformas.")

# --- O RESTO DO SCRIPT CONTINUA O MESMO ---

func generate_initial_platforms():
	for i in range(10):
		create_platform_row()

func generate_platforms_ahead():
	if last_row_y - player.global_position.y < generation_distance:
		create_platform_row()

func create_platform_row():
	var spacing = row_vertical_spacing + randf_range(
		-row_vertical_variance,
		row_vertical_variance
	)
	var row_y = last_row_y - spacing
	var num_platforms = randi_range(min_platforms_per_row, max_platforms_per_row)
	var available_width = screen_width - (2 * horizontal_padding)
	var zone_width = available_width / num_platforms

	for i in range(num_platforms):
		var platform = platform_scene.instantiate()
		if not platform:
			continue
		var zone_start_x = horizontal_padding + (i * zone_width)
		var zone_end_x = zone_start_x + zone_width
		var x_pos = randf_range(zone_start_x, zone_end_x)
		var y_pos = row_y + randf_range(-15.0, 15.0)
		platform.global_position = Vector2(x_pos, y_pos)
		platform.scale = Vector2(1.4, 1.0)
		add_child(platform)
		platforms.append(platform)
		if randf() < breakable_platform_chance:
			platform.setup_as_breakable()
		if randf() < banana_spawn_chance:
			create_banana_on_platform(platform)
	last_row_y = row_y

func create_banana_on_platform(platform: Node2D):
	if not banana_scene or not is_instance_valid(platform):
		return
	var banana = banana_scene.instantiate()
	if not banana:
		return
	var banana_name = "Banana_" + str(platforms.size()) + "_" + str(randi() % 1000)
	banana.name = banana_name
	var banana_y_offset = -60.0
	banana.global_position = Vector2(
		platform.global_position.x,
		platform.global_position.y + banana_y_offset
	)
	add_child(banana)
	bananas.append(banana)

func cleanup_old_platforms():
	if not camera:
		return
	var cleanup_line_y = camera.global_position.y + cleanup_distance_below_camera
	for i in range(platforms.size() - 1, -1, -1):
		var platform = platforms[i]
		if is_instance_valid(platform) and platform.global_position.y > cleanup_line_y:
			platforms.remove_at(i)
			platform.queue_free()
	for i in range(bananas.size() - 1, -1, -1):
		var banana = bananas[i]
		if is_instance_valid(banana) and banana.global_position.y > cleanup_line_y:
			bananas.remove_at(i)
			banana.queue_free()

func remove_banana(banana: Node2D):
	var index = bananas.find(banana)
	if index != -1:
		bananas.remove_at(index)
		banana.queue_free()
