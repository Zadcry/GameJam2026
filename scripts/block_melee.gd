extends StaticBody2D

func _physics_process(_delta: float) -> void:
	# Revisamos constantemente todas las áreas que se solapan con la Hitbox del bloque
	for area in $HitboxArea.get_overlapping_areas():
		# Verificamos que sea el área Melee del P2 Y que esté activamente atacando (monitoring = true) 
		if area.name == "MeleeArea" and area.monitoring == true:
			queue_free()
