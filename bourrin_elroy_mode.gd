extends Node
class_name BourrinElroyMode


@export var enemy_ai: EnemyAIBourrin = null
@onready var pellets_node: Pellets = get_tree().get_root().get_node("World/Pickables/Pellets")


var percentage_tier_1: float = 0.08
var percentage_tier_2: float = 0.04

# Assigned on initialization
var remaining_pellets_count: int = 0
var tier_1_pellet_count_treshold: int = 0
var tier_2_pellet_count_treshold: int = 0


func on_pellets_node_initialized() -> void:
	print(self.name, ": Pellets initialized, count: ", pellets_node.remaining_pellets_count)
	remaining_pellets_count = pellets_node.remaining_pellets_count
	
	tier_1_pellet_count_treshold = round(remaining_pellets_count * percentage_tier_1)
	tier_2_pellet_count_treshold = round(remaining_pellets_count * percentage_tier_2)
	
	print("Tier 1 initialized: ", tier_1_pellet_count_treshold)
	print("Tier 2 initialized: ", tier_2_pellet_count_treshold)


func on_pellet_picked_up(value: int) -> void:
	remaining_pellets_count = pellets_node.remaining_pellets_count
	self.check_if_should_enable_elroy_mode()


func _ready() -> void:
	assert(enemy_ai != null)
	
	pellets_node.initialized.connect(on_pellets_node_initialized)
	pellets_node.pellet_picked_up.connect(on_pellet_picked_up)


func check_if_should_enable_elroy_mode() -> void:
	if remaining_pellets_count <= tier_2_pellet_count_treshold:
		print("Tier 2 elroy: ", remaining_pellets_count)
		enable_elroy_mode(true)
		return
	elif remaining_pellets_count <= tier_1_pellet_count_treshold:
		print("Tier 1 elroy: ", remaining_pellets_count)
		enable_elroy_mode(false)
		return
	print("No elroy: ", remaining_pellets_count)


func enable_elroy_mode(faster_than_player: bool) -> void:
	# Lock in chase mode
	
	if faster_than_player:
		# Set speed to faster than player
		return
	# Set speed to same than player


func disable_elroy_mode() -> void:
	pass
