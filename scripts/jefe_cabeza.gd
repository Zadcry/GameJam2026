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
var cambioFase2: bool = false


enum Estado { SIGUIENDO, ATACANDO, REGRESANDO, FASE2 }
var estado_actual = Estado.SIGUIENDO
var posicion_x_original: float = -255.0

var faseDos:Vector2 = Vector2(-255.0, -550.0)

func _ready() -> void:
	add_to_group("jefe")

func _physics_process(delta: float) -> void:
	# Verificación de seguridad base
	if jugador == null or not is_instance_valid(jugador):
		return # Si no hay jugador, no calculamos físicas para evitar crashes
		
	match estado_actual:
		Estado.SIGUIENDO:
			# Aquí SÍ seguimos al jugador en Y
			velocity.y = global_position.direction_to(jugador.global_position).y * speed
			velocity.x = 0
			animacion.play("preJefe")
			
		Estado.ATACANDO:
			# Mantenemos el seguimiento en Y mientras ataca
			velocity.y = global_position.direction_to(jugador.global_position).y * speed
			
			var directionX = sign(jugador.global_position.x - global_position.x)
			if directionX == 0: directionX = 1
			velocity.x = directionX * speed_ataque
			animacion.play("pequeAtaque")
			
			var distancia_x = abs(global_position.x - jugador.global_position.x)
			var distancia_y = abs(global_position.y - jugador.global_position.y)
			
			if distancia_x < 50.0 and distancia_y < 80.0: 
				if jugador.has_method("recibir_dano"):
					jugador.recibir_dano(directionX)
				estado_actual = Estado.REGRESANDO
				
		Estado.REGRESANDO:
			# Mantenemos el seguimiento en Y mientras regresa a su posición
			velocity.y = global_position.direction_to(jugador.global_position).y * speed
			
			var dir_regreso = sign(posicion_x_original - global_position.x)
			velocity.x = dir_regreso * speed
			animacion.play("preJefe")
			
			if abs(global_position.x - posicion_x_original) < 10.0:
				velocity.x = 0
				estado_actual = Estado.SIGUIENDO
			
		Estado.FASE2:
			# Ya no seguimos al jugador en Y, vamos directo al punto de la Fase 2
			animacion.play("jefeHabla")
			
			# Comprobamos a qué distancia estamos del punto objetivo
			var distancia = global_position.distance_to(faseDos)
			
			if distancia > 10.0:
				# Si estamos lejos, calculamos la dirección correcta y avanzamos
				velocity = global_position.direction_to(faseDos) * speed
			else:
				# ¡Llegamos! Detenemos la velocidad y forzamos la posición exacta para no temblar
				velocity = Vector2.ZERO
				global_position = faseDos 
				
				# ---> AQUÍ puedes meter la lógica de lo que pasa después de llegar a Fase 2 <---
				# Por ejemplo: estado_actual = Estado.ATACANDO_FASE_2

	move_and_slide()

# La señal del Area2D solo debe cambiar el estado e inicializar lo necesario
func cambioFase(llegaron: bool) -> void:
	if llegaron and estado_actual != Estado.FASE2:
		cambioFase2 = true
		timer.stop() # Apagamos el timer para que no decida atacar de la nada
		estado_actual = Estado.FASE2 # Usamos nuestra máquina de estados como se debe

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
