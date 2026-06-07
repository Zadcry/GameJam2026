extends Node

var player: AudioStreamPlayer2D

var niveles_con_musica = ["level0", "level1", "level1v2", "level2", "level3", "level4", "level4v2", "level5", "level6", "level7", "level8"]

func _ready() -> void:
	player = $AudioStreamPlayer
	get_tree().root.connect("child_entered_tree", _on_escena_cambiada)

func _on_escena_cambiada(node: Node) -> void:
	await get_tree().process_frame
	var escena_actual = get_tree().current_scene.scene_file_path.get_file().get_basename()
	if escena_actual in niveles_con_musica:
		if not player.playing:
			player.volume_db = linear_to_db(Global.music_volume / 100.0)
			player.play()
	else:
		if player.playing:
			await _fade_out()
			player.stop()

func _fade_out() -> void:
	var t := 0.0
	var vol_inicial = player.volume_db
	while t < 1.0:
		t += get_process_delta_time()
		player.volume_db = lerp(vol_inicial, -80.0, t / 1.0)
		await get_tree().process_frame
	player.volume_db = vol_inicial
