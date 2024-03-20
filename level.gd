extends Node2D
class_name Level


## Defines which level it is.
@export var id: int = 0
@export_file var next_level_to_load_file_path: String = ""

@onready var switch_to_next_level_timer: Timer = $SwitchToNextLevelTimer


func on_player_finished_dying() -> void:
	if Global.is_game_over: return
	Global.game_ready.emit()


func on_level_cleared() -> void:
	switch_to_next_level_timer.start()


func on_game_over() -> void:
	switch_to_next_level_timer.start()


func _ready() -> void:
	assert(self.id > 0)
	
	Global.player_finished_dying.connect(on_player_finished_dying)
	Global.game_ready.emit()
	Global.level_cleared.connect(on_level_cleared)
	Global.game_over.connect(on_game_over)


func _on_switch_to_next_level_timer_timeout() -> void:
	get_tree().change_scene_to_file(next_level_to_load_file_path)
