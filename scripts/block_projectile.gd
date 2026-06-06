extends StaticBody2D

func _ready() -> void:
	$HitboxArea.connect("area_entered", _on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Verificamos si nos toca el hijo "HitArea" y si su nodo padre tiene la función de tu proyectil [cite: 4, 5]
	if area.name == "HitArea" and area.get_parent().has_method("hit_redirect"):
		queue_free()
