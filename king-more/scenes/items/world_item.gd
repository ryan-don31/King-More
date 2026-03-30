extends Node2D

# This is the actual item you see on the floor in the world

var item: ItemInstance
var player: CharacterBody2D = null

@export var pickup_range: float = 80.0
@export var attract_range: float = 150.0
@export var attract_speed: float = 300.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance < attract_range:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * attract_speed * _delta

	if distance < pickup_range:
		pickup()

func pickup():
	#TODO: Refactor this it's really lame
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.inventory.add_item(item):
		queue_free()
