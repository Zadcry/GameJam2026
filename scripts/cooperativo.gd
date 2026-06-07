extends Node

@onready var coop := $coop
@onready var sprite_e := $E
@onready var sprite_flecha := $flecha
@onready var OrNot := $OrNot

func _ready() -> void:
	FadeManager.fade_in()
	OrNot.modulate.a = 0.0
	coop.modulate.a = 0.0
	sprite_e.visible = false
	sprite_flecha.visible = false
	_animar()

func _animar() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(coop, "modulate:a", 1.0, 2.0)
	tween.tween_property(OrNot, "modulate:a", 0.3, 2.0)
	await tween.finished
	sprite_e.visible = true
	sprite_flecha.visible = true

func _input(event: InputEvent) -> void:
	if sprite_e.visible and event.is_action_pressed("p1_shoot"):
		coop.visible = false
		OrNot.visible = false
		sprite_e.visible = false
		sprite_flecha.visible = false
		await FadeManager.fade_out()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
