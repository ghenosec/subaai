extends CharacterBody2D

const SPEED: float = 400.0
const JUMP_VELOCITY: float = -1100.0
const STAMINA_COST_PER_JUMP: float = 25.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var max_stamina: float = 100.0
var current_stamina: float

@onready var stamina_bar: ProgressBar = get_node_or_null(
	"../CanvasLayer/Estamina/StaminaBar"
)
@onready var score_label_hud: Label = get_node_or_null(
	"../CanvasLayer/HUD/Control/Container/ScoreLabel"
)
@onready var banana_label_hud: Label = get_node_or_null(
	"../CanvasLayer/Banana_counter"
)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var score: int = 0

func _ready() -> void:
	add_to_group("player")

	if Globals.is_loading_from_save:
		global_position = Globals.player_runtime_position
		current_stamina = Globals.player_current_stamina
		score = Globals.score
		Globals.is_loading_from_save = false
	else:
		current_stamina = max_stamina
		score = 0

	update_stamina_ui()
	update_score_ui()
	update_banana_ui()

	Globals.stats_updated.connect(update_score_ui)
	Globals.stats_updated.connect(update_banana_ui)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if current_stamina >= STAMINA_COST_PER_JUMP:
			velocity.y = JUMP_VELOCITY
			current_stamina -= STAMINA_COST_PER_JUMP
			update_stamina_ui()

	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation()
	move_and_slide()

func update_animation() -> void:
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

func restore_stamina(amount: float) -> void:
	current_stamina = min(current_stamina + amount, max_stamina)
	update_stamina_ui()

func add_score(value: int) -> void:
	score += value
	Globals.update_player_score(score)

func update_stamina_ui() -> void:
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina

func update_score_ui() -> void:
	if score_label_hud:
		score_label_hud.text = "Score: %d" % Globals.score

func update_banana_ui() -> void:
	if banana_label_hud:
		banana_label_hud.text = str("%04d" % Globals.bananas)
