extends Control

@export var player: Node
@export var slot_container: HBoxContainer

var inventory: Inventory
var equipment: Equipment
var slot_nodes: Array[Node] = []

func _ready():
	inventory = player.inventory
	equipment = player.equipment
	slot_nodes = slot_container.get_children()
	
	inventory.connect("inventory_changed", Callable(self, "update_ui"))
	
	update_ui()

func update_ui():
	for i in range(slot_nodes.size()):
		var slot = slot_nodes[i]
		var item = inventory.slots[i] if i < inventory.slots.size() else null

		if item != null:
			print("something")
			slot.texture = load("res://assets/sprites/inventory/inventoryslot_full.png")
		else:
			print(i)
			slot.texture = load("res://assets/sprites/inventory/inventoryslot_empty.png")
