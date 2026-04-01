extends Node

@export var enemy_scene: PackedScene
@export var base_enemies_per_wave: int = 4
@export var spawn_points_container: Node
@export var max_waves: int = 3

var current_wave: int = 1
@onready var timer = get_node_or_null("Timer")


func _ready() -> void:
	print("--- GameManager _ready() fired ---")
	if not enemy_scene:
		push_error("Enemy scene is empty!")
	if not spawn_points_container:
		push_error("No spawn_points container detected!")
	
	if timer:
		call_deferred("spawn_wave")
		timer.start()
		current_wave += 1
	else:
		print("No timer found")

func _on_timer_timeout() -> void:
	if current_wave > max_waves:
		print("Stopping wave spawner because max waves reached:", max_waves)
		if timer:
			timer.stop()
		
		return
	spawn_wave()
	current_wave += 1

func spawn_wave() -> void:
	print("Spawning a wave...")
	if not spawn_points_container:
		print("ABORTING: Cannot find spawn points container.")
		return
	var spawn_points = spawn_points_container.get_children()
	var num_points = spawn_points.size()
	
	if num_points == 0:
		print("No spawn points found!")
		return
		
	var total_enemies = base_enemies_per_wave + (current_wave * 2)
	
	#  Calculate the distribution
	var base_amount = total_enemies / num_points
	var remainder = total_enemies % num_points

	var spawn_counts = []
	for i in range(num_points):
		spawn_counts.append(base_amount)
		
	# distribute the remainder randomly across different points
	if remainder > 0:
		var indices = range(num_points)
		indices.shuffle() # Randomize the order of indices
		for i in range(remainder):
			spawn_counts[indices[i]] += 1
			
	print("Distribution across points: ", spawn_counts)
	var enemies_actually_spawned = 0
	
	# Spawn the enemies at their designated points
	for i in range(num_points):
		var enemies_for_this_point = spawn_counts[i]
		var point_position = spawn_points[i].global_position
		
		for j in range(enemies_for_this_point):
			if enemy_scene:
				var enemy = enemy_scene.instantiate()
				# Add a tiny random offset so enemies spawning at the same marker on the same frame don't perfectly overlap and merge into one sprite.
				var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
				enemy.global_position = point_position + random_offset
				get_tree().current_scene.add_child(enemy)
				enemies_actually_spawned += 1
			else:
				print("Tried to spawn, but enemy scene is missing")
				
	print("Successfully added ", enemies_actually_spawned, " enemies to the scene.")
