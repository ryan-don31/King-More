extends Control

# Main script for the entire inventory UI

@export var player: Node

@onready var crown_slot_container: GridContainer = $CrownSlots/CrownSlotsContainer
@onready var inventory_slot_container: GridContainer = $InventoryMenu/InventoryContainer
@onready var equipped_slot_container: GridContainer = $EquippedSlots/EquippedContainer
@onready var highlight: TextureRect = $EquippedSlots/Highlight
@onready var drag_preview: Control = $DragPreview
@onready var item_info: Control = $ItemInfo


var inventory: Inventory
var crown_slot_nodes: Array[Node] = []
var equpped_slot_nodes: Array[Node] = []
var inventory_slot_nodes: Array[Node] = []

# Centralized drag state
var is_dragging: bool = false
var dragged_item: ItemInstance = null
var hovered_slot: Control = null

var SlotType = null # Will be set after inventory is assigned


func _ready():
	inventory = player.inventory
	SlotType = inventory.SlotType

	crown_slot_nodes = crown_slot_container.get_children()
	equpped_slot_nodes = equipped_slot_container.get_children()
	inventory_slot_nodes = inventory_slot_container.get_children()

	# Connect slot signals for drag and hover
	for slot in crown_slot_nodes + equpped_slot_nodes + inventory_slot_nodes:
		slot.connect("start_drag", Callable(self, "_on_slot_start_drag"))
		slot.connect("end_drag", Callable(self, "_on_slot_end_drag"))
		slot.connect("mouse_entered_slot", Callable(self, "_on_slot_mouse_entered").bind(slot))
		slot.connect("mouse_exited_slot", Callable(self, "_on_slot_mouse_exited").bind(slot))

	inventory.inventory_changed.connect(update_ui)
	update_ui()


func _process(_delta: float) -> void:
	if(UiManager.inventory_open):
		inventory_slot_container.visible = true
		crown_slot_container.visible = true
	else:
		inventory_slot_container.visible = false
		crown_slot_container.visible = false

	# Drag preview follows mouse if dragging
	if is_dragging:
		drag_preview.position = get_global_mouse_position() - Vector2(16,16)
	else:
		drag_preview.visible = false

func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseButton and not event.pressed and event.button_index == 1:
		# Mouse released, check if over a slot
		if hovered_slot:
			# Drop on hovered slot
			print("Hovered")
			inventory.move_item(hovered_slot.slot_type, hovered_slot.slot_index)
		# Cancel drag if not over a slot
		_cancel_drag()

func _on_slot_start_drag(item: ItemInstance, slot_type: int, slot_index: int):
	print("starting drag:", dragged_item)
	is_dragging = true
	dragged_item = item
	inventory.from_type = slot_type
	inventory.from_index = slot_index
	drag_preview.show_preview(item)
	# Hide icon on source slot
	var source_slot = _get_slot_by_type_and_index(slot_type, slot_index)
	if source_slot:
		source_slot.set_icon_visible(false)

func _on_slot_end_drag():
	# _cancel_drag()
	pass

func _on_slot_mouse_entered(slot):
	hovered_slot = slot

func _on_slot_mouse_exited(slot):
	if hovered_slot == slot:
		hovered_slot = null

func _cancel_drag():
	# Show icon on source slot if drag was active
	if inventory.from_type != -1 and inventory.from_index != -1:
		var source_slot = _get_slot_by_type_and_index(inventory.from_type, inventory.from_index)
		if source_slot:
			source_slot.set_icon_visible(true)
	is_dragging = false
	dragged_item = null
	inventory.from_type = -1
	inventory.from_index = -1
	drag_preview.hide_preview()

# Helper to get slot node by type and index
func _get_slot_by_type_and_index(slot_type: int, slot_index: int) -> Node:
	match slot_type:
		SlotType.CROWNS:
			if slot_index >= 0 and slot_index < crown_slot_nodes.size():
				return crown_slot_nodes[slot_index]
		SlotType.EQUIPMENT:
			if slot_index >= 0 and slot_index < equpped_slot_nodes.size():
				return equpped_slot_nodes[slot_index]
		SlotType.INVENTORY:
			if slot_index >= 0 and slot_index < inventory_slot_nodes.size():
				return inventory_slot_nodes[slot_index]
	return null


# This just visually updates the ui, to "sync" it with the inventory singleton
# This can DEFINITELY be cleaned up. IDGAF right now though sorry
func update_ui():

	# 1 CROWN SLOT
	for i in range(crown_slot_nodes.size()):
		var slot = crown_slot_nodes[i]
		var item = inventory.crown_slots[i] if i < inventory.crown_slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.item_icon.texture = ItemHelper.load_texture(item.item_type)

		else:
			slot.item_icon.texture = null
		
		slot.slot_index = i
		slot.slot_type = SlotType.CROWNS
		slot.inventory_ref = inventory
		slot.inventory_ui_ref = self
		slot.set_item(item)

	# 5 EQUIPPED SLOTS
	for i in range(equpped_slot_nodes.size()):
		var slot = equpped_slot_nodes[i]
		var item = inventory.equipped_slots[i] if i < inventory.equipped_slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.item_icon.texture = ItemHelper.load_texture(item.item_type)

		else:
			slot.item_icon.texture = null
		
		slot.slot_index = i
		slot.slot_type = SlotType.EQUIPMENT
		slot.inventory_ref = inventory
		slot.inventory_ui_ref = self
		slot.set_item(item)

	# 15 INVENTORY SLOTS
	for i in range(inventory_slot_nodes.size()):
		var slot = inventory_slot_nodes[i]
		var item = inventory.inventory_slots[i] if i < inventory.inventory_slots.size() else null
		
		if i == inventory.selected_slot:
			highlight.position = slot.position

		if item != null:
			slot.item_icon.texture = ItemHelper.load_texture(item.item_type)

		else:
			slot.item_icon.texture = null

		slot.slot_index = i
		slot.slot_type = SlotType.INVENTORY
		slot.inventory_ref = inventory
		slot.inventory_ui_ref = self
		slot.set_item(item)
