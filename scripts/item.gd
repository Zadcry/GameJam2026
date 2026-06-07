extends Area2D

var mitch_cerca := false

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta: float) -> void:
	if mitch_cerca and Input.is_action_just_pressed("p1_shoot"):
		Global.version_mapa += 1
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player1":
		mitch_cerca = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player1":
		mitch_cerca = false
