extends Node
class_name Pellets


func on_scene_tree_exited_by_pellet() -> void:
	var pellet_types_node_empty_count: int = 0
	
	for pellet_type_node in self.get_children():
		if pellet_type_node.get_child_count() == 0:
			pellet_types_node_empty_count += 1
		
		if pellet_types_node_empty_count == self.get_child_count():
			Global.level_cleared.emit()


func _ready() -> void:
	for pellet_type_group in self.get_children():
		for pellet in pellet_type_group.get_children():
			pellet.picked_up.connect(on_pellet_picked_up)
			pellet.tree_exited.connect(on_scene_tree_exited_by_pellet)


func on_pellet_picked_up(score_to_add: int) -> void:
	Global.increase_score(score_to_add)
