extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	connect("animation_finished", _on_animation_finished)

func _on_animation_finished() -> void:
	if is_playing():
		return
	if frame == 0:
		play("default")
	else:
		play_backwards("default")
