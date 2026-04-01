extends CharacterBody2D


@export var speed: float = 50.0
@export var max_health: float = 30 

var player: Node2D
var current_health: int

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	print(self, " enemy heating seeking: ", player)

func _physics_process(delta: float) -> void:
	# tries to chase the player if it exists
	if player:
		var direction = global_position.direction_to(player.global_position)

		velocity = direction * speed

		move_and_slide()

func take_damage(amount: float) -> void:
	current_health -= amount
	print(self, " took ", amount, "damage! HP is ", current_health, '/', max_health)
	if current_health <= 0:
		queue_free()
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# placeholder, something like
		# body.take_damage(10) # not implemented yet
		print(self, " hit the player!")
		# despawning rn to save space but change this body logic later
		#queue_free()
