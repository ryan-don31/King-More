extends Node2D

# This is the actual item you see on the floor in the world

var item: ItemInstance
var is_hovered: bool = false

@onready var item_preview: Control = $Item_Preview

func _process(_delta):
	if is_hovered and Input.is_action_just_pressed("interact"):
		pickup()

func pickup():
	#TODO: Refactor this it's really lame
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.inventory.add_item(item):
		queue_free()


func _on_mouse_area_2d_mouse_entered() -> void:
	print("Yep mouse entered")
	is_hovered = true
	item_preview.visible = true
	modulate = Color(1, 1, 0.5)


func _on_mouse_area_2d_mouse_exited() -> void:
	print("Yep mouse exited")
	is_hovered = false
	item_preview.visible = false
	modulate = Color(1, 1, 1)
