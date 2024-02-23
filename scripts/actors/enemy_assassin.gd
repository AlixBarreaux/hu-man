extends Enemy
class_name EnemyCornichon


func _set_destination_position() -> void:
	destination_position = player.global_position + (player.direction * tile_size) * 4
