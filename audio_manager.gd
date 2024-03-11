extends Node
class_name AudioManager


const GAME_READY_STREAM: AudioStream = preload("res://assets/audio/game_ready.ogg")
const HIGH_SCORE_BEAT_STREAM: AudioStream = preload("res://assets/audio/high_score_beat.wav")


@onready var music_player: AudioStreamPlayer = $Music


func _initialize_asserts() -> void:
	var stream_list: Array[AudioStream] = [
		GAME_READY_STREAM
	]
	
	for stream in stream_list:
		assert(stream != null)


func start() -> void:
	self.music_player.set_stream(self.GAME_READY_STREAM)
	self.music_player.play()
	await self.music_player.finished
	Global.game_started.emit()


func on_game_ready() -> void:
	self.start()


func _initialize_signals() -> void:
	Global.game_ready.connect(on_game_ready)


func _ready() -> void:
	self._initialize_asserts()
	self._initialize_signals()
	
	self.start()
