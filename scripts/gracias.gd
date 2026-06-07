extends Node2D

func _ready() -> void:
	FadeManager.fade_in()
	$Thanks.modulate.a = 0.05
	$GoodEnding.visible = false
	$BadEnding.visible = false
	
	var tween = create_tween()
	tween.tween_property($Thanks, "modulate:a", 1.0, 3.25)
	
	await get_tree().create_timer(3.0).timeout
	
	var ending_label
	if Global.final_bueno:
		$GoodEnding.modulate.a = 0.05
		$GoodEnding.visible = true
		ending_label = $GoodEnding
	else:
		$BadEnding.modulate.a = 0.05
		$BadEnding.visible = true
		ending_label = $BadEnding
	
	var tween2 = create_tween()
	tween2.tween_property(ending_label, "modulate:a", 1.0, 2.0)
	await tween2.finished
	
	var tween3 = create_tween()
	tween3.set_parallel(true)
	tween3.tween_property($Thanks, "modulate:a", 0.0, 3.0)
	tween3.tween_property(ending_label, "modulate:a", 0.0, 3.0)
	await tween3.finished
	
	await FadeManager.fade_out()
	get_tree().change_scene_to_file("res://menus/initial_menu/menuI.tscn")
