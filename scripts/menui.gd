extends Node

@onready var click := $click
@onready var play := $Play
@onready var options := $Options
@onready var quit := $Quit

var opciones_visibles := false
var _opt_node : Node = null

const CONFIG_PATH := "user://config.cfg"

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
		Global.sfx_volume = float(config.get_value("audio", "sfx", 100.0))
		Global.music_volume = float(config.get_value("audio", "music", 100.0))
		var indice_resolucion = int(config.get_value("pantalla", "resolucion", 5))
		var ultima_ventana = int(config.get_value("pantalla", "ultima_ventana", indice_resolucion))
		# Sobreescribe modo a 0 (Fullscreen) en el config guardado
		config.set_value("pantalla", "modo", 0)
		config.set_value("pantalla", "resolucion", indice_resolucion)
		config.set_value("pantalla", "ultima_ventana", ultima_ventana)
		config.save(CONFIG_PATH)
	else:
		Global.sfx_volume = 100.0
		Global.music_volume = 100.0
		# Crea config por defecto con fullscreen
		config.set_value("pantalla", "modo", 0)
		config.set_value("pantalla", "resolucion", 5)
		config.set_value("pantalla", "ultima_ventana", 5)
		config.set_value("audio", "sfx", 100.0)
		config.set_value("audio", "music", 100.0)
		config.save(CONFIG_PATH)

	# Siempre fullscreen al iniciar
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

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
	if _opt_node != null:
		return
	play.disabled = true
	options.disabled = true
	quit.disabled = true
	var opt = preload("res://menus/option_menu/menuOpt.tscn").instantiate()
	opt.desde_pausa = false
	opt.connect("cerrar", _on_opciones_cerradas)
	add_child(opt)
	_opt_node = opt

func _on_opciones_cerradas(_cerrar_todo: bool) -> void:
	_opt_node = null
	play.disabled = false
	options.disabled = false
	quit.disabled = false
	_aplicar_volumen_sfx(Global.sfx_volume)
	_aplicar_volumen_music(Global.music_volume)

func _on_quit() -> void:
	get_tree().quit()
