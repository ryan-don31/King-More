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
	var item = equipment.item
	# TODO: Setup what happens when you use the item


func _physics_process(delta: float) -> void:
	if debug:
		handle_debug()
		
	get_scroll()
	get_use()
	
	var direction = get_input_direction()
	
	velocity = direction * SPEED
	
	move_and_slide()

func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func get_scroll():
	# Sorts out what to do when the player scrolls up/down on the mouse wheel
	# Probably just going to be changing which inventory item is selected
	if Input.is_action_just_pressed("scroll_up"):
		equipment.weapon = inventory.slot_change(-1)
	if Input.is_action_just_pressed("scroll_down"):
		equipment.weapon = inventory.slot_change(1)

func get_use():
	if Input.is_action_just_pressed("use"):
		attack()

# These two functions down here are #FUGLY, I need to put them somewhere else
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
