extends Node2D

@export var damage: float = 0.0

@onready var start_point = $start_point
@onready var point_a = $point_a
@onready var point_b = $point_b
@onready var final_point = $final_point

@onready var start_sprite = $start_point/AnimatedSprite2D
@onready var a_sprite = $point_a/AnimatedSprite2D
@onready var b_sprite = $point_b/AnimatedSprite2D

var target_pos: Vector2 = Vector2.ZERO
var opacity: float = 100.0

func _ready() -> void:
	var distance = position.distance_to(target_pos)
	final_point.position = target_pos

	# EVERYTHING in local space
	var start_pos := Vector2.ZERO
	var end_pos := target_pos

	# base structure
	var one_third := start_pos.lerp(end_pos, 1.0 / 3.0)
	var two_third := start_pos.lerp(end_pos, 2.0 / 3.0)

	var offset_range: float = distance / 4

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

func _process(delta: float) -> void:
	print(opacity)
	opacity -= 5.0
	modulate.a = opacity

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


func _on_timer_timeout() -> void:
	queue_free()
