extends Node

var rng = RandomNumberGenerator.new()

func make_item(mouse_pos: Vector2):
	var dropped_item = ItemInstance.new()
	dropped_item.name = "Plasma Weapon"
	dropped_item.item_type = "plasma_ring"
	dropped_item.damage = snapped(rng.randf_range(50, 100), 0.01)
	dropped_item.fire_rate = snapped(rng.randf_range(0.05, 1), 0.01)
	
	ItemSpawner.spawn(dropped_item, mouse_pos)

func make_random_item(mouse_pos: Vector2):
	var item_pool = [
		ItemTypes.WeaponType.BASIC,
		ItemTypes.WeaponType.PLASMA,
		ItemTypes.WeaponType.LIGHTNING
	]
	ItemSpawner.spawn_random_wep(item_pool, mouse_pos, 10, 100, 0.05, 3.0)

func zoom_camera(camera: Node):
	camera.target_zoom *= Vector2(0.75, 0.75)
