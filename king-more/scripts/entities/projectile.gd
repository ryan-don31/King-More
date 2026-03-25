extends Node2D

@export var speed: float = 100
var direction: Vector2 = Vector2.ZERO

func _ready():
	rotation = direction.angle()
	
func _physics_process(delta):
	position += direction * speed * delta
