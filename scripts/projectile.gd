extends Area2D
var SPEED = 400.0
var direction := Vector2.RIGHT
const PROJ_GRAVITY = 200.0

func _ready() -> void:
	$HitArea.connect("area_entered", _on_hit)
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)
	await get_tree().create_timer(3.0).timeout
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
	if body.name == "Player2":
		var knockback_dir = sign(direction.x)
		body.recibir_dano(knockback_dir)
		queue_free()
	else:
		# Chocó con superficie, spawn explosión
		var explosion_scene = preload("res://scenes/ExplosionArea.tscn")
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name != "HitArea" and area.name != "MeleeArea":
		queue_free()
