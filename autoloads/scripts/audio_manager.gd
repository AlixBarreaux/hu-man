extends Node
#class_name AudioManager


const GAME_READY_STREAM: AudioStream = preload("res://assets/audio/game_ready.wav")
const LEVEL_CLEARED_STREAM: AudioStream = preload("res://assets/audio/level_cleared.wav")

@onready var music_player: AudioStreamPlayer = $Music
@onready var pickups_player: AudioStreamPlayer = $Pickups
@onready var emies_player: AudioStreamPlayer = $Enemies


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


func on_level_cleared() -> void:
	self.music_player.set_stream(LEVEL_CLEARED_STREAM)
	self.music_player.play()


func _initialize_signals() -> void:
	Global.game_ready.connect(on_game_ready)
	Global.level_cleared.connect(on_level_cleared)


enum AUDIO_STREAM_TYPES {
	MUSIC,
	PICKUPS,
	ENEMIES
}

func play_sound_file(sound_file: String, audio_stream_type: AUDIO_STREAM_TYPES) -> void:
	match audio_stream_type:
		AUDIO_STREAM_TYPES.MUSIC:
			self.music_player.set_stream(load(sound_file))
			self.music_player.play()
		AUDIO_STREAM_TYPES.PICKUPS:
			self.pickups_player.set_stream(load(sound_file))
			self.pickups_player.play()
		AUDIO_STREAM_TYPES.ENEMIES:
			self.enemies_player.set_stream(load(sound_file))
			self.enemies_player.play()


func _ready() -> void:
	self._initialize_asserts()
	self._initialize_signals()
