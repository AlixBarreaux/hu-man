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
	self.disable()


func _on_area_entered(_area: Area2D) -> void:
	self.picked_up.emit(self.score_value, self.sprite_2d.get_texture())
	AudioManager.play_sound_file(sound_file_path, AudioManager.TrackTypes.PICKUPS)
	self.disable()
