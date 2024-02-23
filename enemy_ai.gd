extends Node2D
class_name EnemyAI


enum States {
	CHASE,
	SCATTER,
	EATEN,
	FRIGHTENED
}

func on_chasing() -> void:
	print("Chase!")


func on_scattered() -> void:
	print("Scatter!")


func on_eaten() -> void:
	print("Eaten!")

func on_frightened() -> void:
	print("Frightened!")

var current_state: States = States.SCATTER

func set_state(state: States) -> void:
	match state:
		States.CHASE:
			pass
		States.SCATTER:
			pass
		States.EATEN:
			pass
		States.FRIGHTENED:
			pass
		_:
			printerr("(!) Error in " + self.name + ": Unrecognized state!")
	
	current_state = state

#Chase -> Scatter, Frightened
#Scatter -> Chase, Frightened
#Frightened -> Eaten, Chase Scatter
#Eaten -> Chase, Scatter

# Repeat this cycle 4 Times per level:
# Scatter x sec, Chase x sec
# After this cycle is over, lock in chase mode
# Blinky can replace the Scatter x sec by chase, locking him in chase mode when
# x dots are left in the maze


@export var enemy: Enemy = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Player = get_tree().get_root().get_node("World/Actors/Players/Player")
@onready var tile_map: TileMap = get_tree().get_root().get_node("World/TileMap")

@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x

# OVERRIDE THIS
var destination_position: Vector2 = Vector2(0.0, 0.0)

func _set_destination_position_on_player() -> void:
	#printerr(self.name  + ": _set_destination_position() must be implemented!")
	destination_position = player.global_position


func move_to_player() -> void:
	_set_destination_position_on_player()
	nav_agent.set_target_position(destination_position)


func _ready() -> void:
	set_physics_process(false)
	call_deferred("_initialize")


func _initialize():
	set_physics_process(true)
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target
	#move_to_player()


func _physics_process(delta: float) -> void:
	print(self.name, "Destination value to override: ", destination_position)
	move_to_player()
	
	# SIGNAL INSTEAD? -> navigation_finished
	if nav_agent.is_navigation_finished():
		#print("Navigation finished.")
		return
	
	enemy.direction = to_local(nav_agent.get_next_path_position()).normalized()
