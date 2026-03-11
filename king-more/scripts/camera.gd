extends Camera2D

@export var max_distance: float = 850.0
@export var smooth_speed: float = 8.0
@export var mouse_weight: float = 0.4

#@export var speed := 5.0
#@export var run_speed := 7.5
#@export var jump_velocity := 4.5
#@export var sensitivity := 0.01

#@onready var head := $Head
#@onready var camera :=$Camera2D
var target_offset: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position.lerp(target_offset, smooth_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var player_pos = get_parent().global_position 
		
		target_offset = (mouse_pos - player_pos) * mouse_weight
		
		if target_offset.length() > max_distance:
			target_offset = target_offset.normalized()
