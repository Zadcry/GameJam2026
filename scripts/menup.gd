extends Node

signal cerrar

@onready var resume := $TextureButton
@onready var options := $TextureButton2
@onready var quit := $TextureButton3
@onready var _screen := $ScreenPause

const ANIM_DURACION := 0.35
const OFFSET_ENTRADA := 1600.0
const FADE_DELAY := 1.0

var _posicion_origen := Vector2.ZERO
var _animando := false
var _opciones_abiertas := false
var _opt_ref : Node = null

func _ready() -> void:
	resume.connect("pressed", _on_resume)
	options.connect("pressed", _on_options)
	quit.connect("pressed", _on_quit)
	_posicion_origen = _screen.position
	_screen.position.x -= OFFSET_ENTRADA
	resume.modulate.a = 0.0
	options.modulate.a = 0.0
	quit.modulate.a = 0.0
	_animar_entrada()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not _animando and not _opciones_abiertas:
			_animar_salida_y_cerrar()

func _on_resume() -> void:
	_animar_salida_y_cerrar()

func _on_options() -> void:
	if _animando or _opciones_abiertas:
		return
	_opciones_abiertas = true
	resume.disabled = true
	options.disabled = true
	quit.disabled = true
	FadeManager.play_click()
	var opt = preload("res://menus/option_menu/menuOpt.tscn").instantiate()
	opt.desde_pausa = true
	opt.connect("cerrar", _on_opciones_cerradas)
	_opt_ref = opt
	add_child(opt)

func _on_opciones_cerradas(cerrar_pausa: bool) -> void:
	if _opt_ref:
		_opt_ref.queue_free()
	_opt_ref = null
	_opciones_abiertas = false
	resume.disabled = false
	options.disabled = false
	quit.disabled = false

func _on_quit() -> void:
	get_tree().paused = false
	get_parent().queue_free()
	get_tree().change_scene_to_file("res://menus/initial_menu/menuI.tscn")

func _animar_entrada() -> void:
	_animando = true
	var tween = create_tween()
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_screen, "position:x", _posicion_origen.x, ANIM_DURACION)
	tween.tween_interval(FADE_DELAY)
	tween.set_parallel(true)
	tween.tween_property(resume, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	tween.tween_property(options, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	tween.tween_property(quit, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	await tween.finished
	_animando = false

func _animar_salida_y_cerrar() -> void:
	if _animando:
		return
	_animando = true
	resume.disabled = true
	options.disabled = true
	quit.disabled = true
	set_process_input(false)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(resume, "modulate:a", 0.0, ANIM_DURACION * 0.6)
	tween.tween_property(options, "modulate:a", 0.0, ANIM_DURACION * 0.6)
	tween.tween_property(quit, "modulate:a", 0.0, ANIM_DURACION * 0.6)
	tween.set_parallel(false)
	tween.tween_property(_screen, "position:x", _posicion_origen.x - OFFSET_ENTRADA, ANIM_DURACION)
	await tween.finished
	get_tree().paused = false
	queue_free()

func _hacer_invisible() -> void:
	_screen.modulate.a = 0.0
	resume.modulate.a = 0.0
	options.modulate.a = 0.0
	quit.modulate.a = 0.0

func _fade_out_pausa() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_screen, "modulate:a", 0.0, ANIM_DURACION * 0.8)
	tween.tween_property(resume, "modulate:a", 0.0, ANIM_DURACION * 0.8)
	tween.tween_property(options, "modulate:a", 0.0, ANIM_DURACION * 0.8)
	tween.tween_property(quit, "modulate:a", 0.0, ANIM_DURACION * 0.8)
	await tween.finished

func _fade_in_pausa() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_screen, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	tween.tween_property(resume, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	tween.tween_property(options, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	tween.tween_property(quit, "modulate:a", 1.0, ANIM_DURACION * 0.8)
	await tween.finished
