extends CharacterBody2D

@export var speed: float = 100
@export var speed_ataque: float = 300 
var sigueJugador: bool = false
@onready var sonido_dano := $SonidoDano
@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $hitBox
@onready var hurtbox: Area2D = $hurtbox
@onready var timer: Timer = $Timer
@onready var abajo: RayCast2D = $abajo
@onready var izq: RayCast2D = $izq
@onready var der: RayCast2D = $der

var jugador: Node2D = null	
var cambioFase2: bool = false

# --- LA MÁQUINA DE ESTADOS COMPLETA ---
enum Estado { SIGUIENDO, ATACANDO, REGRESANDO, FASE2, PATRULLA_FASE2, CAIDA_FASE2, SUBIDA_FASE2 }
var estado_actual = Estado.SIGUIENDO

var posicion_x_original: float = -255.0
var faseDos: Vector2 = Vector2(-255.0, -550.0)

func _ready() -> void:
	add_to_group("jefe")

func _physics_process(delta: float) -> void:
	
	# Failsafe: Evitamos crashes en Fase 1 si el jugador desaparece, pero dejamos 
	# que la Fase 2 fluya sin depender de que el jugador esté guardado en la variable.
	if estado_actual in [Estado.SIGUIENDO, Estado.ATACANDO] and (jugador == null or not is_instance_valid(jugador)):
		return 
		
	match estado_actual:
		Estado.SIGUIENDO:
			# Fase 1: Sigue en Y, espera en X
			velocity.y = global_position.direction_to(jugador.global_position).y * speed
			velocity.x = 0
			animacion.play("preJefe")
			
		Estado.ATACANDO:
			# Fase 1: Ataque lateral
			velocity.y = global_position.direction_to(jugador.global_position).y * speed
			
			var directionX = sign(jugador.global_position.x - global_position.x)
			if directionX == 0: directionX = 1
			velocity.x = directionX * speed_ataque
			animacion.play("pequeAtaque")
			
			var distancia_x = abs(global_position.x - jugador.global_position.x)
			var distancia_y = abs(global_position.y - jugador.global_position.y)
			
			# Comprueba impacto por distancia
			if distancia_x < 50.0 and distancia_y < 80.0: 
				if jugador.has_method("recibir_dano"):
					jugador.recibir_dano(directionX)
				estado_actual = Estado.REGRESANDO
				
		Estado.REGRESANDO:
			# Fase 1: Retorno a la posición base
			if is_instance_valid(jugador):
				velocity.y = global_position.direction_to(jugador.global_position).y * speed
			else:
				velocity.y = 0
				
			var dir_regreso = sign(posicion_x_original - global_position.x)
			velocity.x = dir_regreso * speed
			animacion.play("preJefe")
			
			if abs(global_position.x - posicion_x_original) < 10.0:
				velocity.x = 0
				estado_actual = Estado.SIGUIENDO
			
		Estado.FASE2:
			# Transición inicial hacia arriba
			animacion.play("jefeHabla")
			var distancia = global_position.distance_to(faseDos)
			
			if distancia > 10.0:
				velocity = global_position.direction_to(faseDos) * speed
			else:
				# Clavado en el punto exacto e inicia patrulla
				velocity = Vector2.ZERO
				global_position = faseDos 
				estado_actual = Estado.PATRULLA_FASE2
				velocity.x = speed 
				
		Estado.PATRULLA_FASE2:
			# Fase 2: Movimiento lateral arriba
			velocity.y = 0 
			
			# Rebote con paredes
			if der.is_colliding() and velocity.x > 0:
				velocity.x = -speed
			elif izq.is_colliding() and velocity.x < 0:
				velocity.x = speed
				
			# Failsafe si la velocidad llega a cero por algún bug físico
			if velocity.x == 0: velocity.x = speed 
				
			# Radar hacia abajo
			if abajo.is_colliding():
				var objetivo = abajo.get_collider()
				if objetivo and (objetivo.is_in_group("player1") or objetivo.is_in_group("player2")):
					jugador = objetivo 
					estado_actual = Estado.CAIDA_FASE2
					velocity.x = 0 
					animacion.play("pequeAtaque")
					
		Estado.CAIDA_FASE2:
			# Fase 2: Smash hacia abajo
			velocity.y = speed_ataque * 1.5 
			
			var impacto_jugador = false
			if is_instance_valid(jugador) and global_position.distance_to(jugador.global_position) < 60.0:
				impacto_jugador = true
				
			if is_on_floor() or impacto_jugador:
				if impacto_jugador and jugador.has_method("recibir_dano"):
					var dirX = sign(jugador.global_position.x - global_position.x)
					if dirX == 0: dirX = 1
					jugador.recibir_dano(dirX)
					animacion.play("hurtJefe")
					
				estado_actual = Estado.SUBIDA_FASE2
				
		Estado.SUBIDA_FASE2:
			# Fase 2: Retorno al techo
			velocity.y = -speed
			velocity.x = 0
			
			
			if global_position.y <= faseDos.y:
				global_position.y = faseDos.y 
				estado_actual = Estado.PATRULLA_FASE2
				velocity.x = speed 
				animacion.play("preJefe")

	move_and_slide()

# --- FUNCIONES DE SEÑALES ---

func cambioFase(llegaron: bool) -> void:
	if llegaron and estado_actual != Estado.FASE2:
		cambioFase2 = true
		timer.stop() 
		estado_actual = Estado.FASE2 
		speed = 200

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if !sigueJugador and jugador == null: 
		if body.is_in_group("player1") or body.is_in_group("player2"):
			jugador = body
			sigueJugador = true
			timer.start()
			print("Fijado objetivo inicial: ", jugador.name)
	elif sigueJugador and jugador != null:
		print("Ya sigo al jugador: ", jugador.name)

func _on_timer_timeout() -> void:
	if estado_actual == Estado.SIGUIENDO:
		var numero = randi_range(1, 10)
		print("Dado de jefe tirado: ", numero)
		if numero > 5:
			print("¡Iniciando ataque lateral!")
			posicion_x_original = global_position.x
			estado_actual = Estado.ATACANDO
