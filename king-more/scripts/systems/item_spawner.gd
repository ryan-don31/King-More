extends Node

const WORLD_ITEM_SCENE = preload("res://scenes/items/world_item.tscn")
var rng = RandomNumberGenerator.new()

var crown_types = [
	ItemTypes.ItemType.CROWN_DAMAGE,
	ItemTypes.ItemType.CROWN_FAST,
	ItemTypes.ItemType.CROWN_REGEN,
	ItemTypes.ItemType.CROWN_TANK
]

var weapon_types = [
	ItemTypes.ItemType.WEAPON_BASIC,
	ItemTypes.ItemType.WEAPON_LIGHTNING,
	ItemTypes.ItemType.WEAPON_PLASMA
]

var adjectives = [
	"Awesome",
	"Ugly",
	"Sweaty",
	"Powerful",
	"Sharp-Shooting",
	"Dreamy",
	"Toe-Tickling",
	"Green",
	"The Best"
]

func generate_weapon(weapon_type: ItemTypes.ItemType, name: String, damage: float, fire_rate: float):
	var item_instance = ItemInstance.new()
	item_instance.name = name
	item_instance.item_category = ItemTypes.ItemCategory.WEAPON
	item_instance.item_type = weapon_type
	item_instance.damage = damage
	item_instance.fire_rate = fire_rate
	return item_instance
	
func generate_random_crown():
	var item_instance = ItemInstance.new()
	var chosen_type = crown_types.pick_random()
	item_instance.name = ItemHelper.get_item_name(chosen_type)
	item_instance.item_category = ItemTypes.ItemCategory.CROWN
	item_instance.item_type = chosen_type

	# Setting attributes based on crown type
	match chosen_type:
		ItemTypes.ItemType.CROWN_DAMAGE:
			item_instance.damage_boost = 100.0
		ItemTypes.ItemType.CROWN_FAST:
			item_instance.extra_speed = 200.0
		ItemTypes.ItemType.CROWN_REGEN:
			item_instance.health_regen = 1.0
		ItemTypes.ItemType.CROWN_TANK:
			item_instance.extra_health = 100.0

	return item_instance

# Formerly "Spawn random wep"
func generate_random_wep(weapon_type_pool: Array, min_damage: float, max_damage: float, min_fire_rate: float, max_fire_rate: float):
	if weapon_type_pool.is_empty():
		return

	var item_instance = ItemInstance.new()
	var chosen_type = weapon_type_pool.pick_random()
	item_instance.name = adjectives.pick_random() + " " + ItemHelper.get_item_name(chosen_type)
	item_instance.item_category = ItemTypes.ItemCategory.WEAPON
	item_instance.item_type = chosen_type
	item_instance.damage = snapped(rng.randf_range(min_damage, max_damage), 0.01)
	item_instance.fire_rate = snapped(rng.randf_range(min_fire_rate, max_fire_rate), 0.01)

	# Balancing weapon based on type
	match chosen_type:
		ItemTypes.ItemType.WEAPON_BASIC:
			pass
		ItemTypes.ItemType.WEAPON_LIGHTNING:
			item_instance.damage *= 0.8
		ItemTypes.ItemType.WEAPON_PLASMA:
			item_instance.fire_rate *= 3

	return item_instance

func spawn(item_instance: ItemInstance, position: Vector2, scene: Node):
	var world_item = WORLD_ITEM_SCENE.instantiate()
	world_item.item = item_instance
	world_item.position = position
	scene.add_child(world_item)
