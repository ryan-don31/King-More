extends Control

@export var enemy: Node
@onready var progress_bar = $TextureProgressBar

var opacity = 0.0

func _ready() -> void:
	enemy.health_changed.connect(update)

func _process(delta: float) -> void:
	modulate.a = opacity
	if opacity > 0.0:
		opacity -= 0.05

func update():
	progress_bar.visible = true
	progress_bar.value = (enemy.current_health / enemy.max_health)
	print("PROGRESS BAR VALUE: ", progress_bar.value)
	opacity = 3.0