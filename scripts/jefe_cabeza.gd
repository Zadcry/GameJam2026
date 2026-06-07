extends CharacterBody2D

@export var speed: float = 100
@export var speed_ataque: float = 300 
var sigueJugador: bool = false

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $hitBox
@onready var hurtbox: Area2D = $hurtbox
@onready var timer: Timer = $Timer

var jugador: Node2D = null	
var distanciaContraPlayer: int = 200


enum Estado { SIGUIENDO, ATACANDO, REGRESANDO }
var estado_actual = Estado.SIGUIENDO
var posicion_x_original: float = -255.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if jugador != null and is_instance_valid(jugador):
		# El seguimiento vertical (eje Y) es constante en todos los estados
		var directionY = global_position.direction_to(jugador.global_position).y
		velocity.y = directionY * speed

		match estado_actual:
			Estado.SIGUIENDO:
				velocity.x = 0
				animacion.play("preJefe")
				
			Estado.ATACANDO:
				var directionX = sign(jugador.global_position.x - global_position.x)
				if directionX == 0: directionX = 1 # Evitar multiplicaciones por cero
				velocity.x = directionX * speed_ataque
				animacion.play("pequeAtaque")
				
				# Detección de impacto por distancia
				var distancia_x = abs(global_position.x - jugador.global_position.x)
				var distancia_y = abs(global_position.y - jugador.global_position.y)
				
				# Si está lo suficientemente cerca en X y alineado en Y, es un golpe
				if distancia_x < 50.0 and distancia_y < 80.0: 
					if jugador.has_method("recibir_dano"):
						jugador.recibir_dano(directionX)
					estado_actual = Estado.REGRESANDO
					
			Estado.REGRESANDO:
				# Calculamos hacia dónde debe moverse para volver a su X original
				var dir_regreso = sign(posicion_x_original - global_position.x)
				velocity.x = dir_regreso * speed
				animacion.play("preJefe")
				
				# Condición de llegada: Si la diferencia entre su posición actual y la original es mínima
				if abs(global_position.x - posicion_x_original) < 10.0:
					velocity.x = 0
					estado_actual = Estado.SIGUIENDO

	move_and_slide()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if !sigueJugador and jugador == null: 
		# Buena práctica: asegurarnos de que lo que entró es realmente un jugador
		if body.is_in_group("player1") or body.is_in_group("player2"):
			jugador = body
			sigueJugador = true
			timer.start()
			print("Fijado objetivo: ", jugador.name)
	elif sigueJugador and jugador != null:
		print("Ya sigo al jugador: ", jugador.name)

func _on_timer_timeout() -> void:
	# El jefe solo debe decidir atacar si está en estado de seguimiento normal
	if estado_actual == Estado.SIGUIENDO:
		var numero = randi_range(1, 10)
		print("Dado tirado: ", numero)
		if numero > 5:
			print("¡Iniciando ataque!")
			# Guardamos la posición X en este exacto instante
			posicion_x_original = global_position.x
			estado_actual = Estado.ATACANDO
