extends StaticBody2D

var manager: Node
var mi_celda: Vector2i
var mi_tipo: String

# Función que llama el TileMapLayer al crearlo
func configurar_bloque(m: Node, c: Vector2i, t: String) -> void:
	manager = m
	mi_celda = c
	mi_tipo = t

func _physics_process(_delta: float) -> void:
	for area in $HitboxArea.get_overlapping_areas():
		if area.name == "MeleeArea" and area.monitoring == true:
			# En lugar de destruirse a sí mismo, activa la cadena
			if is_instance_valid(manager):
				_reproducir_sonido()
				manager.destruir_grupo_en_cadena(mi_celda, mi_tipo)
			else:
				_reproducir_sonido()
				queue_free()
			set_physics_process(false)
			
func _reproducir_sonido() -> void:
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://sfx/destruct_block.ogg")
	audio.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	get_tree().root.add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()
