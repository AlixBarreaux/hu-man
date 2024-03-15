extends EnemyAI
class_name EnemyAIBourrin


func __update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position


var elroy_mode_enabled: bool = false

# @override
func on_scattered() -> void:
	if self.elroy_mode_enabled:
		self.set_state(self.States.CHASE)
		return
	
	enemy.set_hurt_box_disabled(true)
	enemy.set_hit_box_disabled(false)
	set_destination_location(DestinationLocations.SCATTER_AREA)
	go_to_first_scatter_point()
	enemy.speed = scatter_speed

