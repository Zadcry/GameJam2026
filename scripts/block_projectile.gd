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
		if is_instance_valid(manager):
			manager.destruir_grupo_en_cadena(mi_celda, mi_tipo)
		else:
			queue_free()
