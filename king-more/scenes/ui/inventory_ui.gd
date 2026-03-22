extends Control

@export var inventory: Inventory
@export var equipment: Equipment
@export var slot_container: HBoxContainer

var slot_nodes: Array[Node] = []

func _ready():
	slot_nodes = slot_container.get_children()
	update_ui()

func update_ui():
	for i in range(slot_nodes.size()):
		var slot = slot_nodes[i]
		var item = inventory.slots[i] if i < inventory.slots.size() else null
		if item != null:
			slot.texture = preload("res://icon.svg")
		else:
			slot.texture = null
			
func on_item_added(item: ItemInstance):
	update_ui()
