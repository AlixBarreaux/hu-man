extends Node2D
class_name Enemy


@export var speed: float = 1.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


@export var player: Player = null
@export var tile_map: TileMap = null

@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x
var direction: Vector2 = Vector2(0.0, 1.0)


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


# OVERRIDE THIS
var destination_position: Vector2 = Vector2(0.0, 0.0)

func _set_destination_position() -> void:
	printerr(self.name  + ": _set_destination_position() must be implemented!")


func _initialize():
	set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target
	_set_destination_position()
	nav_agent.set_target_position(destination_position)


func _ready() -> void:
	animation_tree.active = true
	set_physics_process(false)
	call_deferred("_initialize")


func _physics_process(delta: float) -> void:
	print(self.name, "Destination value to override: ", destination_position)
	_set_destination_position()
	nav_agent.set_target_position(destination_position)
	
	# SIGNAL INSTEAD? -> navigation_finished
	if nav_agent.is_navigation_finished():
		#print("Navigation finished.")
		return

	direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	self.global_position += direction * speed
	animation_tree.set("parameters/Move/blend_position", direction)
