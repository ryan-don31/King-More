extends Node

const WORLD_ITEM_SCENE = preload("res://scenes/items/world_item.tscn")
var rng = RandomNumberGenerator.new()

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

func generate_weapon(weapon_type: ItemTypes.WeaponType, name: String, damage: float, fire_rate: float):
	var item_instance = ItemInstance.new()
	item_instance.name = name
	item_instance.item_type = ItemTypes.ItemType.WEAPON
	item_instance.weapon_type = weapon_type
	item_instance.damage = damage
	item_instance.fire_rate = fire_rate
	return item_instance
	

func spawn_random_wep(weapon_type_pool: Array, position: Vector2, min_damage: float, max_damage: float, min_fire_rate: float, max_fire_rate: float):
	if weapon_type_pool.is_empty():
		return

	var world_item = WORLD_ITEM_SCENE.instantiate()
	var chosen_type = weapon_type_pool.pick_random()
	var damage = snapped(rng.randf_range(min_damage, max_damage), 0.01)
	var fire_rate = snapped(rng.randf_range(min_fire_rate, max_fire_rate), 0.01)
	var weapon_name = ""

	weapon_name = adjectives.pick_random() + " " + ItemHelper.get_item_name(ItemTypes.ItemType.WEAPON, chosen_type)

	world_item.item = generate_weapon(chosen_type, weapon_name, damage, fire_rate)
	world_item.position = position

	get_tree().current_scene.add_child(world_item)



func spawn(item_instance: ItemInstance, position: Vector2):
	var world_item = WORLD_ITEM_SCENE.instantiate()
	world_item.item = item_instance
	world_item.position = position
	get_tree().current_scene.add_child(world_item)
