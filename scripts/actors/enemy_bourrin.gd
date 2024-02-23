extends Enemy
class_name EnemyBourrin


func _set_destination_position() -> void:
	destination_position = player.global_position
