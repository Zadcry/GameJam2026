extends CharacterBody2D

@onready var sonido_dano := $SonidoDano

enum State { PATROL, CHASE, ATTACK, STUNNED}
var current_state = State.PATROL
var is_invulnerable := false

const GRAVITY = 800.0
const SPEED_PATROL = 100.0
const SPEED_CHASE = 220.0
const ATTACK_RANGE = 50.0

@export var patrol_distance := 100.0
@export var vision_range := 200.0
var point_a: float
var point_b: float

var health := 2
var facing := 1.0
var is_attacking := false
var target_player: Node2D = null
var estado_actual := ""

func _ready() -> void:
	point_a = global_position.x - patrol_distance
	point_b = global_position.x + patrol_distance
	$SpriteAnimado.play("idle")
	estado_actual = "idle"

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
			velocity.x = 0.0

	_check_vision()
	_check_damage()

	if facing != 0.0:
		$Vision.target_position = Vector2(facing * vision_range, 0)
		$SpriteAnimado.flip_h = facing == 1.0

	move_and_slide()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	var nuevo_estado := ""
	match current_state:
		State.STUNNED:
			nuevo_estado = "stunned"
		State.ATTACK:
			nuevo_estado = "attack"
		State.CHASE:
			nuevo_estado = "walk"
		State.PATROL:
			if abs(velocity.x) > 5.0:
				nuevo_estado = "walk"
			else:
				nuevo_estado = "idle"
	if nuevo_estado != estado_actual:
		estado_actual = nuevo_estado
		$SpriteAnimado.play(nuevo_estado)

func _patrol_logic() -> void:
	velocity.x = facing * SPEED_PATROL
	if global_position.x <= point_a:
		facing = 1.0
	elif global_position.x >= point_b:
		facing = -1.0

func _chase_logic() -> void:
	if target_player == null: return
	facing = sign(target_player.global_position.x - global_position.x)
	if facing == 0: facing = 1.0
	velocity.x = facing * SPEED_CHASE
	var distance_to_player = abs(target_player.global_position.x - global_position.x)
	if distance_to_player <= ATTACK_RANGE:
		current_state = State.ATTACK

func _attack_logic() -> void:
	velocity.x = 0.0
	if is_attacking: return
	is_attacking = true
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(self): return
	if is_instance_valid(target_player):
		var distance = abs(target_player.global_position.x - global_position.x)
		if distance <= ATTACK_RANGE + 15.0:
			if target_player.has_method("recibir_dano"):
				var knockback_dir = sign(target_player.global_position.x - global_position.x)
				if knockback_dir == 0.0: knockback_dir = facing
				target_player.recibir_dano(knockback_dir)
	await get_tree().create_timer(0.8).timeout
	if not is_instance_valid(self): return
	is_attacking = false
	current_state = State.PATROL

func _check_vision() -> void:
	if current_state == State.ATTACK or current_state == State.STUNNED: return
	if $Vision.is_colliding():
		var collider = $Vision.get_collider()
		if collider and (collider.name == "Player1" or collider.name == "Player2"):
			target_player = collider
			current_state = State.CHASE
	else:
		if current_state == State.CHASE:
			target_player = null
			current_state = State.PATROL

func _check_damage() -> void:
	for area in $Hurtbox.get_overlapping_areas():
		if area.name == "HitArea" and area.get_parent().has_method("hit_redirect"):
			_apply_stun()

func _apply_stun() -> void:
	if current_state == State.STUNNED: return
	current_state = State.STUNNED
	is_attacking = false
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(self):
		if not is_invulnerable:
			$SpriteAnimado.modulate = Color(1, 1, 1)
		current_state = State.PATROL

func recibir_dano_melee() -> void:
	if is_invulnerable: return
	is_invulnerable = true
	sonido_dano.pitch_scale = 1.5
	sonido_dano.volume_db = linear_to_db(Global.sfx_volume / 100.0)
	sonido_dano.play()
	health -= 1
	$SpriteAnimado.modulate = Color(1, 0, 0)
	if health <= 0:
		queue_free()
	else:
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(self):
			if current_state == State.STUNNED:
				$SpriteAnimado.modulate = Color(0.3, 0.5, 1.0)
			else:
				$SpriteAnimado.modulate = Color(1, 1, 1)
			is_invulnerable = false
