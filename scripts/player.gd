# Player.gd
extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -500.0
const STAMINA_COST_PER_JUMP: float = 25.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var max_stamina: float = 100.0 
var current_stamina: float 

@onready var stamina_bar: ProgressBar = get_node_or_null("../Estamina/StaminaBar")
@onready var score_label_hud: Label = get_node_or_null("../HUD/Control/Container/ScoreLabel") 
@onready var banana_label_hud: Label = get_node_or_null("../StaticBody2D/Banana_counter")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var score: int = 0

func _ready() -> void:
	add_to_group("player")
	print("Player: _ready() chamado.")
	print("Player: Globals.is_loading_from_save no início de _ready(): ", Globals.is_loading_from_save)
	print("Player: Globals.score antes de carregar/inicializar: ", Globals.score)
	print("Player: Globals.player_current_stamina antes de carregar/inicializar: ", Globals.player_current_stamina)

	if Globals.is_loading_from_save:
		max_stamina = Globals.player_max_stamina
		current_stamina = Globals.player_current_stamina
		score = Globals.score
		print("Player: Estado carregado do save. Stamina: ", current_stamina, "/", max_stamina, " Score: ", score)
		print("Player: Estado carregado do save.")
	else:
		current_stamina = max_stamina 
		score = Globals.score 
		Globals.player_max_stamina = max_stamina
		Globals.player_current_stamina = current_stamina
		print("Player: Estado inicializado para novo jogo/nível.")

	if not stamina_bar:
		print("ERRO: Player - StaminaBar não encontrada! Verifique o caminho.")
	if not score_label_hud:
		print("WARN: Player - ScoreLabelHUD não encontrado. Verifique o caminho.")
	if not banana_label_hud:
		print("WARN: Player - BananaLabelHUD não encontrado. Verifique o caminho.")
	if not animated_sprite:
		print("WARN: Player - AnimatedSprite2D não encontrado.")

	update_stamina_ui()
	update_score_ui()
	update_banana_ui() 

	Globals.player_stats_changed.connect(update_score_ui)
	Globals.player_stats_changed.connect(update_banana_ui)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if current_stamina >= STAMINA_COST_PER_JUMP:
			velocity.y = JUMP_VELOCITY
			current_stamina -= STAMINA_COST_PER_JUMP
			update_stamina_ui()
			Globals.update_player_stamina(current_stamina, max_stamina)
		else:
			pass

	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation()
	move_and_slide()

	Globals.update_player_position(self.global_position)


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
	Globals.update_player_stamina(current_stamina, max_stamina)
	Globals.save_game()

func add_score(value: int) -> void:
	var old_player_score: int = score
	var old_globals_score: int = Globals.score
	score += value
	print("Player add_score: Score local do jogador atualizado de ", old_player_score, " para ", score)
	Globals.update_player_score(score) 
	print("Player add_score: Chamado Globals.update_player_score. Globals.score era ", old_globals_score, " agora é ", Globals.score)
	
func update_stamina_ui() -> void:
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina

func update_score_ui() -> void:
	if score_label_hud:
		var text_to_set: String = "Score: %d" % Globals.score
		print("Player update_score_ui: Atualizando HUD. Texto: '", text_to_set, "' Globals.score: ", Globals.score)
		score_label_hud.text = text_to_set
	else:
		print("Player update_score_ui: score_label_hud é null, não pode atualizar UI.")

func update_banana_ui() -> void:
	if banana_label_hud:
		banana_label_hud.text = str("%04d" % Globals.bananas)
