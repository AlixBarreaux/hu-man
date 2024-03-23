extends HBoxContainer
class_name ScoreInfo


@export var score_value: int = 0
@export var texture_modulation_color: Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func _ready() -> void:
	label.set_text(tr_n("%d point", "%d points", score_value) % score_value)
	texture_rect.set_modulate(texture_modulation_color)
