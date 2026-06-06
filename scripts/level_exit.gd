extends Area2D

var time_inside := 0.0

@export var next_level_path: String = ""
# Nueva variable para escribir el ID del punto de aparición en la otra sala
@export var id_destino: String = "EntradaIzquierda" 
@export var REQUIRED_TIME := 2.0

func _physics_process(delta: float) -> void:
	var p1_in_zone = false
	var p2_in_zone = false
	
	for body in get_overlapping_bodies():
		if body.name == "Player1":
			p1_in_zone = true
		elif body.name == "Player2":
			p2_in_zone = true
			
	if p1_in_zone and p2_in_zone:
		time_inside += delta
		if time_inside >= REQUIRED_TIME:
			_change_level()
	else:
		time_inside = 0.0

func _change_level() -> void:
	if next_level_path != "":
		# Guardamos a dónde vamos en el Global ANTES de cambiar de escena
		Global.puerta_destino = id_destino 
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("Error: Falta la ruta del nivel.")
