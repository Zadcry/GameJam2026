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
				manager.destruir_grupo_en_cadena(mi_celda, mi_tipo)
			else:
				queue_free() # Respaldo por si se usa fuera de un TileMap
			
			# Apagamos este código para que no pida destruirse 60 veces por segundo
			set_physics_process(false)
