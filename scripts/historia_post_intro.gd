extends Node

@onready var fondo := $ColorRect
@onready var historia1 := $historia1
@onready var historia2 := $historia2
@onready var historia3 := $historia3
@onready var historia4 := $historia4
@onready var historia5 := $historia5
@onready var sprite_e := $E
@onready var sprite_m := $M
@onready var sprite_m2 := $M2
@onready var sprite_c := $C
@onready var sprite_c2 := $C2

var puede_presionar_e := false

func _ready() -> void:
	historia1.modulate.a = 0.0
	historia2.modulate.a = 0.0
	historia3.modulate.a = 0.0
	historia4.modulate.a = 0.0
	historia5.modulate.a = 0.0
	sprite_e.modulate.a = 0.0
	sprite_m.modulate.a = 0.0
	sprite_m2.modulate.a = 0.0
	sprite_c.modulate.a = 0.0
	sprite_c2.modulate.a = 0.0
	_secuencia()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and puede_presionar_e:
			puede_presionar_e = false

func _secuencia() -> void:
	# Historia 1
	await _fade_in(historia1, 2.0)
	await _fade_in(sprite_e, 0.5)
	puede_presionar_e = true
	await _esperar_e()
	await _fade_out(sprite_e, 0.2)
	await _fade_out(historia1, 1.0)

	# Historia 2 + M
	await get_tree().create_timer(0.5).timeout
	await _fade_in(historia2, 1.5)
	await _fade_in(sprite_m, 0.5)
	await _fade_in(sprite_e, 0.5)
	puede_presionar_e = true
	await _esperar_e()
	await _fade_out(sprite_e, 0.2)

	# Historia 3 + C
	await get_tree().create_timer(0.5).timeout
	await _fade_in(historia3, 1.5)
	await _fade_in(sprite_c, 0.5)
	await _fade_in(sprite_e, 0.5)
	puede_presionar_e = true
	await _esperar_e()
	await _fade_out(sprite_e, 0.2)

	# Historia 4 + M2
	await get_tree().create_timer(0.5).timeout
	await _fade_in(historia4, 1.5)
	await _fade_in(sprite_m2, 0.5)
	await _fade_in(sprite_e, 0.5)
	puede_presionar_e = true
	await _esperar_e()
	await _fade_out(sprite_e, 0.2)

	# Historia 5 + C2
	await get_tree().create_timer(0.5).timeout
	await _fade_in(historia5, 1.5)
	await _fade_in(sprite_c2, 0.5)
	await _fade_in(sprite_e, 0.5)
	puede_presionar_e = true
	await _esperar_e()

	# Final
	await _fade_out(sprite_e, 0.2)
	var nodos = [historia2, historia3, historia4, historia5, sprite_m, sprite_m2, sprite_c, sprite_c2, fondo]
	var t := 0.0
	while t < 1.5:
		t += get_process_delta_time()
		var alpha = clamp(1.0 - (t / 1.5), 0.0, 1.0)
		for nodo in nodos:
			nodo.modulate.a = alpha
		await get_tree().process_frame
	for nodo in nodos:
		nodo.modulate.a = 0.0
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/level0.tscn")

func _esperar_e() -> void:
	await get_tree().process_frame
	while puede_presionar_e:
		await get_tree().process_frame

func _fade_in(nodo: CanvasItem, duracion: float) -> void:
	var t := 0.0
	nodo.modulate.a = 0.0
	while t < duracion:
		t += get_process_delta_time()
		nodo.modulate.a = clamp(t / duracion, 0.0, 1.0)
		await get_tree().process_frame
	nodo.modulate.a = 1.0

func _fade_out(nodo: CanvasItem, duracion: float) -> void:
	var t := 0.0
	nodo.modulate.a = 1.0
	while t < duracion:
		t += get_process_delta_time()
		nodo.modulate.a = clamp(1.0 - (t / duracion), 0.0, 1.0)
		await get_tree().process_frame
	nodo.modulate.a = 0.0
