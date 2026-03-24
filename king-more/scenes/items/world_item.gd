extends Node2D

# This is the actual item you see on the floor in the world

@export var item: ItemInstance

var is_hovered: bool = false

func _on_mouse_entered() -> void:
	is_hovered = true
	modulate = Color(1, 1, 0.8)

func _on_mouse_exited() -> void:
	is_hovered = false
	modulate = Color(1, 1, 1)

func _process(delta):
	if is_hovered and Input.is_action_just_pressed("interact"):
		pickup()

func pickup():
	#TODO: Refactor this it's really lame
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.inventory.add_item(item):
		queue_free()
