extends CanvasLayer

@onready var d_sprite := $UI/D_Sprite
@onready var a_sprite := $UI/A_Sprite

func _ready() -> void:
	add_to_group("ui_canvas")
	d_sprite.visible = false
	a_sprite.visible = false

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
