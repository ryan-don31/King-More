extends Control

@onready var reload_indicator: TextureProgressBar = $ReloadIndicator

var reload_max: float = 0.0
var reload_value: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(reload_value <= 0.0):
		visible = false
	else:
		reload_indicator.max_value = reload_max
		reload_indicator.value = reload_value
		visible = true
