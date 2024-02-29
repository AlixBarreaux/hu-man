extends EnemyAI
class_name EnemyAIBourrin


func __update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position
