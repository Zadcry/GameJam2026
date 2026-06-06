extends CanvasLayer

@onready var fade := $Fade

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
