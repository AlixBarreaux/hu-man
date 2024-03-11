extends Node2D
class_name Enemy


@export var speed: float = 1.0
@export var spawn_point: Marker2D = null
@onready var spawn_position: Vector2 = spawn_point.global_position

@export var initial_direction: Vector2 = Vector2(0.0, 1.0)
var direction: Vector2 = self.initial_direction

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func enable() -> void:
	set_physics_process(true)


func disable() -> void:
	set_physics_process(false)


func on_game_started() -> void:
	self.enable()


func on_level_cleared() -> void:
	self.disable()
	#anim_node_sm_playback.travel("Defeat Animation")


@onready var hurt_box: HurtBox = $HurtBox

func set_hurt_box_disabled(value: bool) -> void:
	for collision_shape in hurt_box.get_children():
		collision_shape.call_deferred("set_disabled", value)


@onready var hit_box: Area2D = $HitBox

func set_hit_box_disabled(value: bool) -> void:
	for collision_shape in hit_box.get_children():
		collision_shape.call_deferred("set_disabled", value)


signal died

func die() -> void:
	self.died.emit()


func on_player_died() -> void:
	self.disable()


func on_player_finished_dying() -> void:
	self.set_global_position(spawn_position)
	self.direction = initial_direction
	animation_tree.set("parameters/Move/blend_position", self.direction)


func _initialize_signals() -> void:
	Global.game_started.connect(on_game_started)
	Global.level_cleared.connect(on_level_cleared)
	Global.player_died.connect(on_player_died)
	Global.player_finished_dying.connect(on_player_finished_dying)


func _ready() -> void:
	assert(spawn_point != null)
	
	self.disable()
	self._initialize_signals()
	self.direction = self.initial_direction
	animation_tree.active = true
	animation_tree.set("parameters/Move/blend_position", self.direction)


func _physics_process(_delta: float) -> void:
	self.global_position += direction * speed
	animation_tree.set("parameters/Move/blend_position", direction)
