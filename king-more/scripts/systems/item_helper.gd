extends Node

func load_texture(item_type: ItemTypes.ItemType):
	match item_type:
		ItemTypes.ItemType.WEAPON_BASIC:
			return load("res://assets/sprites/items/basic_gun.png")
		ItemTypes.ItemType.WEAPON_LIGHTNING:
			return load("res://assets/sprites/items/lightning_shocker.png")
		ItemTypes.ItemType.WEAPON_PLASMA:
			return load("res://assets/sprites/items/plasma_ring.png")
		ItemTypes.ItemType.CROWN_FAST:
			return load("res://assets/sprites/items/crown_fast.png")
		ItemTypes.ItemType.CROWN_TANK:
			return load("res://assets/sprites/items/crown_tank.png")
		ItemTypes.ItemType.CROWN_REGEN:
			return load("res://assets/sprites/items/crown_regen.png")
		ItemTypes.ItemType.CROWN_DAMAGE:
			return load("res://assets/sprites/items/crown_damage.png")
		ItemTypes.ItemType.CROWN_FIRERATE:
			return load("res://assets/sprites/items/crown_firerate.png")

func get_item_name(item_type: ItemTypes.ItemType):
	match item_type:
		ItemTypes.ItemType.WEAPON_BASIC:
			return "Revolver"
		ItemTypes.ItemType.WEAPON_LIGHTNING:
			return "Lightning Shocker"
		ItemTypes.ItemType.WEAPON_PLASMA:
			return "Plasma Emitter"
		ItemTypes.ItemType.CROWN_FAST:
			return "Crown of Speed"
		ItemTypes.ItemType.CROWN_TANK:
			return "Crown of the Tank"
		ItemTypes.ItemType.CROWN_REGEN:
			return "Crown of Regen"
		ItemTypes.ItemType.CROWN_DAMAGE:
			return "Crown of Damage"
		ItemTypes.ItemType.CROWN_FIRERATE:
			return "Crown of Reloading Like, Really Fast"
			