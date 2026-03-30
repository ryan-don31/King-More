extends Control

# Main script for the entire inventory UI

@export var player: Node

@onready var inventory_slot_container: GridContainer = $InventoryMenu/InventoryContainer
@onready var equipped_slot_container: GridContainer = $EquippedSlots/EquippedContainer
@onready var highlight: TextureRect = $EquippedSlots/Highlight
@onready var drag_preview: Control = $DragPreview

var inventory: Inventory
var equpped_slot_nodes: Array[Node] = []
var inventory_slot_nodes: Array[Node] = []

var SlotType = inventory.SlotType

func _ready():
	inventory = player.inventory

	equpped_slot_nodes = equipped_slot_container.get_children()
	inventory_slot_nodes = inventory_slot_container.get_children()

	inventory.connect("inventory_changed", Callable(self, "update_ui"))
	
	update_ui()

func _process(_delta: float) -> void:
	if(UiManager.inventory_open):
		inventory_slot_container.visible = true
	else:
		inventory_slot_container.visible = false

	# Little icon of the item you're dragging in the inventory
	drag_preview.position = get_global_mouse_position() - Vector2(16,16) # Yes this is pretty ghetto, but setting the pivot offset doesn't seeem to do anything and I don't seem to really care right now


# This just visually updates the ui, to "sync" it with the inventory singleton
func update_ui():

	# 5 "EQUIPPED" SLOTS
	for i in range(equpped_slot_nodes.size()):
		var slot = equpped_slot_nodes[i]
		var item = inventory.equipped_slots[i] if i < inventory.equipped_slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.icon.texture = load("res://assets/sprites/inventory/inventoryslot_full.png")

		else:
			slot.icon.texture = load("res://assets/sprites/inventory/inventoryslot_empty.png")
		
		slot.slot_index = i
		slot.slot_type = SlotType.EQUIPMENT
		slot.inventory_ref = inventory
		slot.inventory_ui_ref = self
		slot.item = item

	# 15 INVENTORY SLOTS
	for i in range(inventory_slot_nodes.size()):
		var slot = inventory_slot_nodes[i]
		var item = inventory.inventory_slots[i] if i < inventory.inventory_slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.icon.texture = load("res://assets/sprites/inventory/inventoryslot_full.png")

		else:
			slot.icon.texture = load("res://assets/sprites/inventory/inventoryslot_empty.png")

		slot.slot_index = i
		slot.slot_type = SlotType.INVENTORY
		slot.inventory_ref = inventory
		slot.inventory_ui_ref = self
		slot.item = item
