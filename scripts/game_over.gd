extends Node2D

@onready var quit := $Quit
@onready var retry := $Retry
@onready var barra := $Sprite2D
@onready var sin_senal := $SinSenalFondo
@onready var sonido_pitido := $SonidoPitido
@onready var sonido_estatica := $SonidoEstatica

var barra_inicio_y: float
var barra_fin_y: float
var barra_speed := 100.0

func _ready() -> void:
	FadeManager.fade_in()
	quit.disabled = true
	retry.disabled = true
	quit.connect("pressed", _on_quit)
	retry.connect("pressed", _on_retry)
	barra_inicio_y = -200.0
	barra_fin_y = 700.0
	barra.position.y = barra_inicio_y
	sin_senal.modulate.a = 1.0
	sin_senal.visible = true

	sonido_pitido.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_pitido.play()

	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property(sin_senal, "modulate:a", 0.0, 2.0)
	await tween.finished
	sin_senal.visible = false

	sonido_pitido.stop()
	sonido_estatica.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_estatica.play()

	quit.disabled = false
	retry.disabled = false

func _process(delta: float) -> void:
	barra.position.y += barra_speed * delta
	if barra.position.y >= barra_fin_y:
		barra.position.y = barra_inicio_y

func _on_quit() -> void:
	await _mostrar_sin_senal()
	Global.reset()             # ← resetea todo incluyendo game_over_activo
	Global.es_tutorial = true  # vuelve al menú principal, tiene sentido
	get_tree().change_scene_to_file("res://menus/initial_menu/menuI.tscn")

func _on_retry() -> void:
	await _mostrar_sin_senal()
	Global.reset()             # ← esto faltaba — sin esto game_over_activo queda true
	# NO tocar es_tutorial aquí — que conserve el valor que tenía al morir
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _mostrar_sin_senal() -> void:
	quit.disabled = true
	retry.disabled = true
	sonido_estatica.stop()
	sonido_pitido.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_pitido.play()
	sin_senal.modulate.a = 1.0
	sin_senal.visible = true
	await get_tree().create_timer(2.0).timeout
