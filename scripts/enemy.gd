extends CharacterBody2D

# Definimos los posibles estados del enemigo
enum State { PATROL, CHASE, ATTACK, STUNNED}
var current_state = State.PATROL
var is_invulnerable := false

const GRAVITY = 800.0
const SPEED_PATROL = 100.0
const SPEED_CHASE = 220.0
const ATTACK_RANGE = 50.0 # Distancia a la que se detiene a atacar

@export var patrol_distance := 200.0 # Distancia desde su punto de inicio
var point_a: float
var point_b: float

var health := 2
var facing := 1.0
var is_attacking := false
var target_player: Node2D = null

func _ready() -> void:
	# Calculamos Punto A y Punto B automáticamente según dónde pongas al enemigo
	point_a = global_position.x - patrol_distance
	point_b = global_position.x + patrol_distance

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	match current_state:
		State.PATROL:
			_patrol_logic()
		State.CHASE:
			_chase_logic()
		State.ATTACK:
			_attack_logic()
		State.STUNNED:
			velocity.x = 0.0 # Si está stuneado, no se mueve en absoluto
			
	_check_vision()
	_check_damage() 
	
	# Solo actualizamos hacia dónde mira si NO está stuneado
	if facing != 0.0 and current_state != State.STUNNED:
		$Vision.target_position = Vector2(facing * 200, 0)
		$Sprite2D.flip_h = facing == -1.0

	move_and_slide()

# --- LÓGICA DE ESTADOS ---

func _patrol_logic() -> void:
	velocity.x = facing * SPEED_PATROL
	
	# Si llega al punto A, voltea al punto B y viceversa
	if global_position.x <= point_a:
		facing = 1.0
	elif global_position.x >= point_b:
		facing = -1.0

func _chase_logic() -> void:
	if target_player == null: return
	
	# Calcula la dirección hacia el jugador
	facing = sign(target_player.global_position.x - global_position.x)
	if facing == 0: facing = 1.0
	
	velocity.x = facing * SPEED_CHASE
	
	# Si está lo suficientemente cerca, pasa al estado de ataque
	var distance_to_player = abs(target_player.global_position.x - global_position.x)
	if distance_to_player <= ATTACK_RANGE:
		current_state = State.ATTACK

func _attack_logic() -> void:
	velocity.x = 0.0 # Se detiene para atacar
	
	if is_attacking: return
	is_attacking = true
	
	print("¡El enemigo está atacando!")
	# AQUÍ VA TU LÓGICA DE ATAQUE (Animaciones, quitarle vida al jugador, etc.)
	
	# Espera 1 segundo (cooldown del ataque) antes de poder moverse o atacar de nuevo
	await get_tree().create_timer(1.0).timeout 
	
	is_attacking = false
	current_state = State.PATROL # Vuelve a evaluar su entorno

# --- VISIÓN Y DAÑO ---

func _check_vision() -> void:
	# Ignorar la visión si está atacando O stuneado
	if current_state == State.ATTACK or current_state == State.STUNNED: return
	
	if $Vision.is_colliding():
		var collider = $Vision.get_collider()
		# Verifica si lo que vio fue a alguno de los jugadores
		if collider and (collider.name == "Player1" or collider.name == "Player2"):
			target_player = collider
			current_state = State.CHASE
	else:
		# Si pierde de vista al jugador, vuelve a patrullar
		if current_state == State.CHASE:
			target_player = null
			current_state = State.PATROL

func _check_damage() -> void:
	# Revisamos las áreas que se solapan en este frame
	for area in $Hurtbox.get_overlapping_areas():
		
		# 1. CHEQUEO DE DAÑO (Player 2)
		if area.name == "MeleeArea" and area.monitoring == true and not is_invulnerable:
			is_invulnerable = true 
			health -= 1
			print("Enemigo herido. Vida restante: ", health)
			
			$Sprite2D.modulate = Color(1, 0, 0) # Rojo al recibir daño
			
			if health <= 0:
				queue_free() 
			else:
				await get_tree().create_timer(0.3).timeout
				if is_instance_valid(self): 
					# Si sobrevive y está stuneado, vuelve al color azul; si no, a blanco
					if current_state == State.STUNNED:
						$Sprite2D.modulate = Color(0.3, 0.5, 1.0) 
					else:
						$Sprite2D.modulate = Color(1, 1, 1) 
					is_invulnerable = false 
			break 
			
		# 2. CHEQUEO DE STUN (Player 1)
		elif area.name == "HitArea" and area.get_parent().has_method("hit_redirect"):
			_apply_stun()

func _apply_stun() -> void:
	# Si ya está stuneado, no reiniciamos el contador de tiempo ni hacemos nada
	if current_state == State.STUNNED: return
	
	current_state = State.STUNNED
	is_attacking = false # Cancelamos su ataque si estaba a punto de pegar
	$Sprite2D.modulate = Color(0.3, 0.5, 1.0) # Color azul para indicar "Stun"
	print("Enemigo aturdido!")
	
	# El enemigo queda aturdido por 2 segundos (puedes ajustar este número)
	await get_tree().create_timer(2.0).timeout
	
	if is_instance_valid(self):
		# Al terminar el stun, lo devolvemos a patrullar si no está recibiendo daño en ese frame
		if not is_invulnerable:
			$Sprite2D.modulate = Color(1, 1, 1)
		current_state = State.PATROL
