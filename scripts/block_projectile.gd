extends StaticBody2D

var manager: Node
var mi_celda: Vector2i
var mi_tipo: String

func configurar_bloque(m: Node, c: Vector2i, t: String) -> void:
	manager = m
	mi_celda = c
	mi_tipo = t

func _ready() -> void:
	$HitboxArea.connect("area_entered", _on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "HitArea" and area.get_parent().has_method("hit_redirect"):
		_reproducir_sonido()
		if is_instance_valid(manager):
			manager.destruir_grupo_en_cadena(mi_celda, mi_tipo)
		else:
			queue_free()

func _reproducir_sonido() -> void:
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://sfx/destruct_block.ogg")
	audio.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	audio.pitch_scale = 0.8
	get_tree().root.add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()
