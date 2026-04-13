extends Control

var slot_index: int = -1
var slot_type: int
var inventory_ref = null
var inventory_ui_ref = null
var item: ItemInstance = null

@onready var item_icon = $SlotItemTexture
@onready var reload_anim = $ReloadAnim


signal start_drag(item, slot_type, slot_index)
signal end_drag()
signal mouse_entered_slot()
signal mouse_exited_slot()

var mouse_hovered = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and inventory_ref:
		if mouse_hovered:
			if event.pressed and event.button_index == 1 and item:
				emit_signal("start_drag", item, slot_type, slot_index)
			elif !event.pressed and event.button_index == 1:
				emit_signal("end_drag")
			
			# TEMPORARY "DELETE ITEM" LOGIC
			elif event.pressed and event.button_index == 2 and item:
				print(slot_type)
				match slot_type:
					inventory_ref.SlotType.CROWNS:
						inventory_ref.crown_slots[slot_index] = null
					inventory_ref.SlotType.INVENTORY:
						inventory_ref.inventory_slots[slot_index] = null
					inventory_ref.SlotType.EQUIPMENT:
						inventory_ref.equipped_slots[slot_index] = null
				inventory_ref.emit_signal("inventory_changed")

func set_item(new_item: ItemInstance):
	# If we're already connected to an old item, disconnect it first
	if item and item.cooldown_started.is_connected(render_reload_anim):
		item.cooldown_started.disconnect(render_reload_anim)

	item = new_item

	if item:
		if not item.cooldown_started.is_connected(render_reload_anim):
			item.cooldown_started.connect(render_reload_anim)

func set_icon_visible(visible: bool) -> void:
	item_icon.visible = visible

func _process(delta: float) -> void:
	var was_hovered = mouse_hovered
	mouse_hovered = get_global_rect().has_point(get_global_mouse_position())
	if mouse_hovered and not was_hovered:
		emit_signal("mouse_entered_slot")
	elif not mouse_hovered and was_hovered:
		emit_signal("mouse_exited_slot")

func _on_mouse_entered() -> void:
	if(item):
		# Weapon preview
		if(item.item_category == ItemTypes.ItemCategory.WEAPON):
			inventory_ui_ref.item_info.visible = true
			inventory_ui_ref.item_info.position = get_preview_position()
			inventory_ui_ref.item_info.get_node("Item Name").text = item.name
			inventory_ui_ref.item_info.get_node("Item Damage").visible = true
			inventory_ui_ref.item_info.get_node("Item Firerate").visible = true
			inventory_ui_ref.item_info.get_node("Item Damage").text = "Damage: " + str(item.damage)
			inventory_ui_ref.item_info.get_node("Item Firerate").text = "Reload Time: " + str(item.fire_rate) + "s"
		# Crown preview
		if(item.item_category == ItemTypes.ItemCategory.CROWN):
			inventory_ui_ref.item_info.visible = true
			inventory_ui_ref.item_info.position = get_preview_position()
			inventory_ui_ref.item_info.get_node("Item Name").text = item.name
			inventory_ui_ref.item_info.get_node("Item Damage").visible = false
			inventory_ui_ref.item_info.get_node("Item Firerate").visible = false

func _on_mouse_exited() -> void:
	inventory_ui_ref.item_info.visible = false

func get_preview_position() -> Vector2:
	var finalpos = global_position
	if(finalpos.x < 128):
		finalpos.x = 0
	else:
		finalpos.x -= 128

	finalpos.y -= 128

	return finalpos

func render_reload_anim():
	var speed_scale = 1  / item.fire_rate
	reload_anim.stop()
	reload_anim.visible = true
	reload_anim.speed_scale = speed_scale
	reload_anim.play("default")

func _on_reload_anim_animation_finished():
	reload_anim.visible = false
