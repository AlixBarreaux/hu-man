extends Label
class_name VersionLabel


func _ready() -> void:
	var version_identifier: String = ProjectSettings.get_setting("application/config/version")
	self.set_text(tr("Version: ") + version_identifier)
