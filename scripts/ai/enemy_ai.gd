extends Node2D
class_name EnemyAI


func on_chasing() -> void:
	print("Chase!")


func on_scattered() -> void:
	print("Scatter!")


func on_eaten() -> void:
	print("Eaten!")


func on_frightened() -> void:
	print("Frightened!")


enum States {
	CHASE,
	SCATTER,
	EATEN,
	FRIGHTENED
}

# SETGET?
var current_state: States = States.SCATTER
var state_to_resume: States = current_state

func set_state(state: States) -> void:
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

# Chase -> Scatter, Frightened
# Scatter -> Chase, Frightened
# Frightened -> Eaten, Chase, Scatter
# Eaten -> Chase, Scatter

# Repeat this cycle 4 Times per level:
# Scatter x sec, Chase x sec
# After this cycle is over, lock in chase mode
# Enemy Bourring can replace the Scatter x sec by chase, locking him in chase 
# mode when x dots are left in the maze

@onready var chase_target: Player = get_tree().get_root().get_node("World/Actors/Players/Player")
var chase_target_position: Vector2 = Vector2(0.0, 0.0)


func _set_chase_target_position() -> void:
	chase_target_position = chase_target.global_position + (chase_target.direction * tile_size) * 4


var scatter_target
var frigthened_target

@onready var enemies_home: Marker2D = get_tree().get_root().get_node("World/AIWaypoints/EnemiesHome")
@onready var enemies_home_position: Vector2 = enemies_home.global_position


@export var enemy: Enemy = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var tile_map: TileMap = get_tree().get_root().get_node("World/TileMap")

@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x

# OVERRIDE THIS
var destination_position: Vector2 = Vector2(0.0, 0.0)


func set_destination_position(value: Vector2) -> void:
	destination_position = value
	nav_agent.set_target_position(destination_position)

var destination_location: DestinationLocations = DestinationLocations.SCATTER_AREA

enum DestinationLocations {
	CHASE_TARGET,
	SCATTER_AREA,
	ENEMIES_HOME,
	RANDOM_LOCATION
}



func set_destination_location(new_destination: DestinationLocations) -> void:
	destination_location = new_destination
	
	match destination_location:
		DestinationLocations.CHASE_TARGET:
			_set_chase_target_position()
			set_destination_position(chase_target.global_position)
		DestinationLocations.SCATTER_AREA:
			#set_destination_location()
			pass
		DestinationLocations.ENEMIES_HOME:
			set_destination_position(enemies_home_position)
		DestinationLocations.RANDOM_LOCATION:
			pass
		_:
			printerr("(!) ERROR in " + self.name + ": Unrecognized state!")


@onready var power_pellets: Node = get_tree().get_root().get_node("World/Pickables/Pellets/Power")

func on_power_pellet_picked_up(_value: int) -> void:
	self.set_state(States.FRIGHTENED)


@onready var enemies_timers: Node = get_tree().get_root().get_node("World/EnemiesTimers")
@onready var scatter_timer: Timer = enemies_timers.get_node("ScatterTimer")
@onready var chase_timer: Timer = enemies_timers.get_node("ChaseTimer")
@onready var frightened_timer: Timer = enemies_timers.get_node("FrightenedTimer")


func on_scatter_timer_timeout() -> void:
	set_state(States.CHASE)


func on_chase_timer_timeout() -> void:
	set_state(States.SCATTER)


func on_frightened_timer_timeout() -> void:
	#set_state(state_to_resume)
	pass


func disable() -> void:
	self.set_physics_process(false)


func enable() -> void:
	self.set_physics_process(true)


func on_game_started() -> void:
	print(self.name, ": Game started - WARNING - Should check if scatter mode is chosen!")
	self.enable()


func on_player_died() -> void:
	print(self.name, ": Player died!")
	self.disable()


func _ready() -> void:
	set_physics_process(false)
	call_deferred("_initialize")
	
	scatter_timer.timeout.connect(on_scatter_timer_timeout)
	chase_timer.timeout.connect(on_chase_timer_timeout)
	frightened_timer.timeout.connect(on_frightened_timer_timeout)
	
	for power_pellet in power_pellets.get_children():
		power_pellet.picked_up.connect(on_power_pellet_picked_up)
		
	Global.game_started.connect(on_game_started)
	Global.player_died.connect(on_player_died)


func _initialize():
	set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the nav map is no longer empty, can set the movement target
	
	scatter_timer.start()
	set_state(States.CHASE)


func _physics_process(_delta: float) -> void:
	# SIGNAL INSTEAD? -> navigation_finished
	if nav_agent.is_navigation_finished():
		#print("Navigation finished.")
		return
	
	enemy.direction = to_local(nav_agent.get_next_path_position()).normalized()
