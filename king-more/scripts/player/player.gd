extends CharacterBody2D

# Movement stuff
const SPEED = 300.0

@onready var item_pivot = $ItemPivot
@onready var camera = $Camera2D
@onready var player_sprite = $PlayerSprite
@onready var item_sprite = $ItemPivot/ItemSprite
@onready var use_cooldown = $UseCooldown
@onready var player_status_control = $PlayerStatusControl

@export var max_health: float = 100.0
var health: float = 100.0

var invincible_timer = 0.0

# Inventory/equipment stuff
var inventory: Inventory # Player's inventory

func _ready():
	inventory = Inventory.new()
	
# USING ITEMS
func use():
	var item = inventory.selected_item
	
	match item.weapon_type:
		ItemTypes.WeaponType.BASIC:
			var projectile = preload("res://scenes/projectile/projectile.tscn").instantiate()
			var dir = (get_global_mouse_position() - global_position).normalized()
			projectile.global_position = global_position
			projectile.direction = dir
			projectile.damage = inventory.selected_item.damage
			get_tree().current_scene.add_child(projectile)

		ItemTypes.WeaponType.LIGHTNING:
			var projectile = preload("res://scenes/projectile/lightning_shock.tscn").instantiate()
			projectile.global_position = global_position
			projectile.target_pos = get_local_mouse_position()
			projectile.damage = inventory.selected_item.damage
			get_tree().current_scene.add_child(projectile)
			
		ItemTypes.WeaponType.PLASMA:
			var projectile = preload("res://scenes/projectile/plasma_ring.tscn").instantiate()
			var dir = (get_global_mouse_position() - global_position).normalized()
			projectile.global_position = global_position
			projectile.direction = dir
			projectile.damage = inventory.selected_item.damage
			get_tree().current_scene.add_child(projectile)

func _process(_delta: float) -> void:
	check_invincible()

	if(inventory.selected_item):
		render_cooldown_bar()

	if(!UiManager.inventory_open):	
		handle_debug()
		check_inputs()
		animate_item()

		var direction = get_move_direction()
		velocity = direction * SPEED
		move_and_slide()

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

func get_move_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func check_inputs():
	# Sorts out what to do when the player scrolls up/down on the mouse wheel
	# Probably just going to be changing which inventory item is selected
	if Input.is_action_just_pressed("scroll_up"):
		inventory.slot_change(-1)
	if Input.is_action_just_pressed("scroll_down"):
		inventory.slot_change(1)

	if Input.is_action_pressed("use") and inventory.selected_item and inventory.selected_item.is_ready():
		inventory.selected_item.start_cooldown_timer()
		use()

func take_damage(damage: float):
	if(invincible_timer <= 0.0):
		health -= damage
		invincible_timer = 50.0

func check_invincible():
	if(invincible_timer > 0.0):
		invincible_timer -= 1.0
		modulate.a = 0.5
	else:
		modulate.a = 1.0

func render_cooldown_bar():
	var cooldown_progress = inventory.selected_item.get_cooldown_progress()
	player_status_control.reload_value = 1 - cooldown_progress

func handle_debug():
	if Input.is_action_just_pressed("debug_1"):
		Debug.make_random_item(get_global_mouse_position())
		
	if Input.is_action_just_pressed("debug_2"):
		Debug.zoom_camera(camera)
