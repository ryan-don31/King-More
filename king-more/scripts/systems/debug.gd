extends Node

func make_item():
	var dropped_item = ItemInstance.new()
	dropped_item.item_type.name = "Basic Weapon"
	dropped_item.damage = 69
	dropped_item.fire_rate = 1000.0
	
	ItemSpawner.spawn(dropped_item, Vector2(100, 100))

func zoom_camera(camera: Node):
	camera.target_zoom *= Vector2(0.75, 0.75)
