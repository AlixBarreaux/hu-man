extends Panel
class_name BonusItemsUI


@onready var level: Level = get_tree().get_root().get_node("Level")
@onready var bonus_items: BonusItems = level.get_node("Pickables/BonusItems")

@onready var textures_container: HBoxContainer = $MarginContainer/HBoxContainer
var texture_rect_list: Array[TextureRect] = []
@onready var level_label: Label = textures_container.get_node("LevelLabel")


func on_bonus_item_picked_up(_value: int, texture: Texture2D) -> void:
	var texture_rect: TextureRect = self.texture_rect_list[bonus_items.total_tiers_count - 1]
	
	texture_rect.set_texture(texture)
	texture_rect.show()


func _ready() -> void:
	bonus_items.item_picked_up.connect(on_bonus_item_picked_up)
	
	level_label.set_text(str(level.id))
	
	for tier in bonus_items.total_tiers_count:
		var texture_instance: TextureRect = TextureRect.new()
		texture_instance.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		texture_instance.hide()
		
		textures_container.add_child(texture_instance, false, Node.INTERNAL_MODE_FRONT)
		texture_rect_list.append(texture_instance)
