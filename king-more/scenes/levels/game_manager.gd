extends Node

## Scene references
@export var enemy_scene: PackedScene               # basic melee enemy scene
@export var ranged_enemy_scene: PackedScene         # ranged shooter enemy scene (optional — falls back to all basic if unset)
@export var boss_enemy_scene: PackedScene           # boss scene — spawned alone on the final wave
@export var spawn_points_container: Node            # parent node holding all Marker2D/Node2D spawn points

## Wave config
@export var max_waves: int = 6                      # total number of waves before the game ends
@export var base_enemies_per_wave: int = 4          # enemies in wave 1 (before multiplier)
@export var enemies_per_wave_increase: int = 2      # extra enemies added per wave (linear scaling)
@export var wave_multiplier: float = 1.5            # global multiplier on total enemy count (1.0 = no change, 2.0 = double)
@export var ranged_enemy_wave_start: int = 3        # first wave ranged enemies appear in
@export var ranged_enemy_percentage: float = 0.3    # fraction of each wave that's ranged (0.0–1.0)

## Spawning
@export var spawn_offset_range: float = 100.0       # random position scatter around each spawn point (pixels)

## Timing
@export var grace_period: float = 5.0               # seconds before the first wave spawns
@export var cooldown_between_waves: float = 10.0    # seconds between clearing a wave and the next one spawning

@onready var timer = $Timer

var current_wave: int = 0
var enemies_alive: int = 0
var waiting_for_next_wave: bool = false


func _ready() -> void:
	GameState.is_transitioning = false
	GameState.total_waves = max_waves
	if not enemy_scene:
		push_error("Enemy scene is empty!")
		return
	if not spawn_points_container:
		push_error("No spawn_points container detected!")
		return

	timer.start(grace_period)

func _start_next_wave() -> void:
	current_wave += 1
	GameState.waves_survived = current_wave - 1 
	if current_wave > max_waves:
		print("All waves defeated!") # this might be redundant but im afraid to remove it
		GameState.win()
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

	# Split between basic and ranged
	var ranged_count = 0
	if ranged_enemy_scene and current_wave >= ranged_enemy_wave_start:
		ranged_count = int(total_enemies * ranged_enemy_percentage)
	var basic_count = total_enemies - ranged_count

	# Build a flat shuffled list of scenes to spawn
	var spawn_list = []
	for i in range(basic_count):
		spawn_list.append(enemy_scene)
	for i in range(ranged_count):
		spawn_list.append(ranged_enemy_scene)
	# On the final wave, add the boss to the mix
	if boss_enemy_scene and current_wave == max_waves:
		spawn_list.append(boss_enemy_scene)
	spawn_list.shuffle()

	enemies_alive = 0
	var spawn_index = 0
	for i in range(num_points):
		var point_pos = spawn_points[i].global_position
		for j in range(spawn_counts[i]):
			var enemy = spawn_list[spawn_index].instantiate()
			spawn_index += 1
			enemy.global_position = point_pos + Vector2(randf_range(-spawn_offset_range, spawn_offset_range), randf_range(-spawn_offset_range, spawn_offset_range))
			enemy.tree_exiting.connect(_on_enemy_died)
			get_tree().current_scene.add_child(enemy)
			enemies_alive += 1

func _on_enemy_died() -> void:
	if GameState.is_transitioning:
		return
	enemies_alive -= 1
	if enemies_alive <= 0 and not waiting_for_next_wave:
		waiting_for_next_wave = true
		print("Wave ", current_wave, " cleared! Max: ", max_waves)
		if current_wave >= max_waves:
			print("All waves defeated!")
			GameState.win()
			return
		timer.start(cooldown_between_waves)


func _on_timer_timeout() -> void:
	_start_next_wave()
