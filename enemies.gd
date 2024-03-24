extends Node
class_name Enemies


@onready var tile_map: TileMap = get_tree().get_root().get_node("Level/TileMap")
#@onready var tile_size: float = tile_map.get_tileset().get_tile_size().x


var walkable_tiles_list: PackedVector2Array = []

func build_walkable_tiles_list() -> void:
	for tile in tile_map.get_used_cells(0):
		var cell_tile_data: TileData = tile_map.get_cell_tile_data(0, tile)
		if cell_tile_data and cell_tile_data.get_custom_data("walkable"):
			walkable_tiles_list.append(tile)


func _ready() -> void:
	for enemy in self.get_children():
		self.build_walkable_tiles_list()
