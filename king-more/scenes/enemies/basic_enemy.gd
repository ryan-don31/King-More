extends CharacterBody2D


@export var speed: float = 50.0                   # chase speed toward the player (pixels/sec)
@export var max_health: float = 300                 # starting HP — dies at 0
@export var spawn_duration: float = 1.5            # flicker duration before becoming active (seconds)
@export var seperation_radius: float = 80.0        # distance at which nearby enemies start pushing away (pixels)
@export var seperation_strength: float = 200.0     # how hard enemies push away from each other

@onready var health_bar: Node = $EnemyHealth

signal health_changed

var player: Node2D
var current_health: float
var spawning := true

func _ready() -> void:
	_start_spawn_process()
	player = get_tree().get_first_node_in_group("player")
	

func _start_spawn_process():
	$HitBox.monitoring = false
	$CollisionShape2D.disabled = true
	current_health = max_health
	
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(spawn_duration).timeout
	
	tween.kill()
	modulate.a = 1.0
	$HitBox.monitoring = true
	$CollisionShape2D.disabled = false
	spawning = false
	
func _physics_process(delta: float) -> void:
	if spawning:
		return
	
	# tries to chase the player if it exists
	if player:
		var direction = global_position.direction_to(player.global_position)
		
		var seperation = Vector2.ZERO
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy == self:
				continue
			var to_me = global_position - enemy.global_position
			var dist = to_me.length()
			if dist < seperation_radius and dist > 0:
				seperation += to_me.normalized() / dist
				
		velocity = (direction * speed) + (seperation * seperation_strength)
		move_and_slide()

func take_damage(amount: float) -> void:
	var damage_indicator = preload("res://scenes/ui/damage_indicator.tscn").instantiate()
	damage_indicator.global_position = global_position
	damage_indicator.damage = str(amount)
	get_tree().current_scene.add_child(damage_indicator)

	if spawning:
		return

	current_health -= amount

	health_changed.emit()

	if current_health <= 0:
		queue_free()
	
func _on_hit_box_body_entered(body: Node2D) -> 	void:
	if body.is_in_group("player"):
		player.take_damage(10.0)
