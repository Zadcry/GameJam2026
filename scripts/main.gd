extends Node2D

@onready var player1 := $Player1
@onready var player2 := $Player2
@onready var zona_p1 := $ZonaP1
@onready var zona_p2 := $ZonaP2
@onready var letrero_p1 := $LetreroP1
@onready var letrero_p1b := $LetreroP1b
@onready var letrero_p2 := $LetreroP2
@onready var letrero_p2b := $LetreroP2b
@onready var azul := $Azul
@onready var naranja := $Naranja
@onready var punt_label := $PUNT

var azul_invertido := false
var naranja_invertido := false
var p1_en_zona := false
var p2_en_zona := false
var golpes := 0
var tutorial_activo := false

const MARGIN := 100.0
const CAMERA_OFFSET := Vector2(0, -150)

func _ready() -> void:
	Global.es_tutorial = true
	FadeManager.fade_in()
	azul.play("default")
	naranja.play("default")
	azul.connect("animation_finished", _on_azul_finished)
	naranja.connect("animation_finished", _on_naranja_finished)
	zona_p1.connect("body_entered", _on_zona_p1_entered)
	zona_p2.connect("body_entered", _on_zona_p2_entered)
	player2.connect("proyectil_golpeado", _on_proyectil_golpeado)

func _on_azul_finished() -> void:
	azul_invertido = !azul_invertido
	if azul_invertido:
		azul.play_backwards("default")
	else:
		azul.play("default")
	
func _on_naranja_finished() -> void:
	naranja_invertido = !naranja_invertido
	if naranja_invertido:
		naranja.play_backwards("default")
	else:
		naranja.play("default")

func _process(_delta: float) -> void:
	#pass
	Global.oxido_mitch = 0
	Global.vida_crusty = 6

func _on_proyectil_golpeado() -> void:
	if not tutorial_activo:
		return
	golpes += 1
	punt_label.text = "PUNT!\n  " + str(golpes) + "/3"
	if golpes >= 3:
		Global.es_tutorial = false
		await FadeManager.fade_out()
		get_tree().change_scene_to_file("res://cinematicas/intro/intro.tscn")

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
