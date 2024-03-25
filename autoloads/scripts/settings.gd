extends Node
#class_name Settings


func _ready() -> void:
	TranslationServer.set_locale(OS.get_locale())
	if not OS.is_debug_build():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
