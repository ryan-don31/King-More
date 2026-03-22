extends Resource
class_name ItemInstance

@export var data: WeaponData
@export var damage: int = 0
@export var fire_rate: float = 0.0

func generate_stats():
	# TODO: make a system for generating damage + fire rate based off the current game state
	pass
