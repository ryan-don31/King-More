extends Node2D

@export var damage: float = 0.0

@onready var start_point = $start_point
@onready var point_a = $point_a
@onready var point_b = $point_b
@onready var final_point = $final_point

@onready var start_sprite = $start_point/Sprite2D
@onready var a_sprite = $point_a/Sprite2D
@onready var b_sprite = $point_b/Sprite2D
@onready var end_sprite = $final_point/Sprite2D

var target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	final_point.position = target_pos

	# EVERYTHING in local space
	var start_pos := Vector2.ZERO
	var end_pos := target_pos

	# base structure
	var one_third := start_pos.lerp(end_pos, 1.0 / 3.0)
	var two_third := start_pos.lerp(end_pos, 2.0 / 3.0)

	var offset_range := 128.0

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


func _update_segment(a: Vector2, b: Vector2, sprite: Sprite2D) -> void:
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
	var tex_width := sprite.texture.get_width()
	sprite.scale.x = dist / tex_width


func _on_timer_timeout() -> void:
	queue_free()
