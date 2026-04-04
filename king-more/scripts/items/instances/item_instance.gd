extends Resource
class_name ItemInstance

var name: String = ""
var item_type: ItemTypes.ItemType
var weapon_type: ItemTypes.WeaponType
var damage: float = 0.0		# OPTIONAL - Damage dealt
var healing: float = 0.0	# OPTIONAL - Healing dealt
var fire_rate: float = 0.0	# Time in seconds between uses

func _to_string() -> String:
	return "ItemInstance(name=%s, item_type=%s, damage=%d, healing=%d, fire_rate=%d)" % [name, item_type, damage, healing, fire_rate]

func generate_stats():
	#TODO: Make a function to generate stats, given a max/min for damage, fire rate, etc
	pass
