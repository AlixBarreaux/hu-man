extends HBoxContainer
class_name ScoreInfo


@export var score_value: int = 0
@onready var label: Label = $Label


func _ready() -> void:
	label.set_text(tr_n("%d point", "%d points", score_value) % score_value)
