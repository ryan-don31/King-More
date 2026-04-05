extends Node2D

@export var damage: float = 5.0
@export var speed: float = 0.0
@export var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	position += direction * speed * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		sprite.play("hit")


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()
