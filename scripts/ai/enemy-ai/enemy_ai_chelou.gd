extends EnemyAI
class_name EnemyAIChelou


@onready var enemy_to_target: Enemy = get_tree().get_root().get_node("Level/Actors/Enemies/EnemyBourrin")


func __update_chase_target_position() -> void:
	var cell_away_point_position: Vector2 = chase_target.global_position + (chase_target.direction * tile_size * 2)
	var chase_target_to_enemy_vector: Vector2 = enemy_to_target.global_position - cell_away_point_position
	chase_target_position = cell_away_point_position - chase_target_to_enemy_vector
