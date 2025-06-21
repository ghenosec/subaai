extends Node2D
class_name PlatformManager

@export var platform_scene: PackedScene = preload(
	"res://scenes/tronco_plataform.tscn"
)
@export var banana_scene: PackedScene = preload("res://scenes/banana.tscn")

# --- NOVOS PARÂMETROS ---
@export_category("Geração de Fileiras")
@export var min_platforms_per_row: int = 2
@export var max_platforms_per_row: int = 3
@export var row_vertical_spacing: float = 280.0
@export var row_vertical_variance: float = 25.0
@export var horizontal_padding: float = 100.0
# MUDANÇA: Distância mínima entre plataformas na mesma fileira
@export var min_horizontal_distance_in_row: float = 150.0

# --- PARÂMETROS AJUSTADOS ---
@export_category("Parâmetros Gerais")
@export var screen_width: float = 1152.0
@export var generation_distance: float = 1500.0
@export var cleanup_distance_below_camera: float = 2000.0
# MUDANÇA: Menos bananas
@export var banana_spawn_chance: float = 0.30 # 30% de chance
# MUDANÇA: Chance de uma plataforma ser quebrável
@export var breakable_platform_chance: float = 0.25 # 25% de chance

var platforms: Array[Node2D] = []
var bananas: Array[Node2D] = []
var last_row_y: float = 0.0
var player: Node2D
var camera: Camera2D

func _ready():
	await get_tree().process_frame
	find_player()
	find_camera()
	generate_initial_platforms()

func find_player():
	player = get_tree().get_first_node_in_group("player")
	if player:
		last_row_y = player.global_position.y

func find_camera():
	camera = get_tree().get_first_node_in_group("camera")

func _process(_delta):
	if not player:
		return
	generate_platforms_ahead()
	cleanup_old_platforms()

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
	
	# MUDANÇA: Guarda as posições X para evitar sobreposição
	var row_x_positions: Array[float] = []

	for i in range(num_platforms):
		var platform = platform_scene.instantiate()
		if not platform:
			continue

		var x_pos: float
		var position_ok = false
		var attempts = 0
		
		# Tenta encontrar uma posição X que não esteja muito perto de outras
		while not position_ok and attempts < 10:
			attempts += 1
			position_ok = true
			# Gera uma posição X aleatória na tela
			x_pos = randf_range(horizontal_padding, available_width)
			# Verifica se está muito perto de outras plataformas já criadas NESTA fileira
			for existing_x in row_x_positions:
				if abs(x_pos - existing_x) < min_horizontal_distance_in_row:
					position_ok = false
					break
		
		# Se encontrou uma boa posição, cria a plataforma
		if position_ok:
			row_x_positions.append(x_pos)
			var y_pos = row_y + randf_range(-10.0, 10.0)
			platform.global_position = Vector2(x_pos, y_pos)
			platform.scale = Vector2(1.4, 1.0)
			add_child(platform)
			platforms.append(platform)

			# MUDANÇA: Decide se a plataforma será quebrável
			if randf() < breakable_platform_chance:
				platform.setup_as_breakable()

			if randf() < banana_spawn_chance:
				create_banana_on_platform(platform)

	last_row_y = row_y

# O resto do script (create_banana, cleanup, etc.) continua o mesmo
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
