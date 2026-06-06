extends Node2D

@onready var player1 := $Player1
@onready var player2 := $Player2
@onready var zona_p1 := $ZonaP1
@onready var zona_p2 := $ZonaP2
@onready var letrero_p1 := $LetreroP1
@onready var letrero_p1b := $LetreroP1b
@onready var letrero_p2 := $LetreroP2
@onready var letrero_p2b := $LetreroP2b

var p1_en_zona := false
var p2_en_zona := false
var golpes := 0
var tutorial_activo := false

const MARGIN := 100.0
const CAMERA_OFFSET := Vector2(0, -150)

func _ready() -> void:
	FadeManager.fade_in()
	zona_p1.connect("body_entered", _on_zona_p1_entered)
	zona_p2.connect("body_entered", _on_zona_p2_entered)
	player2.connect("proyectil_golpeado", _on_proyectil_golpeado)

func _process(_delta: float) -> void:
	var midpoint = (player1.global_position + player2.global_position) / 2.0
	var half_w = get_viewport().get_visible_rect().size.x / 2.0
	var half_h = get_viewport().get_visible_rect().size.y / 2.0
	#Global.oxido_mitch = 0
	#Global.vida_crusty = 6

func _on_proyectil_golpeado() -> void:
	if not tutorial_activo:
		return
	golpes += 1
	print("Golpes: ", golpes)
	if golpes >= 3:
		get_tree().reload_current_scene()


func _on_zona_p1_entered(body: Node2D) -> void:
	if body.name == "Player1":
		p1_en_zona = true
		player1.lock_movement(1.0)
		letrero_p1.visible = false
		letrero_p1b.visible = true
		if p2_en_zona:
			tutorial_activo = true

func _on_zona_p2_entered(body: Node2D) -> void:
	if body.name == "Player2":
		p2_en_zona = true
		player2.lock_movement(-1.0)
		letrero_p2.visible = false
		letrero_p2b.visible = true
		if p1_en_zona:
			tutorial_activo = true
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar"):
		_pausar()

func _pausar() -> void:
	get_tree().paused = true
	var pausa = preload("res://menus/pause_menu/menuP.tscn").instantiate()
	var canvas = CanvasLayer.new()
	add_child(canvas)
	canvas.add_child(pausa)
