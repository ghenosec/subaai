# BreakablePlatform.gd - Anexe ao nó raiz da sua cena de tronco
extends StaticBody2D

# Configurações da plataforma quebrável
@export var break_delay: float = 1.5 # Tempo em segundos antes de quebrar
@export var shake_intensity: float = 4.0 # Quão forte a plataforma treme

# Variáveis de controle
var is_breakable: bool = false
var is_breaking: bool = false
var player_on_top: bool = false

# Nós necessários (crie-os na cena do tronco)
@onready var timer: Timer = $BreakTimer
@onready var top_checker: Area2D = $TopCheckerArea

func _ready():
	# Conecta os sinais dos nós filhos
	top_checker.body_entered.connect(_on_player_entered)
	top_checker.body_exited.connect(_on_player_exited)
	timer.timeout.connect(_on_timer_timeout)

# Esta função será chamada pelo PlatformManager para tornar a plataforma quebrável
func setup_as_breakable():
	is_breakable = true
	# Você pode mudar a cor para dar uma dica visual ao jogador
	$Sprite2D.modulate = Color(1.0, 0.8, 0.8) # Deixa um pouco avermelhada

func _on_player_entered(body):
	if body.is_in_group("player") and is_breakable and not is_breaking:
		print("Player pisou em plataforma quebrável!")
		is_breaking = true
		player_on_top = true
		timer.start(break_delay)
		shake_animation()

func _on_player_exited(body):
	if body.is_in_group("player"):
		player_on_top = false

func _on_timer_timeout():
	# Só quebra se o player AINDA estiver em cima
	if player_on_top:
		print("Plataforma quebrou!")
		queue_free()
	else:
		# Se o player saiu, a plataforma se "conserta"
		is_breaking = false

func shake_animation():
	# Usa um Tween para criar uma animação de tremor suave
	var tween = create_tween().set_loops()
	var original_pos = $Sprite2D.position

	# Animação de tremor
	tween.tween_property(
		$Sprite2D, "position", original_pos + Vector2(shake_intensity, 0), 0.05
	)
	tween.tween_property(
		$Sprite2D, "position", original_pos - Vector2(shake_intensity, 0), 0.05
	)
