extends Node2D
class_name Level


func on_player_finished_dying() -> void:
	if Global.is_game_over: return
	Global.game_ready.emit()


func _ready() -> void:
	Global.player_finished_dying.connect(on_player_finished_dying)
	Global.game_ready.emit()
