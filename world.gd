extends Node2D
class_name World


func on_player_finished_dying() -> void:
	Global.game_ready.emit()


func _ready() -> void:
	Global.player_finished_dying.connect(on_player_finished_dying)
	Global.game_ready.emit()
