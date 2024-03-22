extends Control
class_name MainMenuUI


@export var scene_to_load: PackedScene = null
@export_file("*.ogg", "*.wav") var start_game_sound: String = ""

@onready var character_info_list: VBoxContainer = $CharacterInfoList
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	assert(scene_to_load != null)
	assert(FileAccess.file_exists(start_game_sound))
	
	self.animation_player.play("intro")


var gui_input_enabled: bool = true

func _gui_input(event: InputEvent) -> void:
	if not gui_input_enabled: return
	if event is InputEventMouseButton:
		gui_input_enabled = false
		accept_event()
		AudioManager.play_sound_file(start_game_sound, AudioManager.TrackTypes.PICKUPS)
		await AudioManager.pickups_player.finished
		Global.new_game_started.emit()
		get_tree().change_scene_to_packed(scene_to_load)


func _unhandled_key_input(event: InputEvent) -> void:
	set_process_unhandled_key_input(false)
	if event is InputEventJoypadButton or event is InputEventKey:
		accept_event()
		AudioManager.play_sound_file(start_game_sound, AudioManager.TrackTypes.PICKUPS)
		await AudioManager.pickups_player.finished
		Global.new_game_started.emit()
		get_tree().change_scene_to_packed(scene_to_load)
