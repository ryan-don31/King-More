extends Resource
class_name Inventory

# Handles the data for the user's CURRENT INVENTORY

signal inventory_changed

const EQUIP_SLOTS = 5
const INV_SLOTS = 15

enum SlotType {
	INVENTORY,
	EQUIPMENT
}

var equipped_slots: = []
var inventory_slots: = []

var selected_slot: int = 0

# CURRENT EQUIPPED ITEMS
var selected_item: ItemInstance = null

var from_type: SlotType
var from_index: int = -1

# Make sure the slots is limited to the current max size
func _init():
	equipped_slots.resize(EQUIP_SLOTS)
	inventory_slots.resize(INV_SLOTS)
	
func add_item(item: ItemInstance) -> bool:
	for i in range(inventory_slots.size()):
		if inventory_slots[i] == null:
			inventory_slots[i] = item
			emit_signal("inventory_changed")
			selected_item = equipped_slots[selected_slot]
			return true
	return false
	
func _get_array(type: SlotType) -> Array:
	match type:
		SlotType.INVENTORY:
			return inventory_slots
		SlotType.EQUIPMENT:
			return equipped_slots
	return []

func move_item(to_type: SlotType, to_index: int):

	var from_array = _get_array(from_type)
	var to_array = _get_array(to_type)

	# bounds safety
	if from_index < 0 or from_index >= from_array.size():
		return
	if to_index < 0 or to_index >= to_array.size():
		return

	var from_item = from_array[from_index]
	var to_item = to_array[to_index]

	# nothing to move
	if from_item == null:
		return

	# SWAP / MOVE
	to_array[to_index] = from_item
	from_array[from_index] = to_item

	# if we moved something from equipped slot, update selected item
	selected_item = equipped_slots[selected_slot]

	emit_signal("inventory_changed")
	
func slot_change(change: int):	
	if change == -1 and selected_slot > 0:
		selected_slot -= 1
	if change == 1 and selected_slot < 4:
		selected_slot += 1
	
	emit_signal("inventory_changed")
	
	selected_item = equipped_slots[selected_slot]
