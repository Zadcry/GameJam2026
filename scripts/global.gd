extends Node

var oxido_mitch := 0.0
var vida_crusty := 6.0
var es_tutorial := false
var sfx_volume := 100.0
var music_volume := 100.0
var puerta_destino := ""
var game_over_activo := false
var version_mapa := 1
var final_bueno : bool = false
var estado_mundo := 1
var contador_antioxidantes := 0
var on_bossfight := false

func _process(_delta: float) -> void:
	if game_over_activo:
		return
	oxido_mitch = maxf(oxido_mitch, 0.0)
	vida_crusty = maxf(vida_crusty, 0.0)
	if vida_crusty <= 0 or oxido_mitch >= 35.0:
		_game_over()

func _game_over() -> void:
	if game_over_activo:
		return
	game_over_activo = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/gameover_menu/menuGaOv.tscn")

func reset() -> void:
	oxido_mitch = 0.0
	vida_crusty = 6.0
	game_over_activo = false
	contador_antioxidantes = 0
