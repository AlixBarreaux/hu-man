extends CanvasLayer
class_name ScoringUI


@onready var score_label: Label = $Panel/HBoxContainer/ScoreLabel
@onready var high_score_label: Label = $Panel/HBoxContainer/HighScoreLabel


var high_score_label_text: String = "High Score: " + str(Global.high_score)
var score_label_text: String = "Score: " + str(Global.score)


func on_score_changed() -> void:
	self.score_label.set_text("Score:\n" + str(Global.score))


func on_high_score_changed() -> void:
	self.high_score_label.set_text("High Score:\n" + str(Global.high_score))


func _ready() -> void:
	Global.score_changed.connect(on_score_changed)
	Global.high_score_changed.connect(on_high_score_changed)
	
	self.high_score_label.set_text("High Score:\n" + str(Global.high_score))
	self.score_label.set_text("Score:\n" + str(Global.score))
