extends Area2D
class_name Pickable


@export var score_value: int = 0
@export_file("*.ogg", "*.wav") var sound_file_path: String = ""

signal picked_up(value: int)


func _ready() -> void:
	assert(self.score_value > 0)
	assert(FileAccess.file_exists(sound_file_path))


func _on_area_entered(_area: Area2D) -> void:
	self.picked_up.emit(self.score_value)
	AudioManager.play_sound_file(sound_file_path, AudioManager.TRACK_TYPES.PICKUPS)
	self.queue_free()
