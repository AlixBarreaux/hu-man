extends Node2D
class_name Enemy


var speed: float = 0.0
@export var spawn_point: Marker2D = null
@onready var spawn_position: Vector2 = spawn_point.global_position

@export var initial_direction: Vector2 = Vector2(0.0, 1.0)
var direction: Vector2 = self.initial_direction
var velocity: Vector2 = self.direction

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_node_sm_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var colors_animation_player: AnimationPlayer = $ColorsAnimationPlayer

@export var enemy_ai: Node2D = null


func enable() -> void:
	set_physics_process(true)


func disable() -> void:
	set_physics_process(false)


func on_game_ready() -> void:
	animation_tree.set("parameters/move/blend_position", Vector2(0.0, 0.0))
	animation_tree.set("parameters/idle/blend_position", self.direction)


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
	
	animation_tree.set("parameters/idle/blend_position", direction)
	anim_node_sm_playback.travel("idle")


func on_player_finished_dying() -> void:
	if Global.is_game_over: return
	self.set_global_position(spawn_position)
	self.direction = initial_direction
	animation_tree.set("parameters/move/blend_position", self.direction)


func _initialize_signals() -> void:
	Global.game_ready.connect(on_game_ready)
	Global.game_started.connect(on_game_started)
	Global.level_cleared.connect(on_level_cleared)
	Global.player_died.connect(on_player_died)
	Global.player_finished_dying.connect(on_player_finished_dying)


@onready var shared_enemy_ai: SharedEnemyAI = get_tree().get_root().get_node("Level/SharedEnemyAI")
@onready var enemies_timers: EnemiesTimers = shared_enemy_ai.get_node("EnemiesTimers")


func on_enemies_timers_frightened_timer_timeout() -> void:
	colors_animation_player.play("normal")
	set_process(true)


func _process(_delta: float) -> void:
	if enemies_timers.frightened_timer.get_time_left() > 0:
		if enemies_timers.frightened_timer.get_time_left() <= 2.0:
			set_process(false)
			colors_animation_player.play("frightened_ending")


func _ready() -> void:
	assert(spawn_point != null)
	
	await enemies_timers.ready
	enemies_timers.frightened_timer.timeout.connect(on_enemies_timers_frightened_timer_timeout)
	
	self.disable()
	self._initialize_signals()
	self.direction = self.initial_direction
	animation_tree.active = true
	


var can_move: bool = true

func _physics_process(_delta: float) -> void:
	if can_move:
		velocity = direction * speed
		self.global_position += velocity
		
		if velocity != Vector2(0.0, 0.0):
			animation_tree.set("parameters/move/blend_position", direction)
			anim_node_sm_playback.travel("move")
		else:
			animation_tree.set("parameters/idle/blend_position", direction)
			anim_node_sm_playback.travel("idle")
