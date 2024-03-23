extends Panel
class_name InfoMessageUI


@onready var label: Label = $MarginContainer/Label

@export var default_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var level_cleared_color: Color = Color(0.0, 86.0, 0.360, 1.0)
@export var player_died_color: Color = Color(1.0, 0.55, 0.0, 1.0)
@export var game_over_color: Color = Color(1.0, 0.0, 0.0, 1.0)


func set_text_with_color(txt: String, color: Color = self.default_color) -> void:
	self.label.set_text(txt)
	self.label.add_theme_color_override("font_color", color)
	self.show()


func on_game_ready() -> void:
	self.set_text_with_color(tr("Get ready!"))


func on_game_started() -> void:
	self.hide()


func on_player_died() -> void:
	self.set_text_with_color(tr("You died!"), self.player_died_color)


func on_game_over() -> void:
	self.set_text_with_color(tr("Game over!"), self.game_over_color)


func on_level_cleared() -> void:
	var text: String = tr("Level completed!\nThanks for playing!")
	self.set_text_with_color(text, self.level_cleared_color)


func _initialize_signals() -> void:
	Global.game_ready.connect(on_game_ready)
	Global.game_started.connect(on_game_started)
	Global.player_died.connect(on_player_died)
	Global.game_over.connect(on_game_over)
	Global.level_cleared.connect(on_level_cleared)


func _ready() -> void:
	self.hide()
	self._initialize_signals()
