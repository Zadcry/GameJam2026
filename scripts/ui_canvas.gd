extends CanvasLayer

const ESCALA_BASE_ENGRANAJES := 1.5

@onready var d_sprite := $UI/D_Sprite
@onready var a_sprite := $UI/A_Sprite
@onready var engranaje1 := $UI/Engranaje1
@onready var engranaje2 := $UI/Engranaje2
@onready var engranaje3 := $UI/Engranaje3
@onready var engranaje4 := $UI/Engranaje4
@onready var engranaje_mitch := $UI/EngranajeMitch
@onready var rpm_label := $UI/RPM
@onready var sonido_click := $UI/SonidoClick

# TUBO DE CRUSTY
@onready var b_crusty := $UI/BCrusty

var tex_mitch_0: Texture2D = preload("res://UISprites/Mitch/Engranaje0_Sprite.png")
var tex_mitch_50: Texture2D = preload("res://UISprites/Mitch/Engranaje100_Sprite.png")
var tex_mitch_100: Texture2D = preload("res://UISprites/Mitch/Engranaje50_Sprite.png")

var rotacion_mitch := 0.0

var tex_100: Texture2D = preload("res://UISprites/Crusty/Engranaje100.png")
var tex_50: Texture2D = preload("res://UISprites/Crusty/Engranaje50.png")
var tex_0: Texture2D = preload("res://UISprites/Crusty/Engranaje0.png")

# Temporizadores individuales de latido
var hb_time := [0.0, 0.0, 0.0, 0.0]

# Variables del shake
var shake_time := 0.0
var b_crusty_pos_original := Vector2.ZERO

func _ready() -> void:
	layer = 0

	add_to_group("ui_canvas")

	d_sprite.visible = false
	a_sprite.visible = false

	b_crusty_pos_original = b_crusty.position

	await get_tree().process_frame

	actualizar_vida_crusty()

func mostrar_d(textura: Texture2D) -> void:
	d_sprite.visible = true
	d_sprite.texture = textura

func ocultar_d() -> void:
	d_sprite.visible = false

func mostrar_a(textura: Texture2D) -> void:
	a_sprite.visible = true
	a_sprite.texture = textura

func ocultar_a() -> void:
	a_sprite.visible = false

func play_click() -> void:
	sonido_click.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_click.play()

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

func _heartbeat_scale(idx: int, nodo: Node, delta: float) -> float:
	var tex = nodo.texture

	# Sin vida
	if tex == tex_0:
		hb_time[idx] = 0.0
		return 1.0

	var periodo: float

	if tex == tex_100:
		periodo = 0.857
	else:
		periodo = 0.545

	hb_time[idx] += delta / periodo

	if hb_time[idx] >= 1.0:
		hb_time[idx] -= 1.0

	var t: float = hb_time[idx]
	var s := 1.0

	# Lub
	if t < 0.15:
		s = 1.0 + 0.12 * sin((t / 0.15) * PI)

	# Pausa
	elif t < 0.22:
		s = 1.0

	# Dub
	elif t < 0.37:
		s = 1.0 + 0.07 * sin(((t - 0.22) / 0.15) * PI)

	# Reposo
	else:
		s = 1.0

	return s

func _process(delta: float) -> void:
	var oxido = Global.oxido_mitch

	# ===== VIDA DE CRUSTY =====
	var engranajes = [
		engranaje1,
		engranaje2,
		engranaje3,
		engranaje4
	]

	for i in range(4):
		var s := _heartbeat_scale(i, engranajes[i], delta)

		engranajes[i].scale = Vector2(
			ESCALA_BASE_ENGRANAJES * s,
			ESCALA_BASE_ENGRANAJES * s
		)

	# ===== SHAKE DEL TUBO CUANDO QUEDA 1 VIDA =====
	if Global.vida_crusty == 1:
		shake_time += delta * 12.0
		b_crusty.position.y = b_crusty_pos_original.y + sin(shake_time) * 4.0
	else:
		shake_time = 0.0
		b_crusty.position = b_crusty_pos_original

	# ===== RPM DE MITCH =====
	var rpm := 0.0

	if oxido < 45.0:
		rpm = lerp(1000.0, 650.0, oxido / 45.0)
	elif oxido < 65.0:
		rpm = lerp(650.0, 250.0, (oxido - 45.0) / 20.0)
	else:
		rpm = lerp(
			250.0,
			0.0,
			clamp((oxido - 65.0) / 35.0, 0.0, 1.0)
		)

	rotacion_mitch += (rpm / 1000.0) * 150.0 * delta
	engranaje_mitch.rotation_degrees = rotacion_mitch

	if oxido < 15.0:
		rpm = lerp(1000.0, 650.0, oxido / 15.0)
	elif oxido < 25.0:
		rpm = lerp(650.0, 250.0, (oxido - 15.0) / 10.0)
	else:
		rpm = lerp(
			250.0,
			0.0,
			clamp((oxido - 25.0) / 10.0, 0.0, 1.0)
		)

	rpm_label.text = str(int(rpm)) + " RPM"
