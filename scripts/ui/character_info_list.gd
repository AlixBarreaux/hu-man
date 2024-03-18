extends VBoxContainer
class_name CharacterInfoList


@export_category("Debug")
@export var hide_on_ready: bool = true


func _ready() -> void:
	if not hide_on_ready: return
	for node in self.get_children():
		if not node is CharacterInfo: continue
		node.hide()
