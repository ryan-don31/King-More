extends Control

@export var float_speed: float = 20.0
var notification_text: String = ""
@onready var notification_label: Label = $Label
var death_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	notification_label.text = notification_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y -= float_speed * delta
	death_timer += 1.0
	if death_timer > 100.0:
		queue_free()
