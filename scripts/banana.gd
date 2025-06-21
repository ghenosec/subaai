extends Area2D

@export var stamina_restore_amount: float = 50.0
@export var score_value: int = 10
@export var bananas_value: int = 1 

var item_id: String 

func _ready() -> void:
	item_id = self.name 
	
	print("Banana '", item_id, "': _ready() chamado.")

	if Globals.is_item_collected(item_id):
		print("Banana '", item_id, "': Já foi coletada anteriormente. Removendo da cena.")
		queue_free() 
		return 

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return

	print("Banana '", item_id, "': Colisão detectada com: ", body.name)
	if body.is_in_group("player"):
		print("Banana '", item_id, "': Corpo é 'player'.")
		
		Globals.mark_item_as_collected(item_id)

		Globals.update_player_bananas(Globals.bananas + bananas_value) 

		if body.has_method("add_score"):
			body.call("add_score", score_value) 

		if body.has_method("restore_stamina"):
			body.call("restore_stamina", stamina_restore_amount)
		
		print("Banana '", item_id, "': Coletada. Removendo da cena.")
		queue_free()
