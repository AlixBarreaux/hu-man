extends CharacterBody2D
class_name Player


@export var speed: float = 100.0

var movement_input_vector: Vector2 = Vector2(0.0, 0.0)
var direction: Vector2 = Vector2(1.0, 0.0)
var next_direction: Vector2 = Vector2(-1.0, 0.0)


func _unhandled_key_input(event: InputEvent) -> void:
	movement_input_vector.x = Input.get_axis("move_left", "move_right")
	#if movement_input_vector.x != 0: return
	movement_input_vector.y = Input.get_axis("move_up", "move_down")


@onready var next_direction_detector: Node2D = $NextDirectionRotator/NextDirectionDetector

func can_go_in_next_direction() -> bool:
	#print("Ray left: ", next_direction_detector.get_child(0).is_colliding())
	#print("Ray right: ",next_direction_detector.get_child(1).is_colliding())
	
	for raycast in next_direction_detector.get_children():
		if raycast.is_colliding():
			return false
	return true

@onready var next_direction_rotator: Node2D = $NextDirectionRotator

func _physics_process(delta: float) -> void:
	if can_go_in_next_direction():
		direction = next_direction
	
	if movement_input_vector != Vector2(0.0, 0.0):
		next_direction = movement_input_vector
	
	
	if next_direction.x == -1.0:
		next_direction_rotator.set_rotation(deg_to_rad(180.0))
	elif next_direction.x == 1.0:
		next_direction_rotator.set_rotation(deg_to_rad(0.0))
	elif next_direction.y == -1.0:
		next_direction_rotator.set_rotation(deg_to_rad(-90.0))
	elif next_direction.y == 1.0:
		next_direction_rotator.set_rotation(deg_to_rad(90.0))
	
	
	self.velocity = direction * speed
	
	self.move_and_slide()
	print(can_go_in_next_direction())
