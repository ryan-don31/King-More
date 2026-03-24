extends Node

const WORLD_ITEM_SCENE = preload("res://scenes/items/world_item.tscn")

func spawn(item_instance: ItemInstance, position: Vector2):
	var world_item = WORLD_ITEM_SCENE.instantiate()
	world_item.item = item_instance
	world_item.position = position
	get_tree().current_scene.add_child(world_item)
