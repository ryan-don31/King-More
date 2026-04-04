extends Camera2D
class_name Camera

@export var max_distance: float = 850.0
@export var smooth_speed: float = 12.0
@export var mouse_weight: float = 0.2

var target_offset: Vector2 = Vector2.ZERO
var target_zoom: Vector2 = Vector2(0.8, 0.8)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(UiManager.inventory_open):
		position = position.lerp(Vector2(0,0), smooth_speed * delta)
	else:
		position = position.lerp(target_offset, smooth_speed * delta)

	zoom = zoom.lerp(target_zoom, smooth_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var player_pos = get_parent().global_position 
		
		target_offset = (mouse_pos - player_pos) * mouse_weight
		
		if target_offset.length() > max_distance:
			target_offset = target_offset.normalized()
