# Banana.gd
extends Area2D

# Você pode exportar um ID se preferir configurá-lo no inspetor,
# mas usar o nome do nó é mais simples se os nomes forem únicos.
# @export var unique_item_id: String = "" 

@export var stamina_restore_amount: float = 50.0
@export var score_value: int = 10
@export var bananas_value: int = 1 # Quantas bananas este item específico dá

var item_id: String # Será definido no _ready

func _ready() -> void:
	# Define o ID do item. Se unique_item_id for exportado e preenchido, use-o.
	# Caso contrário, use o nome do nó.
	# if not unique_item_id.is_empty():
	# 	item_id = unique_item_id
	# else:
	item_id = self.name # Garanta que o NOME DESTE NÓ seja único na cena!
	
	print("Banana '", item_id, "': _ready() chamado.")

	# Verifica se esta banana já foi coletada
	if Globals.is_item_collected(item_id):
		print("Banana '", item_id, "': Já foi coletada anteriormente. Removendo da cena.")
		queue_free() # Remove a banana se já foi coletada
		return # Importante para não conectar o sinal body_entered abaixo

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Verifica se o nó ainda existe (pode ter sido removido por outra lógica)
	if not is_inside_tree() or is_queued_for_deletion():
		return

	print("Banana '", item_id, "': Colisão detectada com: ", body.name)
	if body.is_in_group("player"):
		print("Banana '", item_id, "': Corpo é 'player'.")
		
		# 1. Marcar este item específico como coletado
		Globals.mark_item_as_collected(item_id)
		
		# 2. Atualizar a contagem global de bananas
		Globals.update_player_bananas(Globals.bananas + bananas_value) # Isso também chama save_game()

		# 3. Adicionar score
		if body.has_method("add_score"):
			body.call("add_score", score_value) # add_score no Player já salva

		# 4. Restaurar estamina
		if body.has_method("restore_stamina"):
			body.call("restore_stamina", stamina_restore_amount) # restore_stamina no Player já salva
		
		print("Banana '", item_id, "': Coletada. Removendo da cena.")
		queue_free()
	# else:
		# print("Banana '", item_id, "': Corpo NÃO é 'player'.")
