extends Node
class_name BonusItems


signal item_picked_up(value: int)

const score_value_list: PackedInt32Array = [
	100,
	300,
	500,
	700,
	1000,
	2000,
	3000,
	5000
]

const image_file_path_list: PackedStringArray = [
	"res://assets/player_walk.png",
	"res://assets/zombie_walk.png",
	"res://assets/tiles.png",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg",
	"res://icon.svg"
]

@onready var level: Level = get_tree().get_root().get_node("Level")
## A tier to define each time a new level is loaded
@onready var current_tier: int = 3
var total_tiers_count: int = score_value_list.size()


func on_bonus_item_picked_up(value: int, texture: Texture2D) -> void:
	self.item_picked_up.emit(value, texture)


# Values to inject
var score_value: int = 0
var texture_file_path: String = ""

func setup_children() -> void:
	# TODO: Set the tier depending on the number of the level
	#current_tier = 
	assert(current_tier > 0 and current_tier <= total_tiers_count)
	
	self.score_value = score_value_list[current_tier - 1]
	self.texture_file_path = image_file_path_list[current_tier - 1]
	
	for bonus_item in self.get_children():
		bonus_item.setup(self.score_value, load(self.texture_file_path))
		bonus_item.picked_up.connect(on_bonus_item_picked_up)


func _initialize_asserts() -> void:
	assert(self.image_file_path_list.size() == self.score_value_list.size())
	
	for image_file in self.image_file_path_list:
		assert(FileAccess.file_exists(image_file))
	
	for value in self.score_value_list:
		assert(value > 0)


func _ready() -> void:
	self._initialize_asserts()
	self.setup_children()
