extends Control

@export var player: Node
@export var slot_container: HBoxContainer
@export var highlight: TextureRect

var inventory: Inventory
var equipment: Equipment
var slot_nodes: Array[Node] = []

func _ready():
	inventory = player.inventory
	equipment = player.equipment
	slot_nodes = slot_container.get_children()
	
	inventory.connect("inventory_changed", Callable(self, "update_ui"))
	
	update_ui()

# This just visually updates the ui, to "sync" it with the inventory singleton
func update_ui():
	for i in range(slot_nodes.size()):
		var slot = slot_nodes[i]
		var item = inventory.slots[i] if i < inventory.slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.texture = load("res://assets/sprites/inventory/inventoryslot_full.png")
		else:
			slot.texture = load("res://assets/sprites/inventory/inventoryslot_empty.png")
