extends Area2D

func _ready() -> void:
	# Conectamos la señal de colisión
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si quien lo tocó fue alguno de los dos jugadores
	if body.is_in_group("player1") or body.is_in_group("player2"):
		
		# Sumamos 1 al contador global
		Global.on_bossfight=true;
		print("Spawn set on Bossfight")
		
		# Destruimos la moneda/objeto
		queue_free()
