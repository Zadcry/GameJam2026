extends Node2D

func _ready() -> void:
	FadeManager.fade_in()
	$AnimationPlayer.play("intro")
	$AnimationPlayer.connect("animation_finished", _on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "intro":
		await FadeManager.fade_out()
		get_tree().change_scene_to_file("res://scenes/level0.tscn")
