# Banana.gd
extends Area2D

@export var stamina_restore_amount: float = 50.0
@export var score_value: int = 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("add_score"):
			body.add_score(score_value)

	if body.is_in_group("player"):
		body.restore_stamina(stamina_restore_amount)
		body.add_score(score_value)
		queue_free()
