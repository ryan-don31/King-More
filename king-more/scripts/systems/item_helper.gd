extends Node

func load_texture(item_type: ItemTypes.ItemType, weapon_type: ItemTypes.WeaponType):
	match weapon_type:
		ItemTypes.WeaponType.BASIC:
			return load("res://assets/sprites/items/basic_gun.png")
		ItemTypes.WeaponType.LIGHTNING:
			return load("res://assets/sprites/items/lightning_shocker.png")
		ItemTypes.WeaponType.PLASMA:
			return load("res://assets/sprites/items/plasma_ring.png")

func get_item_name(item_type: ItemTypes.ItemType, weapon_type: ItemTypes.WeaponType):
	match weapon_type:
		ItemTypes.WeaponType.BASIC:
			return "Revolver"
		ItemTypes.WeaponType.LIGHTNING:
			return "Lightning Shocker"
		ItemTypes.WeaponType.PLASMA:
			return "Plasma Ball"