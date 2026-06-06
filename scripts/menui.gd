extends Node

@onready var click := $click
@onready var play := $Play
@onready var options := $Options
@onready var quit := $Quit

var opciones_visibles := false

func _ready() -> void:
	FadeManager.fade_in()
	play.visible = false
	options.visible = false
	quit.visible = false
	play.connect("pressed", _on_play)
	options.connect("pressed", _on_options)
	quit.connect("pressed", _on_quit)
	_parpadear()

func _parpadear() -> void:
	while not opciones_visibles:
		click.visible = true
		await get_tree().create_timer(0.6).timeout
		click.visible = false
		await get_tree().create_timer(0.4).timeout

func _input(event: InputEvent) -> void:
	if not opciones_visibles and event.is_pressed():
		opciones_visibles = true
		click.visible = false
		play.visible = true
		options.visible = true
		quit.visible = true

func _on_play() -> void:
	get_tree().change_scene_to_file("res://cinematicas/cooperativo.tscn")

func _on_options() -> void:
	play.disabled = true
	options.disabled = true
	quit.disabled = true
	var opt = preload("res://menus/option_menu/menuOpt.tscn").instantiate()
	opt.connect("cerrar", _on_opciones_cerradas)
	add_child(opt)

func _on_opciones_cerradas() -> void:
	play.disabled = false
	options.disabled = false
	quit.disabled = false

func _on_quit() -> void:
	get_tree().quit()
