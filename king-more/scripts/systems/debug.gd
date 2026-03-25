extends Node

func make_item(mouse_pos: Vector2):
	var dropped_item = ItemInstance.new()
	dropped_item.name = "Basic Weapon"
	dropped_item.item_type = "basic_wep"
	dropped_item.damage = 50.0
	dropped_item.fire_rate = 0.25
	
	ItemSpawner.spawn(dropped_item, mouse_pos)

func zoom_camera(camera: Node):
	camera.target_zoom *= Vector2(0.75, 0.75)
