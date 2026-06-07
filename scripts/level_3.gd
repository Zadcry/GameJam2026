extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FadeManager.fade_in()
	if Global.puerta_destino != "":
		# Buscamos el Marker2D que coincida con el nombre que guardamos
		var spawn_point = get_node_or_null("SpawnPoints/" + Global.puerta_destino)
		
		if spawn_point != null:
			# Obtenemos a los jugadores usando los grupos que ya les asignaste en sus _ready()
			var p1 = get_tree().get_first_node_in_group("player1")
			var p2 = get_tree().get_first_node_in_group("player2")
			
			if p1 and p2:
				# Movemos a los jugadores a la posición del Marker2D.
				# Les damos un pequeño desfase (offset) en X para que no aparezcan uno encima del otro.
				p1.global_position = spawn_point.global_position + Vector2(-30, 0)
				p2.global_position = spawn_point.global_position + Vector2(30, 0)
		else:
			print("Advertencia: No se encontró un Marker2D llamado '", Global.puerta_destino, "' en esta sala.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# FINAL MALO REDIRIGE A:
# res://cinematicas/FinalMalo/FinalMalo.tscn

# FINAL BUENO REDIRIGE A:
# res://cinematicas/FinalBueno/FinalBueno.tscn
