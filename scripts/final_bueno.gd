extends Node2D

func _ready() -> void:
	FadeManager.fade_in()
	$VideoStreamPlayer.connect("finished", _on_video_finished)

func _on_video_finished() -> void:
	await FadeManager.fade_out()
	get_tree().change_scene_to_file("res://cinematicas/gracias.tscn")
