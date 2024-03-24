extends Node
#class_name Global


signal level_cleared
signal game_over
signal new_game_started

signal lives_changed
signal score_changed
signal high_score_changed

signal player_died
signal player_finished_dying
signal game_ready
signal game_started

var initial_lives: int = 2
var lives: int = initial_lives
var max_lives: int = 5
var is_game_over: bool = false


@export var success_sound_file_path: String = "res://assets/audio/success.wav"
## Number of points to score to get an extra life.
var point_to_gain_life_base_cap: int = 10000
var points_to_gain_life_cap: int = point_to_gain_life_base_cap


func reset() -> void:
	is_game_over = false
	set_score(0)
	set_lives(initial_lives)


func set_lives(value: int) -> void:
	lives = value
	self.lives_changed.emit()


func increase_lives(value: int = 1) -> void:
	if lives + value > max_lives: return
	set_lives(lives + value)


func decrease_lives(value: int = 1) -> void:
	var remaining_lives: int = lives - value
	
	if remaining_lives < 0:
		is_game_over = true
		self.game_over.emit()
		return
	
	set_lives(remaining_lives)
	Global.player_died.emit()


var score: int = 0:
	set = set_score
	
func set_score(value: int) -> void:
	score = value
	self.score_changed.emit()
	
	if self.score >= points_to_gain_life_cap:
		self.increase_lives()
		points_to_gain_life_cap += point_to_gain_life_base_cap
		AudioManager.play_sound_file(success_sound_file_path, AudioManager.TrackTypes.MUSIC)
	
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


var try_to_replace_corrupted_save_file: bool = false

func save_game() -> void:
	game_save.high_score = self.high_score
	var resource_to_save: Error = ResourceSaver.save(game_save, self.SAVE_GAME_FILE_PATH)
	
	if resource_to_save != OK:
		if try_to_replace_corrupted_save_file:
			printerr("(!) ERROR: In: " + self.get_name() + ": Couldn't create a new save game file!")
			return
		printerr("(!) ERROR: In: " + self.get_name() + ": Couldn't save the game save file!")
		
		printerr("Attempting to delete the save game file...")
		var file_removal_error: Error = DirAccess.remove_absolute(SAVE_GAME_FILE_PATH)
		if file_removal_error != OK:
			printerr("(!) ERROR: In: " + self.get_name() + ": Couldn't remove the game save file!")
			return
			
		printerr("Attempting to create a new save game file...")
		try_to_replace_corrupted_save_file = true
		self.save_game()
	

func load_game() -> void:
	var game_save_exists: bool = FileAccess.file_exists(SAVE_GAME_FILE_PATH)
	
	if not game_save_exists:
		save_game()
	
	var game_save_to_load: Object = load(SAVE_GAME_FILE_PATH)
	
	if game_save_to_load == null:
		printerr("(!) ERROR: In: " + self.get_name() + ": Couldn't load the game save file!")
		return
	
	self.set_high_score(game_save_to_load.high_score)


func on_new_game_started() -> void:
	self.reset()


func on_player_died() -> void:
	# Keep progression even if the game didn't end
	self.save_game()


func on_game_over() -> void:
	self.save_game()


func on_level_cleared() -> void:
	self.save_game()


func _ready() -> void:
	assert(FileAccess.file_exists(success_sound_file_path))
	
	self.new_game_started.connect(on_new_game_started)
	self.player_died.connect(on_player_died)
	self.game_over.connect(on_game_over)
	self.level_cleared.connect(on_level_cleared)
	
	self.load_game()
	
	var level_node: Level = get_tree().get_root().get_node_or_null("Level")
	if level_node == null: return
	await level_node.ready
	reset()
