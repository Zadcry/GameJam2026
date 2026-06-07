extends CharacterBody2D

const GRAVITY = 800.0
const JUMP_FORCE = -400.0
const MIN_POWER = 150.0
const MAX_POWER = 800.0
const CHARGE_RATE = 500.0

@export var projectile_scene: PackedScene

var SPEED = 200.0
var can_shoot := true
var facing := 1.0
var charge := 0.0
var charging := false
var locked := false
var estado_actual := ""
var moving := false
var disparando := false
var en_knockback := false
var d_bloqueada := false
var a_bloqueada := false
var d_estado := 6
var a_estado := 6

var texturas_d: Array[Texture2D] = []
var texturas_a: Array[Texture2D] = []

func _get_ui():
	return get_tree().get_first_node_in_group("ui_canvas")

func _physics_process(delta: float) -> void:
	if $RayArriba.is_colliding():
		velocity.x = 150.0 * facing

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	moving = false

	var nivel = Global.oxido_mitch
	var ui = _get_ui()

	if nivel > 15.0 and not d_bloqueada and d_estado == 6:
		d_bloqueada = true
		if ui:
			ui.mostrar_d(texturas_d[d_estado])

	if nivel > 20.0 and not a_bloqueada and a_estado == 6:
		a_bloqueada = true
		if ui:
			ui.mostrar_a(texturas_a[a_estado])

	if d_bloqueada and Input.is_action_just_pressed("p1_move_right"):
		d_estado -= 1
		if d_estado <= 0:
			d_bloqueada = false
			d_estado = -1
			if ui:
				ui.ocultar_d()
		else:
			if ui:
				ui.mostrar_d(texturas_d[d_estado])

	if a_bloqueada and Input.is_action_just_pressed("p1_move_left"):
		a_estado -= 1
		if a_estado <= 0:
			a_bloqueada = false
			a_estado = -1
			if ui:
				ui.ocultar_a()
		else:
			if ui:
				ui.mostrar_a(texturas_a[a_estado])

	if not locked and not en_knockback:
		var direction := 0.0
		if Input.is_action_pressed("p1_move_right") and not d_bloqueada:
			direction += 1.0
			facing = 1.0
			moving = true
			if charging:
				charging = false
				charge = 0.0
				estado_actual = ""
		if Input.is_action_pressed("p1_move_left") and not a_bloqueada:
			direction -= 1.0
			facing = -1.0
			moving = true
			if charging:
				charging = false
				charge = 0.0
				estado_actual = ""
		velocity.x = direction * SPEED
		if Input.is_action_just_pressed("p1_move_up") and is_on_floor() and not $RayArriba.is_colliding():
			velocity.y = JUMP_FORCE
			if charging:
				charging = false
				charge = 0.0
				estado_actual = ""
	elif locked:
		velocity.x = 0.0

	if not is_on_floor():
		if charging:
			charging = false
			charge = 0.0
			estado_actual = ""
	elif Input.is_action_pressed("p1_shoot") and can_shoot:
		charging = true
		charge = min(charge + CHARGE_RATE * delta, MAX_POWER)

	if Input.is_action_just_released("p1_shoot") and can_shoot and charging and is_on_floor():
		_shoot()

	move_and_slide()

	$animation.flip_h = facing == -1.0
	# (Aquí arriba debe estar tu move_and_slide() y tus animaciones)

	# === SISTEMA DE TRAMPAS POR TILEMAP ===
	var mapa = get_tree().get_first_node_in_group("mapa_trampas")
	
	if mapa and not en_knockback:
		# 1. Calculamos la posición de los pies del jugador
		# (Suma en Y si el centro de tu jugador está en su ombligo y no en sus pies)
		var pos_pies = global_position + Vector2(0, 20) 
		
		# 2. Convertimos esa posición global a coordenadas exactas de la cuadrícula (X, Y)
		var celda = mapa.local_to_map(mapa.to_local(pos_pies))
		
		# 3. Le pedimos a la celda su información
		var data = mapa.get_cell_tile_data(celda)
		
		if data:
			# 4. Revisamos si tiene activada nuestra capa personalizada
			if data.get_custom_data("es_oxido") == true:
				
				# Calculamos el centro exacto de la celda para el Knockback
				var centro_tile = mapa.to_global(mapa.map_to_local(celda))
				var knockback_dir = sign(global_position.x - centro_tile.x)
				
				# Respaldo por si cae exactamente en el centro del píxel
				if knockback_dir == 0.0: knockback_dir = -facing 
				
				# ¡Aplicamos el daño!
				recibir_dano(knockback_dir)
				
	if charging:
		var anim_atk := ""
		if nivel < 12.0:
			anim_atk = "atk_ox0"
		elif nivel < 22.0:
			anim_atk = "atk_ox1"
		elif nivel < 30.0:
			anim_atk = "atk_ox2"
		else:
			anim_atk = "atk_ox3"
		if estado_actual != anim_atk:
			estado_actual = anim_atk
			$animation.play(anim_atk)
			$animation.pause()
		var progreso = (charge - MIN_POWER) / (MAX_POWER - MIN_POWER)
		progreso = clamp(progreso, 0.0, 1.0)
		$animation.frame = int(progreso * 5.0)
	elif not disparando:
		var nuevo_estado := ""
		var en_aire = not is_on_floor()
		if en_aire:
			if nivel < 12.0:
				nuevo_estado = "jump_ox0"
			elif nivel < 22.0:
				nuevo_estado = "jump_ox1"
			elif nivel < 30.0:
				nuevo_estado = "jump_ox2"
			else:
				nuevo_estado = "jump_ox3"
		elif moving:
			if nivel < 12.0:
				nuevo_estado = "walk_ox0"
			elif nivel < 22.0:
				nuevo_estado = "walk_ox1"
			elif nivel < 30.0:
				nuevo_estado = "walk_ox2"
			else:
				nuevo_estado = "walk_ox3"
		else:
			if nivel < 12.0:
				nuevo_estado = "idle_ox0"
			elif nivel < 22.0:
				nuevo_estado = "idle_ox1"
			else:
				nuevo_estado = "idle_ox2"
		if nuevo_estado != estado_actual:
			estado_actual = nuevo_estado
			$animation.play(nuevo_estado)

func _ready() -> void:
	add_to_group("player1")
	estado_actual = ""
	for i in range(7):
		texturas_d.append(load("res://sprites/teclas/a_and_d/D/D_Sprite_" + str(i) + ".png"))
		texturas_a.append(load("res://sprites/teclas/a_and_d/A/A_Sprite_" + str(i) + ".png"))

func aplicar_oxido() -> void:
	var nivel = Global.oxido_mitch
	if nivel >= 50.0:
		SPEED = 200.0 * 0.4
	elif nivel >= 30.0:
		SPEED = 200.0 * 0.5
	elif nivel >= 15.0:
		SPEED = 200.0 * 0.6

func recibir_dano(knockback_dir: float) -> void:
	if en_knockback:
		return
	Global.oxido_mitch += randf_range(3.0, 6.0)
	aplicar_oxido()
	_flash_dano()
	en_knockback = true
	velocity.x = knockback_dir * 100.0
	velocity.y = knockback_dir * -300.0
	await get_tree().create_timer(0.5).timeout
	en_knockback = false

func _flash_dano() -> void:
	$animation.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.5).timeout
	$animation.modulate = Color(1, 1, 1)

func lock_movement(forced_facing: float = 0.0) -> void:
	locked = true
	if forced_facing != 0.0:
		facing = forced_facing

func _shoot() -> void:
	charging = false
	can_shoot = false
	disparando = true
	$animation.frame = 6
	var power = max(charge, MIN_POWER)
	charge = 0.0
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position + Vector2(0, -30)
	get_parent().add_child(proj)
	proj.direction = Vector2(facing * power, -power * 0.0875)
	await get_tree().create_timer(0.3).timeout
	disparando = false
	estado_actual = ""
	await get_tree().create_timer(0.2).timeout
	can_shoot = true
