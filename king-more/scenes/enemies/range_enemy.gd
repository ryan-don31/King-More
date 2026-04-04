extends CharacterBody2D

## Movement
@export var speed: float = 70.0                    # chase speed when outside attack_radius (pixels/sec)
@export var strafe_speed: float = 50.0             # orbit speed when inside attack_radius (pixels/sec)
@export var attack_radius: float = 300.0           # distance at which enemy stops chasing and starts strafing + shooting (pixels)

## Combat
@export var max_health: float = 300                   # starting HP — dies at 0
@export var fire_rate: float = 2.0                 # seconds between shots while in attack range
@export var aim_spread: float = 0.3                # aiming accuracy in radians (0.0 = perfect, 0.3 = slight wobble, 0.8+ = very inaccurate)
@export var projectile_speed: float		# Travel speed of the projectile

## Spawn
@export var spawn_duration: float = 1.5            # flicker duration before becoming active (seconds)

## Flocking
@export var separation_radius: float = 40.0        # distance at which nearby enemies start pushing away (pixels)
@export var separation_strength: float = 80.0      # how hard enemies push away from each other

var player: Node2D
var current_health: float
var spawning: bool = true
var fire_cooldown: float = 0.0
var strafe_direction: int = 1

signal health_changed

const PROJECTILE_SCENE = preload("res://scenes/projectile/enemy_projectile.tscn")

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	strafe_direction = 1 if randf() > 0.5 else -1

	modulate = Color(1.0, 0.4, 0.4)  # reddish tint to distinguish from basic enemy

	$HitBox.monitoring = false
	$CollisionShape2D.disabled = true
	_do_spawn_flicker()

func _do_spawn_flicker() -> void:
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
	if spawning or not player:
		return

	var distance = global_position.distance_to(player.global_position)
	var to_player = global_position.direction_to(player.global_position)

	var separation = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var to_me = global_position - enemy.global_position
		var dist = to_me.length()
		if dist < separation_radius and dist > 0:
			separation += to_me.normalized() / dist

	if distance > attack_radius:
		# Chase the player
		velocity = (to_player * speed) + (separation * separation_strength)
	else:
		# Strafe perpendicular to player, maintaining distance
		var perpendicular = Vector2(-to_player.y, to_player.x) * strafe_direction
		velocity = (perpendicular * strafe_speed) + (separation * separation_strength)

		# Fire on cooldown
		fire_cooldown -= delta
		if fire_cooldown <= 0.0:
			_fire_at_player(to_player)
			fire_cooldown = fire_rate

	move_and_slide()

func _fire_at_player(to_player: Vector2) -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.global_position = global_position
	projectile.speed = projectile_speed
	projectile.direction = to_player.rotated(randf_range(-aim_spread, aim_spread))
	get_tree().current_scene.add_child(projectile)

func take_damage(amount: int) -> void:
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

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		queue_free()
