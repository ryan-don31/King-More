extends Resource
class_name ItemInstance

@export var data: WeaponData
@export var damage: int = 0
@export var fire_rate: float = 0.0

func initialize(weapon_data: WeaponData):
	data = weapon_data
	
func generate_stats():
	#TODO: Make a function to generate stats, given a max/min for damage, fire rate, etc
	pass
