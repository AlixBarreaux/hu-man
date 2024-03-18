extends Label
class_name VersionLabel


func _ready() -> void:
	var version_identifier : String = ProjectSettings.get_setting("application/config/version")
	self.set_text("Version: " + version_identifier)
	
	#set("theme_override_colors/font_color", )
	
	print("Item type list: ", get_theme().get_theme_item_type_list(Theme.DATA_TYPE_COLOR))
	
	print("Item list : ", get_theme().get_theme_item_list(Theme.DATA_TYPE_COLOR, "Label"))
	
	print("Has item: ", get_theme().has_theme_item(Theme.DATA_TYPE_COLOR, "Label", "font_color"))
	
	print(get_theme().get_theme_item(Theme.DATA_TYPE_COLOR, "Label", "font_color"))
	#print(get("theme_override_colors/font_color"))
	
	#var tween: Tween = create_tween()
	#tween.tween_property(self, "theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 0.5), 1.0)
