extends Node

@export var enemy_scene: PackedScene
@export var spawn_points_container: Node

# Wave config
@export var max_waves: int = 6
@export var base_enemies_per_wave: int = 10
@export var enemies_per_wave_increase: int = 2
@export var wave_multiplier: float = 1.5

# Timing
@export var grace_period: float = 5.0
@export var cooldown_between_waves: float = 10.0

var current_wave: int = 0
var enemies_alive: int = 0
var waiting_for_next_wave: bool = false

func _ready() -> void:
	if not enemy_scene:
		push_error("Enemy scene is empty!")
		return
	if not spawn_points_container:
		push_error("No spawn_points container detected!")
		return

	print("Game starting. First wave in ", grace_period, "s")
	await get_tree().create_timer(grace_period).timeout
	_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	if current_wave > max_waves:
		print("All waves defeated!")
		return
	waiting_for_next_wave = false
	_spawn_wave()

func _spawn_wave() -> void:
	var spawn_points = spawn_points_container.get_children()
	var num_points = spawn_points.size()

	if num_points == 0:
		push_error("No spawn points found!")
		return

	# Calculate enemy count: base + scaling per wave, then apply multiplier
	var base_count = base_enemies_per_wave + ((current_wave - 1) * enemies_per_wave_increase)
	var total_enemies = max(int(base_count * wave_multiplier), 1)

	# Distribute evenly, scatter remainder randomly
	var spawn_counts = []
	var per_point = total_enemies / num_points
	var remainder = total_enemies % num_points

	for i in range(num_points):
		spawn_counts.append(per_point)

	if remainder > 0:
		var indices = range(num_points)
		indices.shuffle()
		for i in range(remainder):
			spawn_counts[indices[i]] += 1

	print("Wave ", current_wave, "/", max_waves, " | Enemies: ", total_enemies, " | Distribution: ", spawn_counts)

	enemies_alive = 0
	for i in range(num_points):
		var point_pos = spawn_points[i].global_position
		for j in range(spawn_counts[i]):
			var enemy = enemy_scene.instantiate()
			enemy.global_position = point_pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			enemy.tree_exiting.connect(_on_enemy_died)
			get_tree().current_scene.add_child(enemy)
			enemies_alive += 1

func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and not waiting_for_next_wave:
		waiting_for_next_wave = true
		print("Wave ", current_wave, " cleared!")
		if current_wave >= max_waves:
			print("All waves defeated!")
			return
		print("Next wave in ", cooldown_between_waves, "s...")
		await get_tree().create_timer(cooldown_between_waves).timeout
		_start_next_wave()
