extends CharacterBody2D


@export var speed: float = 100.0
var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	print(self, " enemy heating seeking: ", player)

func _physics_process(delta: float) -> void:
	# tries to chase the player if it e	xists
	if player:
		var direction = global_position.direction_to(player.global_position)
		
		velocity = direction * speed
		
		move_and_slide()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# placeholder, something like
		# body.take_damage(10) # not implemented yet
		print(self, " hit the player!")
		# despawning rn to save space but change this body logic later
		queue_free()
