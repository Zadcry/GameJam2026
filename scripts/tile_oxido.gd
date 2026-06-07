extends Area2D

func _physics_process(_delta: float) -> void:
	# A diferencia de las hitbox que buscaban áreas, aquí buscamos cuerpos (CharacterBody2D)
	for body in get_overlapping_bodies():
		
		# Verificamos si el cuerpo es el Player 1
		if body.is_in_group("player1"):
			
			# Si el P1 no está ya en knockback (I-frames/aturdido)
			if not body.en_knockback:
				
				# Calculamos la dirección del empuje basados en el centro de la trampa
				var knockback_dir = sign(body.global_position.x - global_position.x)
				if knockback_dir == 0.0: knockback_dir = 1.0 # Respaldo por si caen en el centro exacto
				
				# Le enviamos el daño y el empuje usando tu función ya existente
				body.recibir_dano(knockback_dir)
