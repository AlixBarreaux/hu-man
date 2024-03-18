extends HBoxContainer
class_name CharacterInfo


@export var character_name: String = ""
@onready var label: Label = $Label

var empty_color: Color = Color(0.0, 0.0, 0.0, 0.0)
@export var text_color: Color = empty_color


func _ready() -> void:
	assert(character_name != "")
	label.set_text(self.character_name)
	
	if text_color == empty_color:
		return
	
	label.set_modulate(text_color)
