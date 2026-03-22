extends CharacterBody2D

# Movement stuff
const SPEED = 300.0

# Inventory/equipment stuff
@export var inventory: Inventory # Player's inventory
@export var equipment: Equipment # Currently equipped item

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
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")
	var direction_y := Input.get_axis("up", "down")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
