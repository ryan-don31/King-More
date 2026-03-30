extends Control

var slot_index: int
var slot_type: int
var inventory_ref = null
var inventory_ui_ref = null
var item: ItemInstance = null

@onready var icon = $TextureRect

var mouse_hovered = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and inventory_ref:
		if mouse_hovered:
			if event.pressed and item:
				inventory_ref.from_type = slot_type
				inventory_ref.from_index = slot_index

				# Make item ur dragging visible
				inventory_ui_ref.drag_preview.visible = true

			if !event.pressed:
				inventory_ref.move_item(slot_type, slot_index)

				# Make item ur dragging not visible
				inventory_ui_ref.drag_preview.visible = false

func _process(delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		mouse_hovered = true
	else:
		mouse_hovered = false

func _on_mouse_entered() -> void:
	if(item):
		inventory_ui_ref.item_info.visible = true
		inventory_ui_ref.item_info.position = get_preview_position()
		inventory_ui_ref.item_info.get_node("Item Name").text = item.name
		inventory_ui_ref.item_info.get_node("Item Damage").text = str(item.damage)
		inventory_ui_ref.item_info.get_node("Item Firerate").text = str(item.fire_rate)

func _on_mouse_exited() -> void:
	inventory_ui_ref.item_info.visible = false

func get_preview_position() -> Vector2:
	var finalpos = global_position
	print(finalpos)
	if(finalpos.x < 128):
		finalpos.x = 0
	else:
		finalpos.x -= 128

	finalpos.y -= 128

	return finalpos
