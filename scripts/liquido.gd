extends Area2D

var tiempo_contacto := 0.0
var crusty_dentro := false

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _process(delta: float) -> void:
	if crusty_dentro:
		tiempo_contacto += delta
		if tiempo_contacto >= 1.0:
			tiempo_contacto = 0.0
			get_tree().get_first_node_in_group("player2").recibir_dano_liquido()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2":
		crusty_dentro = true
		tiempo_contacto = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player2":
		crusty_dentro = false
		tiempo_contacto = 0.0
