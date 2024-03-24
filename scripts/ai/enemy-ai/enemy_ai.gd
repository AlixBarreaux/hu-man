extends Node2D
class_name EnemyAI


@export_group("Speeds")
@export var base_speed: float = 2.35
var chase_speed: float = base_speed
@export var scatter_speed: float = base_speed
@export var eaten_speed: float = base_speed * 2
@export var frightened_speed: float = base_speed / 1.5


@export_group("Sound Files")
@export_file("*.ogg", "*.wav") var frightened_sound_file_path: String = ""
@export_file("*.ogg", "*.wav") var eaten_sound_file_path: String = ""
@export_file("*.ogg", "*.wav") var enemy_going_home_sound_file_path: String = ""
@export_group("")


var in_home: bool = true


func on_chasing() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.CHASE_TARGET)
	enemy.speed = chase_speed
	AudioManager.stop_track(AudioManager.TrackTypes.ENEMIES)


func on_scattered() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.SCATTER_AREA)
	go_to_first_scatter_point()
	enemy.speed = scatter_speed
	AudioManager.stop_track(AudioManager.TrackTypes.ENEMIES)


func on_eaten() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.ENEMIES_HOME)
	enemy.speed = eaten_speed
	AudioManager.play_sound_file(eaten_sound_file_path, AudioManager.TrackTypes.ENEMIES)
	await AudioManager.enemies_player.finished
	AudioManager.play_sound_file(enemy_going_home_sound_file_path, AudioManager.TrackTypes.ENEMIES)


func on_frightened() -> void:
	enemy.set_hurt_box_disabled(false)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.RANDOM_LOCATION)
	frightened_timer.start()
	enemy.speed = frightened_speed
	AudioManager.play_sound_file(frightened_sound_file_path, AudioManager.TrackTypes.ENEMIES)


enum States {
	CHASE,
	SCATTER,
	EATEN,
	FRIGHTENED
}


var current_state: States = States.SCATTER
var previous_state: States = current_state


signal state_set(value: EnemyAI.States)

func set_state(state: States) -> void:
	if state == current_state and not first_initialization: return
	previous_state = current_state
	current_state = state
	
	match state:
		States.CHASE:
			self.on_chasing()
		States.SCATTER:
			self.on_scattered()
		States.EATEN:
			self.on_eaten()
		States.FRIGHTENED:
			self.on_frightened()
		_:
			printerr("(!) Error in " + self.name + ": Unrecognized state!")

	self.state_set.emit(state)

# State waiting to be set which updates itself in the background while
# the current one is overrinding it
var background_state: States = self.current_state


@onready var chase_target: Player = get_tree().get_root().get_node("Level/Actors/Players/Player")
@onready var chase_target_position: Vector2 = Vector2(0.0, 0.0)

func __update_chase_target_position() -> void:
	printerr("(!) ERROR in: " + self.name + ": __set_chase_target_position() must be implemented!")


func set_destination_position_to_chase_target_position() -> void:
	__update_chase_target_position()
	set_destination_position(chase_target_position)


@export var scatter_points_node_name: String = ""
@onready var scatter_points_node = get_tree().get_root().get_node("Level/AIWaypoints/" + scatter_points_node_name)
@onready var scatter_point_target_position: Vector2 = Vector2(0.0, 0.0)

@onready var scatter_points: PackedVector2Array = []
var current_scatter_point_index: int = 0

func build_scatter_points_list() -> void:
	for node in scatter_points_node.get_children():
		scatter_points.append(node.global_position)


func go_to_first_scatter_point() -> void:
	current_scatter_point_index = 0
	set_destination_position(scatter_points[current_scatter_point_index])


func go_to_next_scatter_point() -> void:
	set_destination_position(scatter_points[current_scatter_point_index])

	current_scatter_point_index += 1
	if current_scatter_point_index >= scatter_points.size():
		current_scatter_point_index = 0


@onready var enemies: Node = get_tree().get_root().get_node("Level/Actors/Enemies")
@onready var shared_enemy_ai: SharedEnemyAI = get_tree().get_root().get_node("Level/SharedEnemyAI")

func pick_random_destination_position() -> void:
	randomize()
	var random_index: int = randi() % shared_enemy_ai.walkable_tiles_list.size() - 1
	set_destination_position(tile_map.map_to_local(shared_enemy_ai.walkable_tiles_list[random_index]))


@onready var enemies_home: Marker2D = get_tree().get_root().get_node("Level/AIWaypoints/EnemiesHome")
@onready var enemies_home_position: Vector2 = enemies_home.global_position

@export var enemy: Enemy = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var tile_map: TileMap = get_tree().get_root().get_node("Level/TileMap")
@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x

var destination_position: Vector2 = Vector2(0.0, 0.0)

func set_destination_position(value: Vector2) -> void:
	destination_position = value
	nav_agent.set_target_position(destination_position)


enum DestinationLocations {
	CHASE_TARGET,
	SCATTER_AREA,
	ENEMIES_HOME,
	RANDOM_LOCATION
}


# Controls if the destination location is updated on each frame.
# Set to false when the position is set once and not changing later.
var can_update_destination_location: bool = true


var destination_location: DestinationLocations = DestinationLocations.SCATTER_AREA

func set_destination_location(new_destination: DestinationLocations) -> void:
	destination_location = new_destination
	can_update_destination_location = true


func update_destination_location() -> void:
	match destination_location:
		DestinationLocations.CHASE_TARGET:
			set_destination_position_to_chase_target_position()
		DestinationLocations.SCATTER_AREA:
			can_update_destination_location = false
			go_to_next_scatter_point()
		DestinationLocations.ENEMIES_HOME:
			can_update_destination_location = false
			set_destination_position(enemies_home_position)
		DestinationLocations.RANDOM_LOCATION:
			can_update_destination_location = false
			pick_random_destination_position()
		_:
			printerr("(!) ERROR in " + self.name + ": Unrecognized state!")


signal navigation_finished

func on_navigation_finished() -> void:
	match current_state:
		States.EATEN:
			can_update_destination_location = true
			self.set_state(background_state)
		States.FRIGHTENED:
			can_update_destination_location = true
			pick_random_destination_position()
		States.SCATTER:
			can_update_destination_location = false
			go_to_next_scatter_point()
		# Useful for EnemyAICornichon only. AI just stops on player death anyways.
		States.CHASE:
			#can_update_destination_location = true
			set_destination_location(DestinationLocations.CHASE_TARGET)


@onready var pellets: Pellets = get_tree().get_root().get_node("Level/Pickables/Pellets")

func on_power_pellet_picked_up(_value: int) -> void:
	if self.in_home: return
	self.set_state(States.FRIGHTENED)


@onready var shared_ai: SharedEnemyAI = get_tree().get_root().get_node("Level/SharedEnemyAI")
@onready var enemies_timers: EnemiesTimer = shared_ai.get_node("EnemiesTimers")
@onready var scatter_timer: Timer = enemies_timers.get_node("ScatterDurationTimer")
@onready var chase_timer: Timer = enemies_timers.get_node("ChaseDurationTimer")
@onready var frightened_timer: Timer = enemies_timers.get_node("FrightenedDurationTimer")


var cycle_completed_before_permanent_chase_mode: bool = false
var cycle_count_before_permanent_chase_mode: int = 0
var cycle_count_limit_before_permanent_chase_mode: int = 4

func check_if_cycle_completed_before_permanent_chase() -> void:
	if cycle_count_before_permanent_chase_mode >= cycle_count_limit_before_permanent_chase_mode:
		cycle_completed_before_permanent_chase_mode = true


func on_scatter_timer_timeout() -> void:
	background_state = States.CHASE
	if current_state == States.EATEN or current_state == States.FRIGHTENED: return
	
	if not cycle_completed_before_permanent_chase_mode:
		cycle_count_before_permanent_chase_mode += 1
		check_if_cycle_completed_before_permanent_chase()
	
	self.set_state(States.CHASE)


func on_chase_timer_timeout() -> void:
	background_state = States.SCATTER
	if current_state == States.EATEN or current_state == States.FRIGHTENED: return
	
	if not cycle_completed_before_permanent_chase_mode:
		cycle_count_before_permanent_chase_mode += 1
		check_if_cycle_completed_before_permanent_chase()
	else:
		return
		
	self.set_state(States.SCATTER)


func on_frightened_timer_timeout() -> void:
	if current_state == States.EATEN: return
	self.set_state(background_state)


@onready var pathfinding_update_timer: Timer = $PathfindingUpdateTimer

func disable() -> void:
	self.set_physics_process(false)
	pathfinding_update_timer.stop()
	enemy.can_move = false


func enable() -> void:
	self.set_physics_process(true)
	pathfinding_update_timer.start()
	enemy.can_move = true
	self.in_home = false


func on_enemy_died() -> void:
	#frightened_timer.stop()
	self.set_state(States.EATEN)


@onready var enable_ai_timer: EnableAITimer = get_node_or_null("EnableAITimer")

func on_game_started() -> void:
	if not enable_ai_timer:
		self.enable()


func on_player_died() -> void:
	self.disable()
	cycle_count_before_permanent_chase_mode = 0
	cycle_completed_before_permanent_chase_mode = false


func on_game_over() -> void:
	self.disable()
	cycle_count_before_permanent_chase_mode = 0
	cycle_completed_before_permanent_chase_mode = false


func on_level_cleared() -> void:
	self.disable()


func _initialize_signals() -> void:
	self.navigation_finished.connect(on_navigation_finished)
	
	scatter_timer.timeout.connect(on_scatter_timer_timeout)
	chase_timer.timeout.connect(on_chase_timer_timeout)
	frightened_timer.timeout.connect(on_frightened_timer_timeout)

	pellets.power_pellet_picked_up.connect(on_power_pellet_picked_up)
	enemy.died.connect(on_enemy_died)
	
	Global.game_started.connect(on_game_started)
	Global.player_died.connect(on_player_died)
	Global.game_over.connect(on_game_over)
	Global.level_cleared.connect(on_level_cleared)


var first_initialization: bool = true

signal initialized
var is_initialized: bool = false

func _initialize():
	build_scatter_points_list()
	is_initialized = true
	self.initialized.emit()


func _ready() -> void:
	assert(enemy != null)
	self.disable()
	assert(FileAccess.file_exists(frightened_sound_file_path))
	assert(FileAccess.file_exists(eaten_sound_file_path))
	assert(FileAccess.file_exists(enemy_going_home_sound_file_path))
	self._initialize_signals()
	call_deferred("_initialize")


func _physics_process(_delta: float) -> void:
	enemy.direction = to_local(nav_agent.get_next_path_position()).normalized()


func _on_pathfinding_update_timer_timeout() -> void:
	if can_update_destination_location: update_destination_location()
	
	if nav_agent.is_navigation_finished():
		navigation_finished.emit()
		return
