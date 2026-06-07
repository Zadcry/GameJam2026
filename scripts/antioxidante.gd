extends Area2D

func _ready() -> void:
	# Conectamos la señal de colisión
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si quien lo tocó fue alguno de los dos jugadores
	if body.is_in_group("player1") or body.is_in_group("player2"):
		
		# Sumamos 1 al contador global
		Global.contador_antioxidantes += 1
		if Global.vida_crusty < 6:
			Global.vida_crusty += 1
		if Global.oxido_mitch > 10:
			Global.oxido_mitch -=10
		print("¡Coleccionable recogido! Total actual: ", Global.contador_antioxidantes)
		
		# Destruimos la moneda/objeto
		queue_free()
