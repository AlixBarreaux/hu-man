extends Area2D
class_name HurtBox


@export var actor_to_hurt: Node2D = null


func _ready() -> void:
	assert(self.actor_to_hurt != null)


func _on_area_entered(area: Area2D) -> void:
	for collision_shape in self.get_children():
		collision_shape.call_deferred("set_disabled", true)
	
	self.actor_to_hurt.die()
