extends Node

# Handles opening/closing the inventory, and showing/disabling the item drag animation

var inventory_ui = null
var player_inventory = null

var inventory_open = false

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	inventory_open = !inventory_open

func show_drag_preview(_dragging_item):
	inventory_ui.drag_preview.visible = true

func hide_drag_preview():
	inventory_ui.drag_preview.visible = false
