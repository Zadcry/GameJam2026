extends ParallaxBackground

@export var tex_lejana: Texture2D
@export var tex_media: Texture2D
@export var tex_frontal: Texture2D

@export var tex_lejana_alt: Texture2D
@export var tex_media_alt: Texture2D
@export var tex_frontal_alt: Texture2D

func _escalar_a_pantalla(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return
	var screen = get_viewport().get_visible_rect().size
	var tex_size = sprite.texture.get_size()
	sprite.scale = Vector2(screen.x / tex_size.x, screen.y / tex_size.y) * 1.3

func _ready() -> void:
	# CHEQUEO DE ESTADO: Si tienen el objeto, cambiamos las texturas a las alternativas
	if Global.estado_mundo==2:
		if tex_lejana_alt: tex_lejana = tex_lejana_alt
	if Global.estado_mundo==3:
		if tex_lejana_alt: tex_lejana = tex_lejana_alt
		if tex_media_alt: tex_media = tex_media_alt
		if tex_frontal_alt: tex_frontal = tex_frontal_alt
		
	$CapaLejana.motion_scale = Vector2(0.1, 0.0)
	$CapaMedia.motion_scale = Vector2(0.4, 0.0)
	$CapaFrontal.motion_scale = Vector2(0.8, 0.0)
	if tex_lejana:
		$CapaLejana/Fondo.texture = tex_lejana
	if tex_media:
		$CapaMedia/Medio.texture = tex_media
	if tex_frontal:
		$CapaFrontal/Frente.texture = tex_frontal
	var screen = get_viewport().get_visible_rect().size
	$CapaLejana/Fondo.position = screen / 2.0
	$CapaFrontal/Frente.position = screen / 2.0
	_escalar_a_pantalla($CapaLejana/Fondo)
	_escalar_a_pantalla($CapaFrontal/Frente)
	$CapaLejana.motion_mirroring = Vector2(screen.x, 0.0)
	$CapaMedia.motion_mirroring = Vector2(screen.x, 0.0)
	$CapaFrontal.motion_mirroring = Vector2(screen.x, 0.0)
	$CapaMedia/Medio.centered = false
	$CapaMedia/Medio.position = Vector2(0.0, 0.0)
	if tex_media:
		var tex_size = $CapaMedia/Medio.texture.get_size()
		$CapaMedia/Medio.scale = Vector2(screen.x / tex_size.x, screen.y / tex_size.y)
		
# CUANDO SE QUIERA QUE CAMBIE EL FONDO CON Global.version_mapa (1,2,3) se descomenta este código: 
#@export var textura_v1: Texture2D
#@export var textura_v2: Texture2D
#@export var textura_v3: Texture2D
#
#func _process(_delta: float) -> void:
	#match Global.version_mapa:
		#1: $CapaX/Sprite.texture = textura_v1
		#2: $CapaX/Sprite.texture = textura_v2
		#3: $CapaX/Sprite.texture = textura_v3
