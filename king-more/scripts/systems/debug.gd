extends Node

var rng = RandomNumberGenerator.new()

func make_item(mouse_pos: Vector2):
	var dropped_item = ItemInstance.new()
	dropped_item.name = ItemHelper.get_item_name(ItemTypes.ItemType.CROWN_REGEN)
	dropped_item.item_category = ItemTypes.ItemCategory.CROWN
	dropped_item.item_type = ItemTypes.ItemType.CROWN_REGEN
	dropped_item.health_regen = 1.0
	
	ItemSpawner.spawn(dropped_item, mouse_pos)

func make_op_item(mouse_pos: Vector2):
	var dropped_item = ItemInstance.new()
	dropped_item.name = "WRATH OF CRISTIANO"
	dropped_item.item_category = ItemTypes.ItemCategory.WEAPON
	dropped_item.item_type = ItemTypes.ItemType.WEAPON_LIGHTNING
	dropped_item.damage = 10.0
	dropped_item.fire_rate = 0.01
	
	ItemSpawner.spawn(dropped_item, mouse_pos)

func make_random_item(mouse_pos: Vector2):
	var item_pool = [
		ItemTypes.ItemType.WEAPON_BASIC,
		ItemTypes.ItemType.WEAPON_LIGHTNING,
		ItemTypes.ItemType.WEAPON_PLASMA
	]
	var wep = ItemSpawner.generate_random_wep(item_pool, 10, 100, 0.05, 5.0)
	ItemSpawner.spawn(wep, mouse_pos)

func make_random_crown(mouse_pos: Vector2):
	ItemSpawner.spawn(ItemSpawner.generate_random_crown(), mouse_pos)

func zoom_camera(camera: Node):
	camera.target_zoom *= Vector2(0.75, 0.75)
