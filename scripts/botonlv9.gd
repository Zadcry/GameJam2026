extends Area2D
@export var muro_a_eliminar: StaticBody2D
@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	# Aprovechamos los grupos "player1" y "player2" que ya configuraste en tus jugadores
	if body.is_in_group("player1") or body.is_in_group("player2"):
		
		# Verificamos que el muro exista antes de intentar borrarlo (evita crashes)
		if is_instance_valid(muro_a_eliminar):
			print("¡Jugador pisó el área! Eliminando muro: ", muro_a_eliminar.name)
			
			# queue_free() elimina el nodo de la escena de forma segura al final del fotograma
			muro_a_eliminar.queue_free()
			
			# OPCIONAL: Si quieres que el interruptor sea de un solo uso, 
			# nos destruimos a nosotros mismos para que no siga procesando colisiones.
			animacion.play("prendido")
