extends CharacterBody2D

# Player attributes
@export var base_speed: float = 200.0
@export var base_max_health: float = 100.0
@export var base_health_regen: float = 0.0
var speed: float = base_speed
var max_health: float = base_max_health
var health_regen: float = base_health_regen
var damage_boost: float = 0.0
var fire_rate_boost: float = 0.0

# Dash stuff
const DASH_SPEED = 900.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.8

var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO

@onready var item_pivot = $ItemPivot
@onready var camera = $Camera2D
@onready var player_sprite = $PlayerSprite
@onready var item_sprite = $ItemPivot/ItemSprite
@onready var use_cooldown = $UseCooldown
@onready var dash_cooldown = $DashCooldown
@onready var player_status_control = $PlayerStatusControl

# Current status
var health: float = 100.0

var invincible_timer = 0.0

# Inventory/equipment stuff
var inventory: Inventory # Player's inventory

func _ready():
	inventory = Inventory.new()
	inventory.inventory_changed.connect(check_crowns)
	
# USING ITEMS
func use():
	var item = inventory.selected_item

	print(item)
	
	if(item.item_type):
		match item.item_type:
			ItemTypes.ItemType.WEAPON_BASIC:
				var projectile = preload("res://scenes/projectile/projectile.tscn").instantiate()
				var dir = (get_global_mouse_position() - global_position).normalized()
				projectile.global_position = global_position
				projectile.direction = dir
				projectile.damage = inventory.selected_item.damage + damage_boost
				print("Getting here")
				get_tree().current_scene.add_child(projectile)

			ItemTypes.ItemType.WEAPON_LIGHTNING:
				var projectile = preload("res://scenes/projectile/lightning_shock.tscn").instantiate()
				projectile.global_position = global_position
				projectile.target_pos = get_local_mouse_position()
				projectile.damage = inventory.selected_item.damage + damage_boost
				get_tree().current_scene.add_child(projectile)
				
			ItemTypes.ItemType.WEAPON_PLASMA:
				var projectile = preload("res://scenes/projectile/plasma_ring.tscn").instantiate()
				var dir = (get_global_mouse_position() - global_position).normalized()
				projectile.global_position = global_position
				projectile.direction = dir
				projectile.damage = inventory.selected_item.damage + damage_boost
				get_tree().current_scene.add_child(projectile)

func check_crowns():
	# Looping through because I plan to add multiple crown slots
	for crown in inventory.crown_slots:
		if(crown):
			max_health = base_max_health + crown.extra_health
			speed = base_speed + crown.extra_speed
			health_regen = base_health_regen + crown.health_regen
			damage_boost = crown.damage_boost
			fire_rate_boost = crown.fire_rate_boost
		else:
			max_health = base_max_health
			speed = base_speed
			health_regen = base_health_regen
			damage_boost = 0.0
			fire_rate_boost = 0.0

func _process(delta: float) -> void:
	check_invincible()

	if(inventory.selected_item):
		render_cooldown_bar()

	if(!UiManager.inventory_open):
		# handle_debug()
		check_inputs()
		animate_item()

		if is_dashing:
			dash_timer -= delta
			velocity = dash_direction * DASH_SPEED
			if dash_timer <= 0.0:
				is_dashing = false
		else:
			var direction = get_move_direction()
			velocity = direction * speed

		move_and_slide()

func animate_item():
	var mouse_pos = get_global_mouse_position()
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	# Look at the mouse
	item_pivot.look_at(mouse_pos)
	
	# Is player holding an item?
	if(inventory.selected_item):
		item_sprite.texture = ItemHelper.load_texture(inventory.selected_item.item_type)
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

	if Input.is_action_just_pressed("dodge") and not is_dashing and dash_cooldown.is_stopped():
		var dir = get_move_direction()
		if dir == Vector2.ZERO:
			dir = (get_global_mouse_position() - global_position).normalized()
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_direction = dir
		invincible_timer = DASH_DURATION * 60.0
		dash_cooldown.start(DASH_COOLDOWN)

func take_damage(damage: float):
	if(invincible_timer <= 0.0):
		health -= damage
		invincible_timer = 50.0
	if health <= 0:
		GameState.game_over()

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
		Debug.make_item(get_global_mouse_position())
		
	if Input.is_action_just_pressed("debug_2"):
		Debug.zoom_camera(camera)


func _on_health_regen_cooldown_timeout() -> void:
	if health_regen > 0:
		health += health_regen
	if health > max_health:
		health = max_health
