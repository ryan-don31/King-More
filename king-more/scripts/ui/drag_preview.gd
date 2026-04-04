extends Control

var item_instance: ItemInstance
@onready var preview_icon: TextureRect = $TextureRect

func show_preview(dragged_item):
    item_instance = dragged_item
    preview_icon.texture = ItemHelper.load_texture(item_instance.item_type, item_instance.weapon_type)
    visible = true

func hide_preview():
    visible = false