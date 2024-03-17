extends Panel
class_name LivesUI



@onready var label: Label = $HBoxContainer/Label


func on_lives_changed() -> void:
	self.label.set_text("x " + str(Global.lives))


func _ready() -> void:
	Global.lives_changed.connect(on_lives_changed)
