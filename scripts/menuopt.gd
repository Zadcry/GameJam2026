extends Node

signal cerrar

var opciones = ["Fullscreen", "Windowed"]
var indice_actual = 0

var resoluciones = [
	Vector2i(640, 360),
	Vector2i(854, 480),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]
var indice_resolucion = 5
var ultima_resolucion_ventana = indice_resolucion

const CONFIG_PATH := "user://config.cfg"

@onready var modo_label = $Label
@onready var resolucion_label = $Label2
@onready var flecha_izq = $Label3
@onready var flecha_der = $Label4
@onready var quit := $Quit
@onready var sfx := $sfx
@onready var music := $music

func _ready() -> void:
	quit.connect("pressed", _on_quit)
	sfx.connect("value_changed", _on_sfx_changed)
	music.connect("value_changed", _on_music_changed)

	var es_primera_vez = _load_config()

	sfx.value = Global.sfx_volume
	music.value = Global.music_volume
	_aplicar_volumen_sfx(Global.sfx_volume)
	_aplicar_volumen_music(Global.music_volume)

	_aplicar_fuente()
	_aplicar_configuracion()
	_actualizar_label_resolucion()
	_actualizar_visibilidad_flechas()

	sfx.gui_input.connect(_on_sfx_gui_input)
	music.gui_input.connect(_on_music_gui_input)

	if es_primera_vez:
		_save_config()

func _on_sfx_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ratio = clamp(event.position.x / sfx.size.x, 0.0, 1.0)
		sfx.value = lerp(sfx.min_value, sfx.max_value, ratio)
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		var ratio = clamp(event.position.x / sfx.size.x, 0.0, 1.0)
		sfx.value = lerp(sfx.min_value, sfx.max_value, ratio)

func _on_music_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ratio = clamp(event.position.x / music.size.x, 0.0, 1.0)
		music.value = lerp(music.min_value, music.max_value, ratio)
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		var ratio = clamp(event.position.x / music.size.x, 0.0, 1.0)
		music.value = lerp(music.min_value, music.max_value, ratio)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var click_pos = event.position

		if modo_label and modo_label.get_global_rect().has_point(click_pos) and event.button_index == MOUSE_BUTTON_LEFT:
			if opciones[indice_actual] == "Windowed":
				ultima_resolucion_ventana = indice_resolucion

			indice_actual = (indice_actual + 1) % opciones.size()
			modo_label.text = opciones[indice_actual]

			match opciones[indice_actual]:
				"Fullscreen":
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
					DisplayServer.window_set_size(Vector2i(1920, 1080))
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
					resolucion_label.text = "1920x1080"
					resolucion_label.modulate.a = 0.5
				"Windowed":
					indice_resolucion = ultima_resolucion_ventana
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					resolucion_label.modulate.a = 1.0
					_actualizar_label_resolucion()

			_actualizar_visibilidad_flechas()
			_save_config()

		if opciones[indice_actual] == "Windowed":
			if flecha_izq and flecha_izq.get_global_rect().has_point(click_pos) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion > 0:
					indice_resolucion -= 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()

			if flecha_der and flecha_der.get_global_rect().has_point(click_pos) and event.button_index == MOUSE_BUTTON_LEFT:
				if indice_resolucion < resoluciones.size() - 1:
					indice_resolucion += 1
					DisplayServer.window_set_size(resoluciones[indice_resolucion])
					_actualizar_label_resolucion()
					_actualizar_visibilidad_flechas()
					_save_config()

func _actualizar_label_resolucion() -> void:
	if opciones[indice_actual] == "Fullscreen":
		resolucion_label.text = "1920x1080"
	else:
		var res = resoluciones[indice_resolucion]
		resolucion_label.text = "%dx%d" % [res.x, res.y]

func _actualizar_visibilidad_flechas() -> void:
	if indice_actual < 0 or indice_actual >= opciones.size():
		indice_actual = clamp(indice_actual, 0, opciones.size() - 1)

	var arrows_visible = opciones[indice_actual] == "Windowed"
	flecha_izq.visible = arrows_visible
	flecha_der.visible = arrows_visible
	flecha_izq.text = "<"
	flecha_der.text = ">"

	if arrows_visible:
		flecha_izq.modulate.a = 0.3 if indice_resolucion <= 0 else 1.0
		flecha_der.modulate.a = 0.3 if indice_resolucion >= resoluciones.size() - 1 else 1.0

func _aplicar_configuracion() -> void:
	if indice_actual < 0 or indice_actual >= opciones.size():
		indice_actual = 0

	modo_label.text = opciones[indice_actual]

	match opciones[indice_actual]:
		"Fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			resolucion_label.text = "1920x1080"
			resolucion_label.modulate.a = 0.5
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resoluciones[indice_resolucion])
			resolucion_label.modulate.a = 1.0

func _aplicar_fuente() -> void:
	var fuente_archivo : FontFile = load("res://fonts/DePixelBreit.ttf")
	var label_settings = LabelSettings.new()
	label_settings.font = fuente_archivo
	label_settings.font_size = 24

	for label in [modo_label, resolucion_label, flecha_izq, flecha_der]:
		if label:
			label.label_settings = label_settings.duplicate()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _save_config() -> void:
	var config = ConfigFile.new()
	config.set_value("pantalla", "modo", indice_actual)
	config.set_value("pantalla", "resolucion", indice_resolucion)
	config.set_value("pantalla", "ultima_ventana", ultima_resolucion_ventana)
	config.set_value("audio", "sfx", Global.sfx_volume)
	config.set_value("audio", "music", Global.music_volume)
	var err = config.save(CONFIG_PATH)
	if err != OK:
		push_error("options_menu: failed to save config, error code %d" % err)

func _load_config() -> bool:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		indice_actual             = int(config.get_value("pantalla", "modo", 0))
		indice_resolucion         = int(config.get_value("pantalla", "resolucion", 5))
		ultima_resolucion_ventana = int(config.get_value("pantalla", "ultima_ventana", indice_resolucion))
		Global.sfx_volume         = float(config.get_value("audio", "sfx", 100.0))
		Global.music_volume       = float(config.get_value("audio", "music", 100.0))
		return false
	else:
		indice_actual             = 0
		indice_resolucion         = 5
		ultima_resolucion_ventana = indice_resolucion
		Global.sfx_volume         = 100.0
		Global.music_volume       = 100.0
		return true

func _aplicar_volumen_sfx(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _aplicar_volumen_music(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_sfx_changed(value: float) -> void:
	Global.sfx_volume = value
	_aplicar_volumen_sfx(value)
	_save_config()

func _on_music_changed(value: float) -> void:
	Global.music_volume = value
	_aplicar_volumen_music(value)
	_save_config()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		if opciones[indice_actual] == "Windowed":
			var modo_actual = DisplayServer.window_get_mode()
			if modo_actual == DisplayServer.WINDOW_MODE_MAXIMIZED or \
			   modo_actual == DisplayServer.WINDOW_MODE_MINIMIZED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_size(resoluciones[indice_resolucion])

func _on_quit() -> void:
	emit_signal("cerrar")
	queue_free()
