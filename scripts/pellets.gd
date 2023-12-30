extends Node
class_name Pellets




func _ready() -> void:
	for pellet in self.get_children():
		pellet.picked_up.connect(on_pellet_picked_up)


func on_pellet_picked_up(score_to_add: int) -> void:
	Global.increase_score(score_to_add)
	
	if self.get_child_count() <= 0:
		Global.level_cleared.emit()
