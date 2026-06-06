extends CharacterBody2D
const SPEED = 200.0
const GRAVITY = 800.0
const JUMP_FORCE = -400.0
const MIN_POWER = 150.0
const MAX_POWER = 800.0
const CHARGE_RATE = 300.0

@export var projectile_scene: PackedScene
var can_shoot := true
var facing := 1.0
var charge := 0.0
var charging := false
var locked := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if not locked:
		var direction := 0.0
		if Input.is_action_pressed("p1_move_right"):
			direction += 1.0
			facing = 1.0
		if Input.is_action_pressed("p1_move_left"):
			direction -= 1.0
			facing = -1.0
		velocity.x = direction * SPEED
		if Input.is_action_just_pressed("p1_move_up") and is_on_floor():
			velocity.y = JUMP_FORCE
	else:
		velocity.x = 0.0

	# Cargar mientras se mantiene E
	if Input.is_action_pressed("p1_shoot") and can_shoot:
		charging = true
		charge = min(charge + CHARGE_RATE * delta, MAX_POWER)

	# Soltar E para disparar
	if Input.is_action_just_released("p1_shoot") and can_shoot and charging:
		_shoot()

	move_and_slide()

func lock_movement(forced_facing: float = 0.0) -> void:
	locked = true
	if forced_facing != 0.0:
		facing = forced_facing

func _shoot() -> void:
	charging = false
	can_shoot = false
	var power = max(charge, MIN_POWER)
	charge = 0.0

	var proj = projectile_scene.instantiate()
	proj.global_position = global_position
	get_parent().add_child(proj)
	proj.direction = Vector2(facing * power, -power * 0.0875)

	await get_tree().create_timer(2.0).timeout
	can_shoot = true
