extends CharacterBody2D

## Movement
@export var speed: float = 90.0                    # chase/strafe speed during RANGED phase (pixels/sec)
@export var strafe_speed: float = 60.0             # orbit speed when inside attack_radius (pixels/sec)
@export var attack_radius: float = 320.0           # distance at which boss stops chasing and starts strafing

## Swoop
@export var swoop_speed: float = 650.0             # dash speed during the swoop attack (pixels/sec)
@export var swoop_chance: float = 0.30             # probability (0.0-1.0) boss decides to swoop when window opens
@export var stream_chance: float = 0.30            # probability (0.0-1.0) boss decides to stream when window opens
@export var swoop_window_min: float = 4.0          # minimum seconds between special attack decision rolls
@export var swoop_window_max: float = 8.0          # maximum seconds between special attack decision rolls
@export var swoop_melee_damage: float = 25.0       # damage dealt to player on swoop contact
@export var swoop_overshoot: float = 80.0          # pixels past the player the boss travels before recovering
@export var recovery_duration: float = 1.2         # seconds the boss pauses after a swoop

## Stream attack
@export var stream_count: int = 12                 # number of projectiles in the stream burst
@export var stream_interval: float = 0.08          # seconds between each projectile in the stream
@export var stream_spread: float = 0.05            # tiny random wobble per shot so it doesn't feel robotic

## Ranged combat
@export var fire_rate: float = 1.8                 # seconds between arc bursts
@export var arc_count: int = 5                     # number of projectiles per burst
@export var arc_spread: float = 0.8                # total angular spread of the arc in radians
@export var aim_spread: float = 0.15               # extra random wobble per projectile (radians)

## General combat
@export var max_health: float = 1000.0
@export var spawn_duration: float = 2.0

## Flocking
@export var separation_radius: float = 50.0
@export var separation_strength: float = 100.0

## Internal state
enum State { SPAWNING, RANGED, SWOOPING, RECOVERING, STREAMING }
var state: State = State.SPAWNING

var player: Node2D
var current_health: float
var strafe_direction: int = 1

var fire_cooldown: float = 0.0

var swoop_timer: float = 0.0
var swoop_destination: Vector2 = Vector2.ZERO
var recovery_timer: float = 0.0

signal health_changed

const PROJECTILE_SCENE = preload("res://scenes/projectile/enemy_projectile.tscn")

# ─── Setup ────────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	strafe_direction = 1 if randf() > 0.5 else -1

	# Purple hue
	modulate = Color(0.75, 0.3, 1.0)

	$HitBox.monitoring = false
	$CollisionShape2D.disabled = true
	_roll_next_swoop_window()
	_do_spawn_flicker()

func _do_spawn_flicker() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.15, 0.12)
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

	await get_tree().create_timer(spawn_duration).timeout

	tween.kill()
	modulate.a = 1.0
	$HitBox.monitoring = true
	$CollisionShape2D.disabled = false
	state = State.RANGED

# ─── Per-frame ────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if state == State.SPAWNING or not player:
		return

	match state:
		State.RANGED:
			_tick_ranged(delta)
		State.SWOOPING:
			_tick_swoop(delta)
		State.RECOVERING:
			_tick_recovery(delta)
		State.STREAMING:
			# Boss stands still during the stream — movement handled in coroutine
			velocity = Vector2.ZERO
			move_and_slide()

func _tick_ranged(delta: float) -> void:
	var distance = global_position.distance_to(player.global_position)
	var to_player = global_position.direction_to(player.global_position)
	var separation = _get_separation_force()

	if distance > attack_radius:
		velocity = (to_player * speed) + separation
	else:
		var perp = Vector2(-to_player.y, to_player.x) * strafe_direction
		velocity = (perp * strafe_speed) + separation

		fire_cooldown -= delta
		if fire_cooldown <= 0.0:
			_fire_arc(to_player)
			fire_cooldown = fire_rate

	# Special attack decision window
	swoop_timer -= delta
	if swoop_timer <= 0.0:
		_roll_next_swoop_window()
		var roll = randf()
		if roll < swoop_chance:
			_begin_swoop()
			return
		elif roll < swoop_chance + stream_chance:
			_begin_stream()
			return

	move_and_slide()

func _tick_swoop(delta: float) -> void:
	var to_dest = global_position.direction_to(swoop_destination)
	velocity = to_dest * swoop_speed
	move_and_slide()

	# Arrived at (or past) destination
	if global_position.distance_to(swoop_destination) < 24.0:
		_enter_recovery()

func _tick_recovery(delta: float) -> void:
	# Bleed off momentum quickly
	velocity = velocity.move_toward(Vector2.ZERO, swoop_speed * delta * 6.0)
	move_and_slide()

	recovery_timer -= delta
	if recovery_timer <= 0.0:
		state = State.RANGED

# ─── Actions ──────────────────────────────────────────────────────────────────

func _begin_swoop() -> void:
	state = State.SWOOPING
	var to_player = global_position.direction_to(player.global_position)
	# Aim slightly past the player so the boss rockets through them
	swoop_destination = player.global_position + to_player * swoop_overshoot

func _enter_recovery() -> void:
	state = State.RECOVERING
	recovery_timer = recovery_duration
	_roll_next_swoop_window()

func _fire_arc(base_direction: Vector2) -> void:
	for i in range(arc_count):
		# Spread shots evenly across the arc, centred on base_direction
		var t = float(i) / float(arc_count - 1) - 0.5   # -0.5 .. +0.5
		var angle = t * arc_spread + randf_range(-aim_spread, aim_spread)

		var projectile = PROJECTILE_SCENE.instantiate()
		projectile.global_position = global_position
		projectile.direction = base_direction.rotated(angle)
		get_tree().current_scene.add_child(projectile)

func _begin_stream() -> void:
	state = State.STREAMING
	_fire_stream()

func _fire_stream() -> void:
	for i in range(stream_count):
		if state != State.STREAMING or not player:
			break
		var to_player = global_position.direction_to(player.global_position)
		var projectile = PROJECTILE_SCENE.instantiate()
		projectile.global_position = global_position
		projectile.direction = to_player.rotated(randf_range(-stream_spread, stream_spread))
		get_tree().current_scene.add_child(projectile)
		await get_tree().create_timer(stream_interval).timeout
	# Stream finished — back to ranged
	if state == State.STREAMING:
		state = State.RANGED
		_roll_next_swoop_window()

func _roll_next_swoop_window() -> void:
	swoop_timer = randf_range(swoop_window_min, swoop_window_max)

func _get_separation_force() -> Vector2:
	var sep = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var to_me = global_position - enemy.global_position
		var dist = to_me.length()
		if dist < separation_radius and dist > 0:
			sep += to_me.normalized() / dist
	return sep * separation_strength

# ─── Damage / death ───────────────────────────────────────────────────────────

func take_damage(amount: float) -> void:
	var damage_indicator = preload("res://scenes/ui/damage_indicator.tscn").instantiate()
	damage_indicator.global_position = global_position
	damage_indicator.damage = str(amount)
	get_tree().current_scene.add_child(damage_indicator)

	if state == State.SPAWNING:
		return

	current_health -= amount
	health_changed.emit()

	if current_health <= 0:
		queue_free()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if state == State.SWOOPING:
		# Swoop contact — heavy melee hit, then recover
		body.take_damage(swoop_melee_damage)
		_enter_recovery()
	else:
		# Incidental contact during ranged phase
		body.take_damage(10.0)
