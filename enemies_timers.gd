extends Node


@onready var power_pellets = get_tree().get_root().get_node("World/Pickables/Pellets/Power")

@onready var scatter_timer: Timer = $ScatterDurationTimer
@onready var chase_timer: Timer = $ChaseDurationTimer
@onready var frightened_timer: Timer = $FrightenedDurationTimer


func stop_all_timers() -> void:
	for timer in self.get_children():
		timer.stop()


func on_power_pellet_picked_up(_value: int) -> void:
	self.frightened_timer.start()


func on_player_died() -> void:
	print(self.name, ": Player died! Timers all stopped!")
	self.stop_all_timers()


func _ready() -> void:
	for power_pellet in power_pellets.get_children():
		power_pellet.picked_up.connect(on_power_pellet_picked_up)
	
	Global.player_died.connect(on_player_died)


func _on_scatter_timer_timeout() -> void:
	print(self.name, ": Scatter timer timeout!")
	chase_timer.start()


func _on_chase_timer_timeout() -> void:
	print(self.name, ": Chase timer timeout!")
	scatter_timer.start()
