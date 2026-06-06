extends ParallaxBackground

@export var tex_lejana: Texture2D
@export var tex_media: Texture2D
@export var tex_frontal: Texture2D

func _ready() -> void:
	if tex_lejana:
		$CapaLejana/Fondo.texture = tex_lejana
	if tex_media:
		$CapaMedia/Medio.texture = tex_media
	if tex_frontal:
		$CapaFrontal/Frente.texture = tex_frontal
