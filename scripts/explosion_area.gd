extends Area2D

func _ready() -> void:
	# Espera un frame para que detecte colisiones
	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body.name == "Player2":
			Global.vida_crusty -= 1
			body.actualizar_cuerpo()
	
	# Spawn del líquido en la misma posición
	var liquido_scene = preload("res://scenes/Liquido.tscn")
	var liquido = liquido_scene.instantiate()
	liquido.global_position = global_position
	get_parent().add_child(liquido)
	
	queue_free()
