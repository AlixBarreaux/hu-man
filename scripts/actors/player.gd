extends CharacterBody2D
class_name Player


@export var speed: float = 150.0
@export var spawn_point: Marker2D = null

@onready var spawn_position: Vector2 = spawn_point.global_position

var movement_input_vector: Vector2 = Vector2(0.0, 0.0)
var initial_direction: Vector2 = Vector2(1.0, 0.0)
var direction: Vector2 = self.initial_direction
var next_direction: Vector2 = direction


func _unhandled_key_input(event: InputEvent) -> void:
	movement_input_vector = Vector2(0.0, 0.0)
	
	movement_input_vector.x = Input.get_axis("move_left", "move_right")
	if movement_input_vector.x != 0: return
	
	movement_input_vector.y = Input.get_axis("move_up", "move_down")


@onready var next_direction_detector: Node2D = $NextDirectionRotator/NextDirectionDetector

func can_go_in_next_direction() -> bool:
	for raycast in next_direction_detector.get_children():
		if raycast.is_colliding():
			return false
	return true


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


@onready var hurt_box: HurtBox = $HurtBox

func enable() -> void:
	self.set_physics_process(true)
	self.set_process_unhandled_key_input(true)
	hurt_box.enable()


func disable() -> void:
	self.set_physics_process(false)
	self.set_process_unhandled_key_input(false)
	hurt_box.disable()


func die() -> void:
	self.disable()
	Global.decrease_lives()
	anim_node_sm_playback.travel("die")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		Global.player_finished_dying.emit()


func on_game_ready() -> void:
	animation_tree.set("parameters/idle/blend_position", next_direction)
	anim_node_sm_playback.travel("idle")


func on_game_started() -> void:
	self.enable()


func on_level_cleared() -> void:
	self.disable()
	animation_tree.set("parameters/idle/blend_position", next_direction)
	anim_node_sm_playback.travel("idle")


func on_finished_dying() -> void:
	if Global.is_game_over: return
	self.set_global_position(self.spawn_position)


func _ready() -> void:
	assert(spawn_point != null)
	
	Global.game_ready.connect(on_game_ready)
	Global.game_started.connect(on_game_started)
	Global.level_cleared.connect(on_level_cleared)
	Global.player_finished_dying.connect(on_finished_dying)
	
	animation_tree.active = true
	self.disable()


@onready var next_direction_rotator: Node2D = $NextDirectionRotator

func _physics_process(_delta: float) -> void:
	if can_go_in_next_direction():
		direction = next_direction
	
	if movement_input_vector != Vector2(0.0, 0.0):
		next_direction = movement_input_vector

		if next_direction.x == -1.0:
			next_direction_rotator.set_rotation(deg_to_rad(180.0))
		elif next_direction.x == 1.0:
			next_direction_rotator.set_rotation(deg_to_rad(0.0))
		elif next_direction.y == -1.0:
			next_direction_rotator.set_rotation(deg_to_rad(-90.0))
		elif next_direction.y == 1.0:
			next_direction_rotator.set_rotation(deg_to_rad(90.0))
	
	if velocity != Vector2(0.0, 0.0):
		animation_tree.set("parameters/move/blend_position", velocity)
		anim_node_sm_playback.travel("move")
	else:
		animation_tree.set("parameters/idle/blend_position", next_direction)
		anim_node_sm_playback.travel("idle")
	
	self.velocity = direction * speed
	self.move_and_slide()
