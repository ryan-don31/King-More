extends Control

@export var lifetime = 10.0
@onready var label = $Label
var damage = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = damage


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(lifetime <= 0.0):
		queue_free()
	
	lifetime -= 0.1
	position.y -= 1
	modulate.a -= 0.05
