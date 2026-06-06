extends CharacterBody2D

signal proyectil_golpeado

const GRAVITY = 800.0
const JUMP_FORCE = -400.0

var SPEED = 200.0
var facing := 1.0
var locked := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if not locked:
		var direction := 0.0
		if Input.is_action_pressed("p2_move_right"):
			direction += 1.0
			facing = 1.0
		if Input.is_action_pressed("p2_move_left"):
			direction -= 1.0
			facing = -1.0
		velocity.x = direction * SPEED

		if Input.is_action_just_pressed("p2_move_up") and is_on_floor():
			velocity.y = JUMP_FORCE
	else:
		velocity.x = 0.0
	if Input.is_action_just_pressed("p2_hit"):
		_melee_attack()
	# Actualiza el shape activo según facing
	$MeleeArea/HitRight.disabled = facing != 1.0
	$MeleeArea/HitLeft.disabled = facing != -1.0
	move_and_slide()

func boost() -> void:
	SPEED *= 1.2

func lock_movement(forced_facing: float = 0.0) -> void:
	locked = true
	if forced_facing != 0.0:
		facing = forced_facing

func _ready() -> void:
	$MeleeArea/HitRight.disabled = true
	$MeleeArea/HitLeft.disabled = true
	$MeleeArea.monitoring = false
	$MeleeArea.connect("area_entered", _on_melee_hit)

func _melee_attack() -> void:
	$MeleeArea.monitoring = true
	await get_tree().create_timer(0.1).timeout
	$MeleeArea.monitoring = false

func _on_melee_hit(area: Area2D) -> void:
	if area.name == "HitArea":
		print("golpeado")
		emit_signal("proyectil_golpeado")
		var proj = area.get_parent()
		var speed = abs(proj.direction.x)
		proj.hit_redirect(Vector2(-proj.direction.x, -speed * 1.732).normalized() * speed * 1.2)
