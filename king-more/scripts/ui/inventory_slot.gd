extends Control

var slot_index: int = -1
var slot_type: int
var inventory_ref = null
var inventory_ui_ref = null
var item: ItemInstance = null

@onready var icon = $TextureRect
@onready var reload_anim = $ReloadAnim

var mouse_hovered = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and inventory_ref:
		if mouse_hovered:
			if event.pressed and event.button_index == 1 and item:
				inventory_ref.from_type = slot_type
				inventory_ref.from_index = slot_index

				# Make item ur dragging visible
				inventory_ui_ref.drag_preview.visible = true

			elif !event.pressed and event.button_index == 1 and inventory_ref.from_index != -1:

				inventory_ref.move_item(slot_type, slot_index)

				# Make item ur dragging not visible
				inventory_ui_ref.drag_preview.visible = false

			else:
				inventory_ref.from_index = -1
				inventory_ui_ref.drag_preview.visible = false

func set_item(new_item: ItemInstance):
	# If we're already connected to an old item, disconnect it first
	if item and item.cooldown_started.is_connected(render_reload_anim):
		item.cooldown_started.disconnect(render_reload_anim)

	item = new_item

	if item:
		if not item.cooldown_started.is_connected(render_reload_anim):
			item.cooldown_started.connect(render_reload_anim)

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
		inventory_ui_ref.item_info.get_node("Item Damage").text = "Damage: " + str(item.damage)
		inventory_ui_ref.item_info.get_node("Item Firerate").text = "Fire Rate: " + str(item.fire_rate)

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
