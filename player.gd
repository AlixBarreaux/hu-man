extends Node2D


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move"):
		self.global_position = get_global_mouse_position()
