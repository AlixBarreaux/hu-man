extends Panel
class_name InfoMessageUI


@onready var label: Label = $MarginContainer/Label

@export var level_cleared_color: Color = Color(0.0, 86.0, 0.360, 255.0)
@export var game_over_color: Color = Color()


func set_text_with_color(txt: String, color: Color) -> void:
	self.label.set_text(txt)
	self.label.add_theme_color_override("font_color", color)


func on_level_cleared() -> void:
	self.set_text_with_color("Level cleared!", self.level_cleared_color)
	self.label.show()


func _ready() -> void:
	Global.level_cleared.connect(on_level_cleared)
