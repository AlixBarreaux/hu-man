extends EnemyAI
class_name EnemyAICornichon


# Chase until 8 tiles distance of player, scatter if inside of this zone

func __update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position
