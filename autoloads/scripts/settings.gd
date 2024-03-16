extends Node
#class_name Settings


func _read() -> void:
	TranslationServer.set_locale(OS.get_locale())
