extends Area2D

# Tiempo requerido en segundos para cambiar de nivel
const REQUIRED_TIME := 2.0 
var time_inside := 0.0

# Al exportar esta variable, podrás poner la ruta de tu siguiente nivel
# directamente desde el Inspector de Godot, haciendo este bloque reutilizable.
@export var next_level_path: String = "res://scenes/level1.tscn"

func _physics_process(delta: float) -> void:
	var p1_in_zone = false
	var p2_in_zone = false
	
	# Revisamos todos los cuerpos físicos que están tocando el área en este frame
	for body in get_overlapping_bodies():
		if body.name == "Player1": # Asegúrate de que el nodo de tu jugador 1 se llame así en la escena
			p1_in_zone = true
		elif body.name == "Player2": # Asegúrate de que el nodo de tu jugador 2 se llame así en la escena
			p2_in_zone = true
			
	# Si AMBOS jugadores están dentro, el tiempo avanza
	if p1_in_zone and p2_in_zone:
		time_inside += delta
		
		# Si llegamos a los 2 segundos, cambiamos de escena
		if time_inside >= REQUIRED_TIME:
			_change_level()
	else:
		# Si uno de los dos sale (o ninguno está), el contador se reinicia a 0
		time_inside = 0.0

func _change_level() -> void:
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("Error: No has asignado una ruta para el siguiente nivel en el Inspector.")
