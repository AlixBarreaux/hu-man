extends Node
class_name SharedEnemyAI


@onready var tile_map: TileMap = get_tree().get_root().get_node("Level/TileMap")
#@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x


var walkable_tiles_list: PackedVector2Array = []

func build_walkable_tiles_list() -> void:
	for tile in tile_map.get_used_cells(0):
		var cell_tile_data: TileData = tile_map.get_cell_tile_data(0, tile)
		if cell_tile_data and cell_tile_data.get_custom_data("walkable"):
			walkable_tiles_list.append(tile)



@onready var enemies_timers: EnemiesTimer = $EnemiesTimers
@onready var scatter_timer: Timer = enemies_timers.get_node("ScatterDurationTimer")
@onready var chase_timer: Timer = enemies_timers.get_node("ChaseDurationTimer")
#@onready var frightened_timer: Timer = enemies_timers.get_node("FrightenedDurationTimer")

@onready var enemies: Node = get_tree().get_root().get_node("Level/Actors/Enemies")
var enemy_ai_list: Array[EnemyAI] = []


var frightened_enemy_ais_count: int = 0
var enemies_eaten_combo_count: int = 0

var enemy_base_score_value: int = 200
var enemy_score_value: int = enemy_base_score_value

func on_enemy_state_set(state: EnemyAI.States) -> void:
	match state:
		EnemyAI.States.EATEN:
			frightened_enemy_ais_count -= 1
			enemies_eaten_combo_count += 1
			print(self.name, ": Eaten! Count--")
			if frightened_enemy_ais_count >= 0:
				if enemies_eaten_combo_count > 1:
					enemy_score_value *= 2
					print("Score value x2!")
				else:
					print("Score value x1.")
				print("Score to add: ", enemy_score_value)
				Global.increase_score(enemy_score_value)
		EnemyAI.States.FRIGHTENED:
			frightened_enemy_ais_count += 1
			print(self.name, ": Frightened! Count++")


func on_enemies_timers_frightened_timer_timeout() -> void:
	frightened_enemy_ais_count = 0
	enemies_eaten_combo_count = 0
	enemy_score_value = enemy_base_score_value
	print("Frightened timer timeout, reset score to base value: ", enemy_base_score_value)


func on_game_started() -> void:
	var timer_started: bool = false
	
	for enemy: Enemy in enemies.get_children():
		var enemy_ai: EnemyAI = enemy.enemy_ai
		
		# AI must absolutely be initialized before proceeding
		if not enemy_ai.is_initialized:
			await enemy_ai.initialized
		
		enemy_ai.state_set.connect(on_enemy_state_set)
		
		enemy_ai.set_state(enemy_ai.initial_state)
	
		match enemy_ai.initial_state:
			enemy_ai.States.CHASE:
				enemy_ai.background_state = enemy_ai.States.CHASE
				if not timer_started:
					timer_started = true
					chase_timer.start()
			enemy_ai.States.SCATTER:
				enemy_ai.background_state = enemy_ai.States.SCATTER
				if not timer_started:
					timer_started = true
					enemy_ai.scatter_timer.start()
			_:
				printerr(("(!) ERROR: In: " + self.get_name() + ": Uhandled state on game started!"))
				
		enemy_ai.first_initialization = false


func _ready() -> void:
	Global.game_ready.connect(on_game_started)
	enemies_timers.frightened_timer.timeout.connect(on_enemies_timers_frightened_timer_timeout)
	
	for enemy: Enemy in enemies.get_children():
		enemy_ai_list.append(enemy.enemy_ai)
	
	for enemy in enemy_ai_list:
		self.build_walkable_tiles_list()
	
