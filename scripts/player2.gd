extends CharacterBody2D
@onready var brazo_izq := $Body/BrazoIzq
@onready var pierna_izq := $Body/PiernaIzq
signal proyectil_golpeado
const GRAVITY = 800.0
const JUMP_FORCE = -400.0
var SPEED = 200.0
var facing := 1.0
var locked := false
var estado_actual := ""
var atacando := false
var puede_atacar := true
var en_knockback := false

func _physics_process(delta: float) -> void:
	$Body/Torso.flip_h = facing == -1.0
	$Body/Head.flip_h = facing == -1.0
	$Body/BrazoDer.flip_h = facing == -1.0
	$Body/BrazoIzq.flip_h = facing == -1.0
	$Body/PiernaDer.flip_h = facing == -1.0
	$Body/PiernaIzq.flip_h = facing == -1.0
	if $RayArriba.is_colliding():
		velocity.x = 150.0 * facing
	var p1 = get_tree().get_first_node_in_group("player1")
	if p1 and not p1.en_knockback:
		var dist = global_position.distance_to(p1.global_position)
		if dist < 40.0:
			p1.recibir_dano(-p1.facing)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	var moving := false
	if not locked and not en_knockback:
		var direction := 0.0
		if Input.is_action_pressed("p2_move_right"):
			direction += 1.0
			facing = 1.0
			moving = true
		if Input.is_action_pressed("p2_move_left"):
			direction -= 1.0
			facing = -1.0
			moving = true
		velocity.x = direction * SPEED
		if Input.is_action_just_pressed("p2_move_up") and is_on_floor() and not $RayArriba.is_colliding():
			velocity.y = JUMP_FORCE
		velocity.x = direction * SPEED
	elif locked:
		velocity.x = 0.0
	if Input.is_action_just_pressed("p2_hit") and puede_atacar:
		_melee_attack()
	$MeleeArea/HitRight.disabled = facing != 1.0
	$MeleeArea/HitLeft.disabled = facing != -1.0
	move_and_slide()
	if not atacando:
		var nuevo_estado := ""
		var en_aire = not is_on_floor()
		if Global.es_tutorial:
			if en_aire:
				nuevo_estado = "saltando_sin"
			elif moving:
				nuevo_estado = "caminar"
			else:
				nuevo_estado = "idle_sin"
		else:
			if en_aire:
				nuevo_estado = "saltando_ox"
			elif moving:
				nuevo_estado = "caminar_ox"
			else:
				nuevo_estado = "idle_oxidado"
		if nuevo_estado != estado_actual:
			estado_actual = nuevo_estado
			if nuevo_estado == "saltando_sin":
				$Body/Torso.play("saltando_sin")
				$Body/Head.play("saltando_sin")
				$Body/BrazoDer.play("saltando_sin")
				$Body/BrazoIzq.play("saltando_sin")
				$Body/PiernaDer.play("saltando_sin")
				$Body/PiernaIzq.play("saltando_sin")
			elif nuevo_estado == "saltando_ox":
				$Body/Torso.play("saltando_ox")
				$Body/Head.play("saltando_ox")
				$Body/BrazoDer.play("saltando_ox")
				$Body/BrazoIzq.play("saltando_ox")
				$Body/PiernaDer.play("saltando_ox")
				$Body/PiernaIzq.play("saltando_ox")
			elif Global.es_tutorial:
				if moving:
					$Body/Torso.play("caminar")
					$Body/Head.play("caminar")
					$Body/BrazoDer.play("caminar")
					$Body/BrazoIzq.play("caminar")
					$Body/PiernaDer.play("caminar")
					$Body/PiernaIzq.play("caminar")
				else:
					$Body/Torso.play("idle_sin")
					$Body/Head.play("idle_sin")
					$Body/BrazoDer.play("idle")
					$Body/BrazoIzq.play("idle")
					$Body/PiernaDer.play("idle")
					$Body/PiernaIzq.play("idle")
			else:
				if moving:
					$Body/Torso.play("caminar_ox")
					$Body/Head.play("caminar_ox")
					$Body/BrazoDer.play("caminar_ox")
					$Body/BrazoIzq.play("caminar_ox")
					$Body/PiernaDer.play("caminar_ox")
					$Body/PiernaIzq.play("caminar_ox")
				else:
					$Body/Torso.play("idle_oxidado")
					$Body/Head.play("idle_oxidado")
					$Body/BrazoDer.play("idle")
					$Body/BrazoIzq.play("idle")
					$Body/PiernaDer.play("idle")
					$Body/PiernaIzq.play("idle")
	if atacando:
		if p1:
			var dist = global_position.distance_to(p1.global_position)
			if dist < 80.0 and sign(p1.global_position.x - global_position.x) == facing:
				p1.recibir_dano(facing)

func boost() -> void:
	SPEED *= 1.2

func lock_movement(forced_facing: float = 0.0) -> void:
	locked = true
	if forced_facing != 0.0:
		facing = forced_facing

func _ready() -> void:
	add_to_group("player2")
	$MeleeArea/HitRight.disabled = true
	$MeleeArea/HitLeft.disabled = true
	$MeleeArea.monitoring = false
	$MeleeArea.connect("area_entered", _on_melee_hit)
	estado_actual = ""
	actualizar_cuerpo()

func _melee_attack() -> void:
	puede_atacar = false
	atacando = true
	estado_actual = ""
	var anim := ""
	if not is_on_floor() and not Global.es_tutorial:
		anim = "atk_jump"
	elif Global.es_tutorial:
		anim = "atk_sin"
	else:
		anim = "atk_ox"
	$Body.position.y -= 15.0
	$Body/Torso.play(anim)
	$Body/Head.play(anim)
	$Body/BrazoDer.play(anim)
	$Body/BrazoIzq.play(anim)
	$Body/PiernaDer.play(anim)
	$Body/PiernaIzq.play(anim)
	$MeleeArea.monitoring = true
	await get_tree().create_timer(0.5).timeout
	$MeleeArea.monitoring = false
	$Body.position.y += 15.0
	atacando = false
	estado_actual = ""
	puede_atacar = true

func actualizar_cuerpo() -> void:
	brazo_izq.visible = Global.vida_crusty > 3
	pierna_izq.visible = Global.vida_crusty > 2

func _on_melee_hit(area: Area2D) -> void:
	if area.name == "HitArea":
		emit_signal("proyectil_golpeado")
		var proj = area.get_parent()
		var speed = abs(proj.direction.x)
		proj.hit_redirect(Vector2(-proj.direction.x, -speed * 1.732).normalized() * speed * 1.2)
	elif area.name == "HurtBox":
		if Global.es_tutorial:
			return
		var mitch = get_tree().get_first_node_in_group("player1")
		var knockback_dir = sign(mitch.global_position.x - global_position.x)
		mitch.recibir_dano(knockback_dir)

func recibir_dano_liquido() -> void:
	Global.vida_crusty -= 1
	actualizar_cuerpo()
	_flash_dano()

func _flash_dano() -> void:
	var partes = [$Body/Head, $Body/Torso, $Body/BrazoDer, $Body/BrazoIzq, $Body/PiernaDer, $Body/PiernaIzq]
	for parte in partes:
		parte.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.5).timeout
	for parte in partes:
		parte.modulate = Color(1, 1, 1)
		
func recibir_dano(knockback_dir: float) -> void:
	if en_knockback:
		return
	Global.vida_crusty -= 1
	actualizar_cuerpo()
	_flash_dano()
	en_knockback = true
	velocity.x = knockback_dir * 150.0
	await get_tree().create_timer(0.5).timeout
	en_knockback = false
