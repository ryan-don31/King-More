extends Node2D

@export var speed: float = 100.0
@export var damage: float = 0
@export var direction: Vector2 = Vector2.ZERO
@export var damage_interval: float = 0.2

@onready var hitbox: Area2D = $Hitbox

var damage_cooldown: float = 0.0

var life: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	life += 0.01
	damage_cooldown -= delta
	check_overlapping_enemies()
	fade_away()
	
	if(life > 50):
		queue_free()
	

func _physics_process(delta):
	position += direction * speed * delta

func fade_away():
	var new_size = 1.0 - (life/20)
	var new_opacity = 1.0 - (life / 5)

	scale = Vector2(new_size, new_size)
	modulate.a = new_opacity

func check_overlapping_enemies():
	if damage_cooldown > 0:
		return

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(damage)
			damage_cooldown = damage_interval
