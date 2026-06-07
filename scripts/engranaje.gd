extends Area2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Si cualquiera de los dos jugadores lo toca, guardamos el estado
	if body.is_in_group("player1") or body.is_in_group("player2"):
		Global.estado_mundo += 1
		print("¡Objeto especial recogido! Estado global actualizado.")
		queue_free() # Destruye el objeto de la escena
