extends CharacterBody2D

const SPEED = 200.0
@export var vida: int = 3
@onready var animacion :AnimatedSprite2D = $AnimatedSprite2D
var activo: bool = false # Controla si ya pasaron los 3 segundos

@onready var rayoIzq: RayCast2D = $rayIzq
@onready var rayoDer: RayCast2D = $rayDer

func _ready() -> void:
	# 1. El motor empieza completamente quieto
	velocity = Vector2.ZERO
	add_to_group("jefe")
	animacion.play("motor")
	
	# 2. Esperamos 3 segundos exactos sin congelar el resto del juego
	await get_tree().create_timer(3.0).timeout
	
	# 3. ¡Se acabó el tiempo! Lo activamos y le damos un empuje inicial
	activo = true
	velocity.x = SPEED
	print("¡El motor ahora es vulnerable y se está moviendo!")

func _physics_process(delta: float) -> void:
	# Si no está activo, no calculamos físicas
	if !activo:
		return
		
	# Bloqueamos el eje Y para asegurar que NUNCA suba o baje
	velocity.y = 0
	
	# Lógica de rebote automático usando tus RayCasts
	if rayoDer.is_colliding() and velocity.x > 0:
		velocity.x = -SPEED # Invierte hacia la izquierda
	elif rayoIzq.is_colliding() and velocity.x < 0:
		velocity.x = SPEED  # Invierte hacia la derecha
		
	move_and_slide()

# Esta función debe ser llamada por el proyectil del Jugador 1 al chocar
# Asumo que tu proyectil usa algo como if body.has_method("recibir_dano"): body.recibir_dano()
func recibir_dano(dano_recibido: float = 1.0) -> void:
	# Si el Jugador 1 le dispara antes de los 3 segundos, tiene armadura de trama (ignora el daño)
	dano_recibido =dano_recibido*-1
	if !activo:
		print("Motor invulnerable aún...")
		return
		
	vida -= int(dano_recibido)
	print("¡Impacto al motor! Vida restante: ", vida)
	
	# Feedback visual rápido de ingeniero a jugador
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		_destruir_motor()

func _destruir_motor() -> void:
	print("¡Motor destruido! Reiniciando la escena para comprobar que funciona...")
	get_tree().reload_current_scene()
