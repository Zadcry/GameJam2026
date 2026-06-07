extends Area2D

var time_inside := 0.0

@export var next_level_path: String = ""
@export var id_destino: String = "EntradaIzquierda" 
@export var REQUIRED_TIME := 2.0

# Configuración Condicional
@export var usar_desvio_condicional: bool = false # Encender esto en el Inspector solo si es un TP especial
@export var path_alternativo: String = ""
@export var id_destino_alternativo: String = ""

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
	var path_a_cargar = next_level_path
	var id_a_cargar = id_destino
	
	# Si este TP en específico es condicional Y tienen el objeto especial...
	if usar_desvio_condicional and Global.estado_mundo==2:
		path_a_cargar = path_alternativo
		id_a_cargar = id_destino_alternativo

	if path_a_cargar != "":
		Global.puerta_destino = id_a_cargar
		get_tree().change_scene_to_file(path_a_cargar)
	else:
		print("Error: Falta la ruta del nivel.")
