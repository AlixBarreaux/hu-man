extends Node2D
class_name Enemy


@export var speed: float = 1.0
@export var spawn_point: Marker2D = null
@onready var spawn_position: Vector2 = spawn_point.global_position

var direction: Vector2 = Vector2(0.0, 0.0)

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func on_game_started() -> void:
	pass


func on_player_died() -> void:
	pass


func on_player_finished_dying() -> void:
	self.set_global_position(spawn_position)


func _ready() -> void:
	assert(spawn_point != null)
	
	animation_tree.active = true
	
	Global.game_started.connect(on_game_started)
	Global.player_died.connect(on_player_died)
	Global.player_finished_dying.connect(on_player_finished_dying)


func _physics_process(_delta: float) -> void:
	self.global_position += direction * speed
	animation_tree.set("parameters/Move/blend_position", direction)
