extends Timer
class_name EnableAITimer


@export var enemy_ai: EnemyAI = null


func on_game_started() -> void:
	self.start()


func on_player_died() -> void:
	self.stop()


func _ready() -> void:
	assert(enemy_ai != null)
	Global.game_started.connect(on_game_started)
	Global.player_died.connect(on_player_died)


func _on_timeout() -> void:
	enemy_ai.enable()
