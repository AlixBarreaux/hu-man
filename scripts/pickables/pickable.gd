extends Area2D
class_name Pickable


@export var score_value: int = 0

signal picked_up(value: int)


func _ready() -> void:
	assert(self.score_value > 0)


func _on_area_entered(area: Area2D) -> void:
	self.picked_up.emit(self.score_value)
	self.queue_free()
