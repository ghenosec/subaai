extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const STAMINA_COST_PER_JUMP = 25.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina

@onready var stamina_bar = get_node_or_null("../Estamina/StaminaBar") # Ajuste este caminho se necessário
@onready var score_label = get_node_or_null("../HUD/Control/Container/Banana_Container") # Ajuste este caminho se necessário
@onready var animated_sprite = $AnimatedSprite2D 

var score = 0

func _ready():
	add_to_group("player")
	current_stamina = max_stamina
	if not stamina_bar:
		print("ERRO: StaminaBar não encontrada! Verifique o caminho em Player.gd.")
	if not score_label:
		print("WARN: ScoreLabel node not found. Check path in Player.gd")
	if not animated_sprite:
		print("WARN: AnimatedSprite2D node not found in Player scene.")

	update_stamina_ui()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if current_stamina >= STAMINA_COST_PER_JUMP:
			velocity.y = JUMP_VELOCITY
			current_stamina -= STAMINA_COST_PER_JUMP
			update_stamina_ui()
		else:
			pass

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation()
	move_and_slide()

func update_animation():
	if not animated_sprite:
		return

	if is_on_floor():
		if abs(velocity.x) > 5.0:
			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
			animated_sprite.flip_h = velocity.x < 0
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")


func restore_stamina(amount: float):
	current_stamina = min(current_stamina + amount, max_stamina)
	update_stamina_ui()

func add_score(value: int) -> void:
	score += value
	print("Score atual:", score)

func update_stamina_ui():
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina
