extends Area2D
class_name WarpZone


@export var warp_destination_node: Node2D = null
@onready var warp_destination_position: Vector2 = warp_destination_node.get_global_position()

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Flush ref, not used anymore
	warp_destination_node = null


func _on_body_entered(body: Player) -> void:
	body.set_global_position(warp_destination_position)
