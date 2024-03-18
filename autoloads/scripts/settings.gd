extends Node
#class_name Settings


func _ready() -> void:
	TranslationServer.set_locale(OS.get_locale())
