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

@export var enemy_ai: EnemyAI = null


@export var base_speed: float = 2.35
var chase_speed: float = base_speed
var scatter_speed: float = base_speed
var eaten_speed: float = base_speed * 2
var frightened_speed: float = base_speed / 1.5


@export_group("Sound Files")
@export_file("*.ogg", "*.wav") var frightened_sound_file_path: String = ""
@export_file("*.ogg", "*.wav") var eaten_sound_file_path: String = ""
@export_file("*.ogg", "*.wav") var enemy_going_home_sound_file_path: String = ""
@export_group("")


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


func _process(_delta: float) -> void:
	if enemies_timers.frightened_timer.get_time_left() > 0:
		if enemies_timers.frightened_timer.get_time_left() <= 2.0:
			set_process(false)
			colors_animation_player.play("frightened_ending")


var going_home: bool = false


func on_chasing() -> void:
	set_hurt_box_disabled(true)
	set_hit_box_disabled(false)
	speed = chase_speed
	going_home = false
	colors_animation_player.play("normal")
	AudioManager.stop_track(AudioManager.TrackTypes.ENEMIES)


func on_scattered() -> void:
	set_hurt_box_disabled(true)
	set_hit_box_disabled(false)
	speed = scatter_speed
	going_home = false
	colors_animation_player.play("normal")
	AudioManager.stop_track(AudioManager.TrackTypes.ENEMIES)


func on_eaten() -> void:
	set_hurt_box_disabled(true)
	set_hit_box_disabled(true)
	speed = eaten_speed
	going_home = true
	AudioManager.play_sound_file(eaten_sound_file_path, AudioManager.TrackTypes.ENEMIES)
	await AudioManager.enemies_player.finished
	AudioManager.play_sound_file(enemy_going_home_sound_file_path, AudioManager.TrackTypes.ENEMIES)


func on_frightened() -> void:
	set_hurt_box_disabled(false)
	set_hit_box_disabled(true)
	speed = frightened_speed
	going_home = false
	set_process(true)
	colors_animation_player.play("frightened")
	AudioManager.play_sound_file(frightened_sound_file_path, AudioManager.TrackTypes.ENEMIES)


func on_enemy_ai_state_set(state: EnemyAI.States) -> void:
	match state:
		EnemyAI.States.CHASE:
			on_chasing()
		EnemyAI.States.SCATTER:
			on_scattered()
		EnemyAI.States.EATEN:
			on_eaten()
		EnemyAI.States.FRIGHTENED:
			on_frightened()
		_:
			printerr("(!) ERROR: In: " + self.get_name() + ": Unhandled enemy ai state!")


func _ready() -> void:
	set_process(false)
	assert(spawn_point != null)
	
	assert(FileAccess.file_exists(frightened_sound_file_path))
	assert(FileAccess.file_exists(eaten_sound_file_path))
	assert(FileAccess.file_exists(enemy_going_home_sound_file_path))
	
	enemy_ai.state_set.connect(on_enemy_ai_state_set)
	
	#await enemies_timers.ready
	#enemies_timers.frightened_timer.timeout.connect(on_enemies_timers_frightened_timer_timeout)
	
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
			if going_home:
				anim_node_sm_playback.travel("going_home")
				colors_animation_player.play("going_home")
			else:
				animation_tree.set("parameters/move/blend_position", direction)
				anim_node_sm_playback.travel("move")
		else:
			animation_tree.set("parameters/idle/blend_position", direction)
			anim_node_sm_playback.travel("idle")
