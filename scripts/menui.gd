extends Node

@onready var click := $click
@onready var play := $Play
@onready var options := $Options
@onready var quit := $Quit

var opciones_visibles := false

const CONFIG_PATH := "user://config.cfg"

var resoluciones = [
	Vector2i(640, 360),
	Vector2i(854, 480),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

func _ready() -> void:
	FadeManager.fade_in()
	_cargar_pantalla()

	play.visible = false
	options.visible = false
	quit.visible = false
	play.connect("pressed", _on_play)
	options.connect("pressed", _on_options)
	quit.connect("pressed", _on_quit)
	_parpadear()

func _cargar_pantalla() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		var modo = int(config.get_value("pantalla", "modo", 0))
		var indice_resolucion = int(config.get_value("pantalla", "resolucion", 5))
		Global.sfx_volume = float(config.get_value("audio", "sfx", 100.0))
		Global.music_volume = float(config.get_value("audio", "music", 100.0))

		if modo == 0:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resoluciones[indice_resolucion])
	else:
		Global.sfx_volume = 100.0
		Global.music_volume = 100.0

	_aplicar_volumen_sfx(Global.sfx_volume)
	_aplicar_volumen_music(Global.music_volume)

func _aplicar_volumen_sfx(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _aplicar_volumen_music(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

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
	_aplicar_volumen_sfx(Global.sfx_volume)
	_aplicar_volumen_music(Global.music_volume)

func _on_quit() -> void:
	get_tree().quit()
