extends Resource
class_name WeaponRuntime

var item: ItemInstance

var last_fire_time := -INF

# This code is SLOPTACULAR!!
# Basically runs things like cooldown statuses on weapons without needing to keep an eye on them every frame
# Only checks if it's ready to use or not when needed based on timestamps
# Also gets cooldown progress only when needed to be actively monitored

func get_cooldown_progress() -> float:
	var t := Time.get_ticks_msec() / 1000.0
	var cd := item.fire_rate

	if cd <= 0:
		return 1.0

	return clamp((t - last_fire_time) / cd, 0.0, 1.0)

func is_ready() -> bool:
	return get_cooldown_progress() >= 1.0

func fire():
	last_fire_time = Time.get_ticks_msec() / 1000.0