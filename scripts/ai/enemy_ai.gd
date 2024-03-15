extends Node2D
class_name EnemyAI


# REFACTOR NOTES: Use SETGET on every setter function?

# TODO:
# - To avoid calling 4 times the timers on _initialize, do it in enemies_timers
# and rename this scene to something like EnemiesSharedAI ?
# (Careful with function / var names, signals and refs!)
# - Pathfinding optimization: build and store the walkable tiles on a shared AI thingy

# END TODO

# TO REMOVE WHEN DONE:

# Repeat this cycle 4 Times per level:
# Scatter x sec, Chase x sec
# After this cycle is over, lock in chase mode

@export var initial_chase_speed: float = 1.0
var chase_speed: float = initial_chase_speed
@export var scatter_speed: float = 1.0
@export var eaten_speed: float = 2.0
@export var frightened_speed: float = 1.0

func on_chasing() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.CHASE_TARGET)
	enemy.speed = chase_speed


func on_scattered() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.SCATTER_AREA)
	go_to_first_scatter_point()
	enemy.speed = scatter_speed


func on_eaten() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.ENEMIES_HOME)
	enemy.speed = eaten_speed


func on_frightened() -> void:
	enemy.set_hurt_box_disabled(false)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.RANDOM_LOCATION)
	frightened_timer.start()
	enemy.speed = frightened_speed


enum States {
	CHASE,
	SCATTER,
	EATEN,
	FRIGHTENED
}


var current_state: States = States.SCATTER
@export var initial_state: States = States.SCATTER


func set_state(state: States) -> void:
	if state == current_state and not first_initialization: return
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


# State waiting to be set which updates itself in the background while
# the current one is overrinding it
var background_state: States = self.current_state


@onready var chase_target: Player = get_tree().get_root().get_node("World/Actors/Players/Player")
@onready var chase_target_position: Vector2 = Vector2(0.0, 0.0)

func __update_chase_target_position() -> void:
	printerr("(!) ERROR in: " + self.name + ": __set_chase_target_position() must be implemented!")


func set_destination_position_to_chase_target_position() -> void:
	__update_chase_target_position()
	set_destination_position(chase_target_position)


@export var scatter_points_node_path_string: String = ""
@onready var scatter_points_node: Node2D = get_tree().get_root().get_node(scatter_points_node_path_string)
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


var walkable_tiles_list: PackedVector2Array = []

func build_walkable_tiles_list() -> void:
	for tile in tile_map.get_used_cells(0):
		var cell_tile_data: TileData = tile_map.get_cell_tile_data(0, tile)
		if cell_tile_data and cell_tile_data.get_custom_data("walkable"):
			walkable_tiles_list.append(tile)


func pick_random_destination_position() -> void:
	randomize()
	var random_index: int = randi() % walkable_tiles_list.size() - 1
	set_destination_position(tile_map.map_to_local(walkable_tiles_list[random_index]))


@onready var enemies_home: Marker2D = get_tree().get_root().get_node("World/AIWaypoints/EnemiesHome")
@onready var enemies_home_position: Vector2 = enemies_home.global_position

@export var enemy: Enemy = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var tile_map: TileMap = get_tree().get_root().get_node("World/TileMap")
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


@onready var pellets: Pellets = get_tree().get_root().get_node("World/Pickables/Pellets")

func on_power_pellet_picked_up(_value: int) -> void:
	self.set_state(States.FRIGHTENED)


@onready var enemies_timers: Node = get_tree().get_root().get_node("World/EnemiesTimers")
@onready var scatter_timer: Timer = enemies_timers.get_node("ScatterDurationTimer")
@onready var chase_timer: Timer = enemies_timers.get_node("ChaseDurationTimer")
@onready var frightened_timer: Timer = enemies_timers.get_node("FrightenedDurationTimer")


func on_scatter_timer_timeout() -> void:
	background_state = States.CHASE
	if current_state == States.EATEN or current_state == States.FRIGHTENED: return
	self.set_state(States.CHASE)


func on_chase_timer_timeout() -> void:
	background_state = States.SCATTER
	if current_state == States.EATEN or current_state == States.FRIGHTENED: return
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


func on_enemy_died() -> void:
	#frightened_timer.stop()
	self.set_state(States.EATEN)


@onready var enable_ai_timer: EnableAITimer = get_node_or_null("EnableAITimer")

func on_game_started() -> void:
	if not enable_ai_timer:
		self.enable()


func on_player_died() -> void:
	self.disable()


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
	Global.level_cleared.connect(on_level_cleared)
	Global.player_died.connect(on_player_died)


var first_initialization: bool = true

func _initialize():
	#set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	#await get_tree().physics_frame
	# Now that the nav map is no longer empty, can use pathfinding
	
	build_walkable_tiles_list()
	build_scatter_points_list()
	
	self.set_state(initial_state)
	
	# WARNING: TIMER CALLED BY EACH ENEMY! TIMER SHOULD BE CALLED ONCE ONLY!
	match initial_state:
		States.CHASE:
			background_state = States.CHASE
			chase_timer.start()
		_:
			background_state = States.SCATTER
			scatter_timer.start()
	
	first_initialization = false


func _ready() -> void:
	self.disable()
	self._initialize_signals()
	call_deferred("_initialize")


func _physics_process(_delta: float) -> void:
	enemy.direction = to_local(nav_agent.get_next_path_position()).normalized()


func _on_pathfinding_update_timer_timeout() -> void:
	if can_update_destination_location: update_destination_location()
	
	if nav_agent.is_navigation_finished():
		navigation_finished.emit()
		return
