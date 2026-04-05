extends Node2D

# This is the actual item you see on the floor in the world

var item: ItemInstance
var player: CharacterBody2D = null

@export var pickup_range: float = 80.0
@export var attract_range: float = 150.0
@export var attract_speed: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = ItemHelper.load_texture(item.item_type)
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
	if player and player.inventory.add_item(item):
		queue_free()
