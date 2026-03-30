extends Control

var slot_index: int
var slot_type: int
var inventory_ref = null
var inventory_ui_ref = null
var item: ItemInstance = null

@onready var icon = $TextureRect


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and inventory_ref:
		if get_global_rect().has_point(get_global_mouse_position()):
			if event.pressed and item:
				inventory_ref.from_type = slot_type
				inventory_ref.from_index = slot_index

				# Make item ur dragging visible
				inventory_ui_ref.drag_preview.visible = true

			if !event.pressed:
				inventory_ref.move_item(slot_type, slot_index)

				# Make item ur dragging not visible
				inventory_ui_ref.drag_preview.visible = false


# # Godot drag-and-drop: can this slot accept a drop?
# func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
# 	return data.has("slot_type") and data.has("slot_index")

# # Godot drag-and-drop: handle drop
# func _drop_data(_at_position: Vector2, data: Variant):
# 	if not (data.has("slot_type") and data.has("slot_index")):
# 		return
# 	var from_type = data["slot_type"]
# 	var from_index = data["slot_index"]
# 	# Move or swap items using inventory logic
# 	if inventory_ref:
# 		inventory_ref.move_item(from_type, from_index, slot_type, slot_index)
