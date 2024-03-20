extends Node2D
class_name Level


## Defines which level it is.
@export var id: int = 0
@export_file var next_level_to_load_file_path: String = ""


func on_player_finished_dying() -> void:
	if Global.is_game_over: return
	Global.game_ready.emit()


func _ready() -> void:
	assert(self.id > 0)
	
	Global.player_finished_dying.connect(on_player_finished_dying)
	Global.game_ready.emit()
