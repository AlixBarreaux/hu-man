extends Node2D
class_name EnemyAI


# REFACTOR NOTES: Use SETGET on every setter function?


# TODO:
# - Implement ghost "dying" -> Swicth from frigthened to eaten
# - Implement scatter behavior: Moving around the first point for now, should 
# go to the next one
# - Make player die
# - To avoid calling 4 times the timers on _initialize, do it in enemies_timers
# and rename this scene to something like EnemiesSharedAI ?
# (Careful with signals and refs!)
# END TODO

# TO REMOVE WHEN DONE:

# Chase -> Scatter, Frightened
# Scatter -> Chase, Frightened
# Frightened -> Eaten, Chase, Scatter
# Eaten -> Chase, Scatter

# Repeat this cycle 4 Times per level:
# Scatter x sec, Chase x sec
# After this cycle is over, lock in chase mode
# Enemy Bourring can replace the Scatter x sec by chase, locking him in chase 
# mode when x dots are left in the maze


func on_chasing() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.CHASE_TARGET)


func on_scattered() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.SCATTER_AREA)


func on_eaten() -> void:
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.ENEMIES_HOME)


func on_frightened() -> void:
	enemy.set_hurt_box_disabled(false)
	enemy.set_hit_box_disabled(true)
	set_destination_location(DestinationLocations.RANDOM_LOCATION)
	frightened_timer.start()


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
var chase_target_position: Vector2 = Vector2(0.0, 0.0)

func _update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position
	set_destination_position(chase_target_position)


@onready var scatter_point: Marker2D = get_tree().get_root().get_node("World/AIWaypoints/ScatterPoints1/Marker2D")
@onready var scatter_point_position: Vector2 = scatter_point.global_position

func update_scatter_area_point_position() -> void:
	scatter_point_position = scatter_point.global_position
	set_destination_position(scatter_point_position)


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
			#print("Update chase!")
			_update_chase_target_position()
		DestinationLocations.SCATTER_AREA:
			#print("Update scatter!")
			update_scatter_area_point_position()
		DestinationLocations.ENEMIES_HOME:
			can_update_destination_location = false
			
			#print("Update enemies home!")
			set_destination_position(enemies_home_position)
		DestinationLocations.RANDOM_LOCATION:
			can_update_destination_location = false
			
			#print("Update random location!")
			pick_random_destination_position()
		_:
			printerr("(!) ERROR in " + self.name + ": Unrecognized state!")


signal navigation_finished

func on_navigation_finished() -> void:
	if current_state == States.EATEN:
		can_update_destination_location = true
		self.set_state(background_state)
	elif current_state == States.FRIGHTENED:
		can_update_destination_location = true
		pick_random_destination_position()


@onready var power_pellets: Node = get_tree().get_root().get_node("World/Pickables/Pellets/Power")

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
	self.set_state(background_state)


func disable() -> void:
	self.set_physics_process(false)


func enable() -> void:
	self.set_physics_process(true)


func on_enemy_died() -> void:
	frightened_timer.stop()
	self.set_state(States.EATEN)


func on_game_started() -> void:
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
	
	for power_pellet in power_pellets.get_children():
		power_pellet.picked_up.connect(on_power_pellet_picked_up)
	
	enemy.died.connect(on_enemy_died)
	
	Global.game_started.connect(on_game_started)
	Global.level_cleared.connect(on_level_cleared)
	Global.player_died.connect(on_player_died)


func _ready() -> void:
	set_physics_process(false)
	self._initialize_signals()
	call_deferred("_initialize")


var first_initialization: bool = true

func _initialize():
	set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the nav map is no longer empty, can use pathfinding
	
	build_walkable_tiles_list()
	
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


func _physics_process(_delta: float) -> void:
	if can_update_destination_location: update_destination_location()
	
	if nav_agent.is_navigation_finished():
		navigation_finished.emit()
		return
	
	enemy.direction = to_local(nav_agent.get_next_path_position()).normalized()
