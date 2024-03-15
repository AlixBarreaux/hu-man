extends Node
class_name Pellets


var total_remaining_pellets_count: int = 0
var remaining_pellets_count: int = 0


func on_scene_tree_exited_by_pellet() -> void:
	var pellet_types_node_empty_count: int = 0
	
	for pellet_type_node in self.get_children():
		if pellet_type_node.get_child_count() == 0:
			pellet_types_node_empty_count += 1
		
		if pellet_types_node_empty_count == self.get_child_count():
			Global.level_cleared.emit()


signal initialized

func _ready() -> void:
	var current_callable_on_pellet_picked_up: Callable = Callable()
	var callable_on_normal_pellet_picked_up: Callable = on_normal_pellet_picked_up
	var callable_on_power_pellet_picked_up: Callable = on_power_pellet_picked_up
	
	for pellet_type_group in self.get_children():
		if pellet_type_group.get_name() == "Normal":
			current_callable_on_pellet_picked_up = callable_on_normal_pellet_picked_up
		elif pellet_type_group.get_name() == "Power":
			current_callable_on_pellet_picked_up = callable_on_power_pellet_picked_up
		else:
			printerr("(!) ERROR! In: " + self.name + ": Unhandled pellet type!")
		
		for pellet in pellet_type_group.get_children():
			pellet.picked_up.connect(on_pellet_picked_up)
			pellet.picked_up.connect(current_callable_on_pellet_picked_up)
			pellet.tree_exited.connect(on_scene_tree_exited_by_pellet)
			
			total_remaining_pellets_count += 1
	
	assert(total_remaining_pellets_count > 0)
	
	remaining_pellets_count = total_remaining_pellets_count
	initialized.emit()


signal pellet_picked_up(value: int)
signal normal_pellet_picked_up(value: int)
signal power_pellet_picked_up(value: int)

func on_pellet_picked_up(score_to_add: int) -> void:
	remaining_pellets_count -= 1
	Global.increase_score(score_to_add)
	pellet_picked_up.emit(score_to_add)


func on_normal_pellet_picked_up(score_to_add: int) -> void:
	normal_pellet_picked_up.emit(score_to_add)


func on_power_pellet_picked_up(score_to_add: int) -> void:
	power_pellet_picked_up.emit(score_to_add)
