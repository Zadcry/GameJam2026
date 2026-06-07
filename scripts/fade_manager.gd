extends CanvasLayer

@onready var fade := $Fade
@onready var sonido_click := $SonidoClick

func play_click() -> void:
	sonido_click.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_click.play()
	
func _ready() -> void:
	fade.color = Color(0, 0, 0, 1)
	fade.modulate.a = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_in() -> void:
	fade.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	await tween.finished
