extends Node2D

# This is the actual item you see on the floor in the world

@export var item: ItemInstance
@onready var sprite: Sprite2D = $Sprite2D

func setup(new_item: ItemInstance):
	item = new_item
	sprite.texture = preload("res://icon.svg")
	
# TODO: Add something here for user pushing E with mouse over the weapon
