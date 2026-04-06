extends Control

@onready var health_bar = $ProgressBar
@onready var health_label = $"HP Label"

@export var player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.value = player.health
	health_bar.max_value = player.max_health
	health_label.text = "HP: " + str(player.health) + "/" + str(player.max_health)
