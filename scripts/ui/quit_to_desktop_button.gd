extends Button
class_name QuitToDesktopButton


func _on_pressed() -> void:
	get_tree().quit()
