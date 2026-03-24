extends CharacterBody2D

# Movement stuff
const SPEED = 300.0

# Inventory/equipment stuff
@export var inventory: Inventory # Player's inventory

@export var debug: bool

func _ready():
	inventory = Inventory.new()
	
func use():
	var item = inventory.selected_item
	
	if(item):
		print("Weapon:",item.item_type.name,"Damage:",item.damage)
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
		inventory.slot_change(-1)
	if Input.is_action_just_pressed("scroll_down"):
		inventory.slot_change(1)

func get_use():
	if Input.is_action_just_pressed("use"):
		use()

# These two functions down here are #FUGLY, I need to put them somewhere else
func handle_debug():
	if Input.is_action_just_pressed("debug"):
		var dropped_item = ItemInstance.new()
		dropped_item.item_type.name = "Basic Weapon"
		dropped_item.damage = 69
		dropped_item.fire_rate = 1000.0
		
		ItemSpawner.spawn(dropped_item, Vector2(100, 100))
