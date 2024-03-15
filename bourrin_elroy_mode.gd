extends Node
class_name BourrinElroyMode


@export var enemy_ai: EnemyAIBourrin = null
@onready var enemy: Enemy = enemy_ai.enemy
@onready var enemy_ai_to_wait_enable_ai_timer: Timer = get_tree().get_root().get_node("World/Actors/Enemies/EnemyCornichon/EnemyAICornichon/EnableAITimer")
@onready var pellets_node: Pellets = get_tree().get_root().get_node("World/Pickables/Pellets")


var percentage_tier_1: float = 0.08
var percentage_tier_2: float = 0.04

# Assigned on initialization
var remaining_pellets_count: int = 0
var tier_1_pellet_count_treshold: int = 0
var tier_2_pellet_count_treshold: int = 0


func on_pellets_node_initialized() -> void:
	remaining_pellets_count = pellets_node.remaining_pellets_count
	
	tier_1_pellet_count_treshold = round(remaining_pellets_count * percentage_tier_1)
	tier_2_pellet_count_treshold = round(remaining_pellets_count * percentage_tier_2)
	
	if remaining_pellets_count <= 2:
		self.queue_free()
	
	if tier_1_pellet_count_treshold == tier_2_pellet_count_treshold:
		tier_1_pellet_count_treshold = 2
		tier_2_pellet_count_treshold = 1


func on_pellet_picked_up(value: int) -> void:
	remaining_pellets_count = pellets_node.remaining_pellets_count
	self.check_if_should_enable_elroy_mode()


func on_player_died() -> void:
	disable_elroy_mode()


func on_enemy_to_wait_went_out() -> void:
	self.check_if_should_enable_elroy_mode()


func _ready() -> void:
	assert(enemy_ai != null)
	assert(enemy_ai_to_wait_enable_ai_timer != null)
	
	pellets_node.initialized.connect(on_pellets_node_initialized)
	pellets_node.pellet_picked_up.connect(on_pellet_picked_up)
	Global.player_died.connect(on_player_died)
	enemy_ai_to_wait_enable_ai_timer.timeout.connect(on_enemy_to_wait_went_out)


func check_if_should_enable_elroy_mode() -> void:
	if remaining_pellets_count <= tier_2_pellet_count_treshold:
		enable_elroy_mode(true)
		return
	elif remaining_pellets_count <= tier_1_pellet_count_treshold:
		enable_elroy_mode(false)
		return


func enable_elroy_mode(go_faster_than_player: bool) -> void:
	enemy_ai.elroy_mode_enabled = true
	
	if not go_faster_than_player:
		enemy_ai.chase_speed = enemy_ai.initial_chase_speed * 2.0
	else:
		# ~ as fast as Player
		enemy_ai.chase_speed = enemy_ai.initial_chase_speed * 2.7
	
	
	if enemy_ai.current_state == enemy_ai.States.CHASE:
		# REFACTOR: Could reset to chase state again to change the speed
		# but doesn't seem to work:
		#enemy_ai.set_state(enemy_ai.States.CHASE)
		enemy.speed = enemy_ai.chase_speed
	elif enemy_ai.current_state == enemy_ai.States.SCATTER:
		enemy_ai.set_state(enemy_ai.States.CHASE)


func disable_elroy_mode() -> void:
	enemy_ai.elroy_mode_enabled = false
	enemy_ai.chase_speed = enemy_ai.initial_chase_speed
	enemy_ai.set_state(enemy_ai.initial_state)
