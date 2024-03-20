extends Panel
class_name BonusItemsUI


@onready var bonus_items: BonusItems = get_tree().get_root().get_node("Level/Pickables/BonusItems")


func on_bonus_item_picked_up(_value: int) -> void:
	pass


func _ready() -> void:
	bonus_items.item_picked_up.connect(on_bonus_item_picked_up)
