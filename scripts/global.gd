extends Node

var oxido_mitch := 0.0
var vida_crusty := 6.0
var es_tutorial := true
var sfx_volume := 100.0
var music_volume := 100.0
var puerta_destino := ""
var game_over_activo := false
var version_mapa := 1

func _process(_delta: float) -> void:
	if game_over_activo:
		return
	if vida_crusty <= 0 or oxido_mitch >= 35.0:
		_game_over()

func _game_over() -> void:
	game_over_activo = true
	get_tree().change_scene_to_file("res://menus/gameover_menu/menuGaOv.tscn")
