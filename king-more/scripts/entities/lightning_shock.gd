extends Node2D

@export var damage: float = 0.0
@export var snap_radius: float = 128.0

@onready var start_point = $start_point
@onready var point_a = $point_a
@onready var point_b = $point_b
@onready var final_point = $final_point

@onready var start_sprite = $start_point/AnimatedSprite2D
@onready var a_sprite = $point_a/AnimatedSprite2D
@onready var b_sprite = $point_b/AnimatedSprite2D

var target_pos: Vector2 = Vector2.ZERO
var opacity: float = 1.0
var width: float = 0.5

func _ready() -> void:
	spawn_lightning()

func _process(delta: float) -> void:
	opacity -= 0.05
	width -= 0.01
	modulate.a = opacity
	start_sprite.scale.y = width
	a_sprite.scale.y = width
	b_sprite.scale.y = width

func spawn_lightning():
	var start_pos := Vector2.ZERO

	# Convert target_pos to GLOBAL for searching
	var global_target := to_global(target_pos)

	var closest_enemy := get_closest_enemy_to_point(global_target)

	var end_global: Vector2

	if closest_enemy and global_target.distance_to(closest_enemy.global_position) <= snap_radius:
		end_global = closest_enemy.global_position
	else:
		end_global = global_target

	# Convert BACK to local space
	var end_pos := to_local(end_global)

	final_point.position = end_pos

	# base structure
	var one_third := start_pos.lerp(end_pos, 1.0 / 3.0)
	var two_third := start_pos.lerp(end_pos, 2.0 / 3.0)

	var offset_range: float = 128

	var a_pos := one_third + Vector2(
		randf_range(-offset_range, offset_range),
		randf_range(-offset_range, offset_range)
	)

	var b_pos := two_third + Vector2(
		randf_range(-offset_range, offset_range),
		randf_range(-offset_range, offset_range)
	)

	_update_segment(start_pos, a_pos, start_sprite)
	_update_segment(a_pos, b_pos, a_sprite)
	_update_segment(b_pos, end_pos, b_sprite)

func _update_segment(a: Vector2, b: Vector2, sprite: AnimatedSprite2D) -> void:
	var dir := b - a
	var dist := dir.length()

	if dist == 0:
		return

	dir = dir.normalized()

	# midpoint in LOCAL space
	sprite.position = (a + b) * 0.5

	# rotate
	sprite.rotation = dir.angle()

	# stretch along X axis
	sprite.play("default")
	var tex_width: float = sprite.sprite_frames.get_frame_texture("default", 0).get_width()
	sprite.scale.x = dist / tex_width

func get_closest_enemy_to_point(point: Vector2) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")

	var closest_enemy: Node2D = null
	var closest_dist := INF

	for enemy in enemies:
		if not enemy is Node2D:
			continue

		var dist = enemy.global_position.distance_to(point)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy

	return closest_enemy

func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		final_point.queue_free()

