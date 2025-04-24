extends Area2D

var bananas := 1

@onready var Banana_counter = $"../StaticBody2D/Banana_counter" as Label
@export var stamina_restore_amount: float = 50.0
@export var score_value: int = 10

func _ready():
	Banana_counter.text = str("%04d" % Globals.bananas)
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	Banana_counter.text = str("%04d" % Globals.bananas)
	
func _on_body_entered(_body: Node2D) -> void:
	Globals.bananas += bananas
	if _body.has_method("add_score"):
		_body.add_score(score_value)

	if _body.is_in_group("player"):
		_body.restore_stamina(stamina_restore_amount)
		Banana_counter.text = str("%04d" % Globals.bananas)
		queue_free()
