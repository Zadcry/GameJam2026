extends Area2D

var SPEED = 400.0
var direction := Vector2.RIGHT
const PROJ_GRAVITY = 200.0
var _ya_impacto := false  # guarda para evitar doble impacto

func _ready() -> void:
	$HitArea.connect("area_entered", _on_hit)
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)
	# Desactivar monitoring hasta el siguiente frame para evitar
	# colisiones espurias al instanciar
	set_deferred("monitoring", true)
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	direction.y += PROJ_GRAVITY * delta
	position += direction * delta

func boost() -> void:
	SPEED *= 1.2

func hit_redirect(new_dir: Vector2) -> void:
	direction = new_dir

func _on_hit(_area: Area2D) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if _ya_impacto:
		return
	_ya_impacto = true
	# Diferir TODO para salir completamente del flush de física
	call_deferred("_resolver_impacto_body", body, direction)

func _resolver_impacto_body(body: Node2D, dir: Vector2) -> void:
	if not is_instance_valid(self):
		return
	if body.is_in_group("player2") or body.is_in_group("jefe"):
		var knockback_dir = sign(dir.x)
		body.recibir_dano(knockback_dir)
	else:
		var es_pared = abs(dir.x) > abs(dir.y) * 3.0
		if not es_pared:
			var explosion_scene = preload("res://scenes/ExplosionArea.tscn")
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			if dir.y < 0:
				explosion.scale.y = -1.0
			get_parent().add_child(explosion)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name != "HitArea" and area.name != "MeleeArea":
		if _ya_impacto:
			return
		_ya_impacto = true
		call_deferred("queue_free")
