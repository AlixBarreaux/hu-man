extends Node
class_name EnemiesTimer


@onready var pellets: Pellets = get_tree().get_root().get_node("World/Pickables/Pellets")

@onready var scatter_timer: Timer = $ScatterDurationTimer
@onready var chase_timer: Timer = $ChaseDurationTimer
@onready var frightened_timer: Timer = $FrightenedDurationTimer


func stop_all_timers() -> void:
	for timer in self.get_children():
		timer.stop()


func on_power_pellet_picked_up(_value: int) -> void:
	self.frightened_timer.start()


func on_player_died() -> void:
	self.stop_all_timers()


func on_game_over() -> void:
	self.stop_all_timers()


func _ready() -> void:
	pellets.power_pellet_picked_up.connect(on_power_pellet_picked_up)
	
	Global.player_died.connect(on_player_died)
	Global.game_over.connect(on_game_over)


func _on_scatter_duration_timer_timeout() -> void:
	chase_timer.start()


func _on_chase_duration_timer_timeout() -> void:
	scatter_timer.start()
