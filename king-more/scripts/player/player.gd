extends CharacterBody2D

# Movement stuff
const SPEED = 300.0

# Inventory/equipment stuff
@export var inventory: Inventory # Player's inventory
@export var equipment: Equipment # Currently equipped item

@export var debug: bool

func _ready():
	inventory = Inventory.new()
	equipment = Equipment.new()
	
func attack():
	var weapon = equipment.weapon
	if weapon == null:
		pass
	
	if weapon.data is GunData:
		shoot_gun(weapon)
	# Under this if statement is where I'll put things like swinging melee, using diff weapon types, etc

func shoot_gun(weapon: ItemInstance):
	print(weapon) # Using this just for debugging

func _physics_process(delta: float) -> void:
	if debug:
		handle_debug()
	
	var direction = get_input_direction()
	
	velocity = direction * SPEED
	
	move_and_slide()

func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func handle_debug():
	if Input.is_action_just_pressed("debug"):
		var gun_template = GunData.new()
		gun_template.name = "Basic Gun"
		gun_template.damage = 69
		gun_template.fire_rate = 1000.0
		
		var dropped_item = ItemInstance.new()
		dropped_item.initialize(gun_template)
		
		spawn_world_item(dropped_item, Vector2(100, 100))
		
func spawn_world_item(item_instance: ItemInstance, position: Vector2):
	var scene = preload("res://scenes/items/world_item.tscn")
	var world_item = scene.instantiate()
	world_item.item = item_instance
	world_item.position = position
	get_tree().current_scene.add_child(world_item)
