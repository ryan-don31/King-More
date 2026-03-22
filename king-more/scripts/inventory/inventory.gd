extends Resource
class_name Inventory

# Handles the user's CURRENT INVENTORY

@export var size: int = 5
var slots: Array[ItemInstance] = []

# Make sure the slots is limited to the current max size
func _init():
	slots.resize(size)
	
func add_item(item: ItemInstance) -> bool:
	return false
	
func move_item(from_index: int, to_index: int):
	pass
	
