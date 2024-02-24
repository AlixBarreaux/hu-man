extends Node2D
class_name Enemy


@export var speed: float = 1.0

var direction: Vector2 = Vector2(0.0, 1.0)

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready() -> void:
	animation_tree.active = true


func _physics_process(_delta: float) -> void:
	self.global_position += direction * speed
	animation_tree.set("parameters/Move/blend_position", direction)
