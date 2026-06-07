extends CharacterBody2D


const SPEED = 300.0
var posicionGlob = Vector2(0.0, 0.0)

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	move_and_slide()
