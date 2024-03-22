extends Node
#class_name AudioManager


const GAME_READY_STREAM: AudioStream = preload("res://assets/audio/game_ready.wav")
const LEVEL_CLEARED_STREAM: AudioStream = preload("res://assets/audio/level_cleared.wav")

@onready var music_player: AudioStreamPlayer = $Music
@onready var pickups_player: AudioStreamPlayer = $Pickups
@onready var enemies_player: AudioStreamPlayer = $Enemies


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
	self.stop_all_tracks()
	self.music_player.set_stream(LEVEL_CLEARED_STREAM)
	self.music_player.play()


func _initialize_signals() -> void:
	Global.game_ready.connect(on_game_ready)
	Global.level_cleared.connect(on_level_cleared)


enum TrackTypes {
	MUSIC,
	PICKUPS,
	ENEMIES
}

func play_sound_file(sound_file: String, track_type: TrackTypes) -> void:
	match track_type:
		TrackTypes.MUSIC:
			self.music_player.set_stream(load(sound_file))
			self.music_player.play()
		TrackTypes.PICKUPS:
			self.pickups_player.set_stream(load(sound_file))
			self.pickups_player.play()
		TrackTypes.ENEMIES:
			self.enemies_player.set_stream(load(sound_file))
			self.enemies_player.play()
		_:
			printerr("(!) ERROR: In: " + self.get_name() + ": Unandled case in play_sound_file()!")


func stop_track(track_type: TrackTypes) -> void:
	match track_type:
		TrackTypes.MUSIC:
			self.music_player.stop()
		TrackTypes.PICKUPS:
			self.pickups_player.stop()
		TrackTypes.ENEMIES:
			self.enemies_player.stop()
		_:
			printerr("(!) ERROR: In: " + self.get_name() + ": Unandled case in stop_track()!")


func stop_all_tracks() -> void:
	for node in self.get_children():
		node.stop()


func _ready() -> void:
	self._initialize_asserts()
	self._initialize_signals()
