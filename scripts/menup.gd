extends Node

@onready var resume := $TextureButton
@onready var options := $TextureButton2
@onready var quit := $TextureButton3

signal cerrar

func _ready() -> void:
	resume.connect("pressed", _on_resume)
	options.connect("pressed", _on_options)
	quit.connect("pressed", _on_quit)

func _on_resume() -> void:
	get_tree().paused = false
	queue_free()

func _on_options() -> void:
	var opt = preload("res://menus/option_menu/menuOpt.tscn").instantiate()
	opt.connect("cerrar", _on_opciones_cerradas)
	add_child(opt)

func _on_opciones_cerradas() -> void:
	pass

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/initial_menu/menuI.tscn")
