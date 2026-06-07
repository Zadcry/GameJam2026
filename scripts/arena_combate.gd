extends Area2D

var jugador:Node2D =null
var jefe:Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1") and body.is_in_group("player2"):
		print("llegaron los dos jugadores")
	elif body.is_in_group("jefe"):
		jefe = body
		var llegaron:bool = true
		if jefe.has_method("cambioFase"):
			jefe.cambioFase(llegaron)
