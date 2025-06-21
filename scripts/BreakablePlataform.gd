extends StaticBody2D

@export var break_delay: float = 1.5
@export var shake_intensity: float = 4.0

var is_breakable: bool = false
var is_breaking: bool = false

var player_ref: CharacterBody2D = null
var player_is_in_trigger_zone: bool = false

@onready var timer: Timer = $BreakTimer
@onready var top_checker: Area2D = $TopCheckerArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if top_checker:
		top_checker.body_entered.connect(_on_player_entered_trigger)
		top_checker.body_exited.connect(_on_player_exited_trigger)
	else:
		print("❌ ERRO: Nó 'TopCheckerArea' não encontrado!")

	if timer:
		timer.timeout.connect(_on_timer_timeout)
	else:
		print("❌ ERRO: Nó 'BreakTimer' não encontrado!")

func _on_player_entered_trigger(body):
	if body.is_in_group("player"):
		player_ref = body
		player_is_in_trigger_zone = true

func _on_player_exited_trigger(body):
	if body.is_in_group("player"):
		player_ref = null
		player_is_in_trigger_zone = false

func _physics_process(_delta):
	if is_breaking or not is_breakable:
		return

	if player_is_in_trigger_zone and player_ref and player_ref.is_on_floor():
		start_breaking_sequence()

func start_breaking_sequence():
	print("Player ATERRISSOU em plataforma quebrável! Iniciando timer.")
	is_breaking = true
	if timer:
		timer.start(break_delay)
	shake_animation()

func _on_timer_timeout():
	print("Plataforma quebrou!")
	queue_free() 

func setup_as_breakable():
	is_breakable = true
	if sprite:
		sprite.modulate = Color(1.0, 0.8, 0.8)

func shake_animation():
	if not sprite: return
	var tween = create_tween().set_loops()
	var original_pos = sprite.position
	tween.tween_property(
		sprite, "position", original_pos + Vector2(shake_intensity, 0), 0.05
	)
	tween.tween_property(
		sprite, "position", original_pos - Vector2(shake_intensity, 0), 0.05
	)
	
func is_platform_breakable() -> bool:
	return is_breakable
