extends Node2D

@export var speed: float = 100
@export var damage: float = 0.0
@export var direction: Vector2 = Vector2.ZERO

func _ready():
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
