extends EnemyAI
class_name EnemyAICornichon


func __update_chase_target_position() -> void:
	if enemy.global_position.distance_to(chase_target_position) <= tile_size * 8:
		set_destination_location(DestinationLocations.RANDOM_LOCATION)
	else:
		chase_target_position = chase_target.global_position
