extends Node
#class_name Global


signal level_cleared
signal game_over

signal score_changed
signal high_score_changed

signal player_died
signal player_finished_dying
signal game_ready
signal game_started


var score: int = 0:
	set = set_score
	
func set_score(value: int) -> void:
	score = value
	self.score_changed.emit()
	
	if self.score > self.high_score:
		self.set_high_score(self.score)


func increase_score(value: int) -> void:
	set_score(score + value)


var high_score: int = 0

func set_high_score(value: int) -> void:
	high_score = value
	self.high_score_changed.emit()


const SAVE_GAME_FILE_PATH: String = "user://game_save.res"
var game_save: GameSave = GameSave.new()


func save_game() -> void:
	game_save.high_score = self.high_score
	ResourceSaver.save(game_save, self.SAVE_GAME_FILE_PATH)
	

func load_game() -> void:
	var game_save_exists: bool = FileAccess.file_exists(SAVE_GAME_FILE_PATH)
	
	if not game_save_exists:
		save_game()
	
	var game_save_to_load = load(SAVE_GAME_FILE_PATH)
	
	if game_save_to_load == null:
		printerr("Error while loading the game save file!")
		return
	
	self.high_score = game_save_to_load.high_score


func on_game_over() -> void:
	self.save_game()


func _ready() -> void:
	self.game_over.connect(on_game_over)
	
	self.load_game()
