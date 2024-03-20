extends Pickable
class_name BonusItem


enum Types {
	TIER_1,
	TIER_2,
	TIER_3,
	TIER_4,
	TIER_5,
	TIER_6,
	TIER_7,
	TIER_8,
}

var type: Types = Types.TIER_1


const image_path_list: PackedStringArray = [
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
]

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func enable() -> void:
	self.collision_shape_2d.call_deferred("set_disabled", false)
	self.sprite_2d.show()


func disable() -> void:
	self.collision_shape_2d.call_deferred("set_disabled", true)
	self.sprite_2d.hide()


func _ready() -> void:
	self.disable()
	
	# Each image to load from the list should exist
	for image_file in self.image_path_list:
		assert(FileAccess.file_exists(image_file))
	
	match self.type:
		Types.TIER_1:
			self.score_value = 100
			sprite_2d.set_texture(load(image_path_list[0]))
		Types.TIER_2:
			self.score_value = 300
			sprite_2d.set_texture(load(image_path_list[1]))
		Types.TIER_3:
			self.score_value = 500
			sprite_2d.set_texture(load(image_path_list[2]))
		Types.TIER_4:
			self.score_value = 700
			sprite_2d.set_texture(load(image_path_list[3]))
		Types.TIER_5:
			self.score_value = 1000
			sprite_2d.set_texture(load(image_path_list[4]))
		Types.TIER_6:
			self.score_value = 2000
			sprite_2d.set_texture(load(image_path_list[5]))
		Types.TIER_7:
			self.score_value = 3000
			sprite_2d.set_texture(load(image_path_list[6]))
		Types.TIER_8:
			self.score_value = 5000
			sprite_2d.set_texture(load(image_path_list[7]))
		_:
			printerr(self.name, ": Error: Unrecognized tier type!")


func _on_area_entered(_area: Area2D) -> void:
	self.picked_up.emit(self.score_value)
	self.disable()
