extends CanvasLayer

@onready var d_sprite := $UI/D_Sprite
@onready var a_sprite := $UI/A_Sprite
@onready var engranaje1 := $UI/Engranaje1
@onready var engranaje2 := $UI/Engranaje2
@onready var engranaje3 := $UI/Engranaje3
@onready var engranaje_mitch := $UI/EngranajeMitch
@onready var rpm_label := $UI/RPM
@onready var sonido_click := $UI/SonidoClick
@onready var engranaje4 := $UI/Engranaje4

var tex_mitch_0: Texture2D = preload("res://UISprites/Mitch/Engranaje0_Sprite.png")
var tex_mitch_50: Texture2D = preload("res://UISprites/Mitch/Engranaje100_Sprite.png")
var tex_mitch_100: Texture2D = preload("res://UISprites/Mitch/Engranaje50_Sprite.png")

var rotacion_mitch := 0.0
var tex_100: Texture2D = preload("res://UISprites/Crusty/Engranaje100.png")
var tex_50: Texture2D = preload("res://UISprites/Crusty/Engranaje50.png")
var tex_0: Texture2D = preload("res://UISprites/Crusty/Engranaje0.png")

func _ready() -> void:
	add_to_group("ui_canvas")
	d_sprite.visible = false
	a_sprite.visible = false
	await get_tree().process_frame
	actualizar_vida_crusty()

func mostrar_d(textura: Texture2D) -> void:
	d_sprite.visible = true
	d_sprite.texture = textura

func play_click() -> void:
	sonido_click.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_click.play()

func ocultar_d() -> void:
	d_sprite.visible = false

func mostrar_a(textura: Texture2D) -> void:
	a_sprite.visible = true
	a_sprite.texture = textura

func ocultar_a() -> void:
	a_sprite.visible = false
	
func actualizar_vida_crusty() -> void:
	var vida = Global.vida_crusty
	# Engranaje 4 (vida 8-7)
	if vida >= 8:
		engranaje4.texture = tex_100
	elif vida >= 7:
		engranaje4.texture = tex_50
	else:
		engranaje4.texture = tex_0
	# Engranaje 3 (vida 6-5)
	if vida >= 6:
		engranaje3.texture = tex_100
	elif vida >= 5:
		engranaje3.texture = tex_50
	else:
		engranaje3.texture = tex_0
	# Engranaje 2 (vida 4-3)
	if vida >= 4:
		engranaje2.texture = tex_100
	elif vida >= 3:
		engranaje2.texture = tex_50
	else:
		engranaje2.texture = tex_0
	# Engranaje 1 (vida 2-1)
	if vida >= 2:
		engranaje1.texture = tex_100
	elif vida >= 1:
		engranaje1.texture = tex_50
	else:
		engranaje1.texture = tex_0

func _process(delta: float) -> void:
	var oxido = Global.oxido_mitch
	
	# RPM continuo
	var rpm := 0.0
	if oxido < 45.0:
		rpm = lerp(1000.0, 650.0, oxido / 45.0)
	elif oxido < 65.0:
		rpm = lerp(650.0, 250.0, (oxido - 45.0) / 20.0)
	else:
		rpm = lerp(250.0, 0.0, clamp((oxido - 65.0) / 35.0, 0.0, 1.0))
	
	# Rotación proporcional a RPM
	rotacion_mitch += (rpm / 1000.0) * 150.0 * delta
	engranaje_mitch.rotation_degrees = rotacion_mitch
	
	if oxido < 15.0:
		rpm = lerp(1000.0, 650.0, oxido / 15.0)
	elif oxido < 25.0:
		rpm = lerp(650.0, 250.0, (oxido - 15.0) / 10.0)
	else:
		rpm = lerp(250.0, 0.0, clamp((oxido - 25.0) / 10.0, 0.0, 1.0))
	
	rpm_label.text = str(int(rpm)) + " RPM"
