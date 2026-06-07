extends CharacterBody2D

const SPEED = 200.0
@export var vida: int = 1
@onready var animacion :AnimatedSprite2D = $AnimatedSprite2D
var activo: bool = false # Controla si ya pasaron los 3 segundos
@onready var sonido_dano := $SonidoDano
@onready var rayoIzq: RayCast2D = $rayIzq
@onready var rayoDer: RayCast2D = $rayDer
var destruido: bool = false

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
	# Si no está activo o YA se destruyó, ignoramos el daño
	if !activo or destruido:
		return
		
	dano_recibido = dano_recibido * -1
	vida -= int(dano_recibido)
	
	sonido_dano.pitch_scale = 0.35
	sonido_dano.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_dano.play()
	
	# Evaluamos la muerte INMEDIATAMENTE, antes del await visual
	if vida <= 0:
		destruido = true # Ponemos el candado para ignorar más impactos
		_destruir_motor()
		return # Cortamos la función aquí para no hacer el parpadeo rojo
	
	# Si sobrevive, hacemos el parpadeo de daño
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	
	# Verificamos que el jefe siga existiendo antes de devolverle el color
	if is_inside_tree():
		modulate = Color(1, 1, 1)

func _destruir_motor() -> void:
	print("¡Motor destruido! Iniciando transición...")
	activar_final()
	
func activar_final() -> void:
	# CRÍTICO: Guardamos la referencia al SceneTree ANTES de que el tiempo pase
	var arbol_escena = get_tree()
	
	if Global.contador_antioxidantes >= 3:
		Global.final_bueno = true
		await FadeManager.fade_out()
		# Usamos nuestra referencia guardada en lugar de buscar el árbol de nuevo
		arbol_escena.change_scene_to_file("res://cinematicas/FinalBueno/FinalBueno.tscn")
	else:
		Global.final_bueno = false
		await FadeManager.fade_out()
		arbol_escena.change_scene_to_file("res://cinematicas/FinalMalo/FinalMalo.tscn")
