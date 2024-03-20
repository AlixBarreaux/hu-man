extends Node
class_name BonusItems


signal item_picked_up(value: int)

func on_bonus_item_picked_up(value: int) -> void:
	self.item_picked_up.emit(value)


func _ready() -> void:
	for bonus_item in self.get_children():
		bonus_item.picked_up.connect(on_bonus_item_picked_up)
