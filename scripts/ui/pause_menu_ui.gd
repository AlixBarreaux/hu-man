extends Panel
class_name PauseMenuUI


@export var first_element_to_grab_focus: Control = null


func _ready() -> void:
	self.hide()
	assert(first_element_to_grab_focus != null)


func _unhandled_key_input(_event: InputEvent) -> void:
	if Global.is_game_over: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().get_root().set_input_as_handled()
		self.set_visible(not self.is_visible())
	
		if self.is_visible():
			get_tree().set_pause(true)
			first_element_to_grab_focus.grab_focus()
		else:
			get_tree().set_pause(false)


func _on_resume_button_pressed() -> void:
	self.set_visible(false)
	get_tree().set_pause(false)
