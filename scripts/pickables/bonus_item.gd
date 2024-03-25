extends Pickable
class_name BonusItem


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func enable() -> void:
	self.collision_shape_2d.call_deferred("set_disabled", false)
	self.sprite_2d.show()


func disable() -> void:
	self.collision_shape_2d.call_deferred("set_disabled", true)
	self.sprite_2d.hide()


func setup(new_score_value: int, new_texture: Texture2D) -> void:
	self.score_value = new_score_value
	self.sprite_2d.set_texture(new_texture)


func _ready() -> void:
	assert(numbers_displayer_scene != null)
	self.disable()


@export var numbers_displayer_scene: PackedScene = null

func _on_area_entered(_area: Area2D) -> void:
	self.picked_up.emit(self.score_value, self.sprite_2d.get_texture())
	AudioManager.play_sound_file(sound_file_path, AudioManager.TrackTypes.PICKUPS)
	self.disable()
	
	var numbers_displayer_instance: NumbersDisplayer = numbers_displayer_scene.instantiate()
	numbers_displayer_instance.color = Color(1.0, 1.0, 1.0, 1.0)
	numbers_displayer_instance.set_text(str(self.score_value))
	numbers_displayer_instance.set_global_position(self.get_global_position())
	get_tree().get_root().add_child(numbers_displayer_instance)
