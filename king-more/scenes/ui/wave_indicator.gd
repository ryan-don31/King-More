extends Control

@export var game_manager: Node

@onready var current_wave_label: Label = $"Current Wave"
@onready var countdown_label: Label = $Countdown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time_left = int(game_manager.timer.time_left)
	if(time_left <= 0):
		countdown_label.visible = false
	else:
		countdown_label.visible = true
	current_wave_label.text = "Current Wave: " + str(game_manager.current_wave)
	countdown_label.text = "Next Wave Starting In " + str(time_left) + "s"
