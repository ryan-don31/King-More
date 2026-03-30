extends CharacterBody2D

# Movement stuff
const SPEED = 300.0

@onready var item_pivot = $ItemPivot
@onready var camera = $Camera2D
@onready var player_sprite = $PlayerSprite
@onready var item_sprite = $ItemPivot/ItemSprite

# Inventory/equipment stuff
@export var inventory: Inventory # Player's inventory

@export var debug: bool

func _ready():
	print("test")
	inventory = Inventory.new()
	
func use():
	var item = inventory.selected_item
	
	if(item):
		print("Item:",item.item_type.name,"Damage:",item.damage)
		var projectile = preload("res://scenes/projectile/projectile.tscn").instantiate()
		
		projectile.global_position = global_position
		
		var dir = (get_global_mouse_position() - global_position).normalized()
		projectile.direction = dir
		
		get_tree().current_scene.add_child(projectile)
	# TODO: Setup what happens when you use the item

func _process(delta: float) -> void:
	if debug:
		handle_debug()
		
	check_inputs()
	animate_item()

func animate_item():
	var mouse_pos = get_global_mouse_position()
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	# Look at the mouse
	item_pivot.look_at(mouse_pos)
	
	# Is player holding an item?
	if(inventory.selected_item):
		item_sprite.visible = true
	else:
		item_sprite.visible = false
	
	# Flip if facing left/right
	if direction.x < 0:
		item_pivot.scale.y = -1
		player_sprite.scale.x = -0.5
	else:
		item_pivot.scale.y = 1
		player_sprite.scale.x = 0.5

func _physics_process(delta: float) -> void:
	var direction = get_move_direction()
	
	velocity = direction * SPEED
	
	move_and_slide()

func get_move_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func check_inputs():
	# Sorts out what to do when the player scrolls up/down on the mouse wheel
	# Probably just going to be changing which inventory item is selected
	if Input.is_action_just_pressed("scroll_up"):
		inventory.slot_change(-1)
	if Input.is_action_just_pressed("scroll_down"):
		inventory.slot_change(1)
		
	if Input.is_action_just_pressed("use"):
		use()

func handle_debug():
	if Input.is_action_just_pressed("debug_1"):
		Debug.make_item()
		
	if Input.is_action_just_pressed("debug_2"):
		Debug.zoom_camera(camera)
