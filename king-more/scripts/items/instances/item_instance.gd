extends Resource
class_name ItemInstance

signal cooldown_started

var name: String = ""
var item_category: ItemTypes.ItemCategory
var item_type: ItemTypes.ItemType

# Weapon attributes
var damage: float = 0.0		# OPTIONAL - Damage dealt
var healing: float = 0.0	# OPTIONAL - Healing dealt
var fire_rate: float = 0.0	# Time in seconds between uses

# Crown attributes
var extra_health: float = 0.0
var extra_speed: float = 0.0
var health_regen: float = 0.0
var damage_boost: float = 0.0
var fire_rate_boost: float = 0.0

var last_fire_time := -INF

func _to_string() -> String:
	return "ItemInstance(name=%s, item_type=%s, damage=%d, healing=%d, fire_rate=%d)" % [name, item_type, damage, healing, fire_rate]

func get_cooldown_progress() -> float:
	var current_time_seconds := Time.get_ticks_msec() / 1000.0
	var cooldown_duration := fire_rate
	var time_since_last_fire := current_time_seconds - last_fire_time
	var progress := time_since_last_fire / cooldown_duration

	return clamp(progress, 0.0, 1.0)

func is_ready() -> bool:
	return get_cooldown_progress() >= 1.0

func start_cooldown_timer():
	cooldown_started.emit()
	last_fire_time = Time.get_ticks_msec() / 1000.0
