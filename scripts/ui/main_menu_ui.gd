extends Control
class_name MainMenuUI


@export var scene_to_load: PackedScene = null

@onready var character_info_list: VBoxContainer = $CharacterInfoList
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	assert(scene_to_load != null)
	
	self.animation_player.play("intro")



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		accept_event()
		get_tree().change_scene_to_packed(scene_to_load)
		Global.new_game_started.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey:
		accept_event()
		get_tree().change_scene_to_packed(scene_to_load)
		Global.new_game_started.emit()
