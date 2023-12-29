extends Node2D
class_name Enemy


@export var speed: float = 1.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


@export var target_node: Node2D = null

func _ready() -> void:
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	set_physics_process(false)
	call_deferred("initialize")


func _physics_process(delta: float) -> void:
	nav_agent.set_target_position(target_node.global_position)
	
	# SIGNAL INSTEAD? -> navigation_finished
	if nav_agent.is_navigation_finished():
		#print("Navigation finished.")
		return

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	
	self.global_position += axis * speed



func initialize():
	set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	nav_agent.set_target_position(target_node.global_position)
