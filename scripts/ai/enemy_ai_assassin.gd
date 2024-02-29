extends EnemyAI
class_name EnemyAICornichon


func __update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position + (chase_target.direction * tile_size * 4)
