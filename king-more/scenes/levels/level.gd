extends Node2D


func _ready() -> void:
	UiManager.inventory_ui = $CanvasLayer/InventoryUI
	UiManager.player_inventory = $Player.inventory


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
