extends Node2D


@export var tile_map: TileMap = null

var astar_grid_2d: AStarGrid2D = null
var current_id_path: Array[Vector2i] = []


var target_position: Vector2 = self.global_position
var is_moving: bool = false

func _ready() -> void:
	self.astar_grid_2d = AStarGrid2D.new()
	self.astar_grid_2d.region = tile_map.get_used_rect()
	self.astar_grid_2d.cell_size = tile_map.tile_set.tile_size
	self.astar_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	self.astar_grid_2d.update()
	
	
	#for cell_position in tile_map.get_used_cells(0):
		#print("Cell position: ", cell_position)
		
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var cell_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y,
			)
			
			var tile_custom_data: TileData = tile_map.get_cell_tile_data(0, cell_position)

			# Tell astar which tiles can't be walked
			if tile_custom_data == null or tile_custom_data.get_custom_data("walkable") == false:
				astar_grid_2d.set_point_solid(cell_position)



func _input(event):
	if event.is_action_pressed("move") == false:
		return

	# Generate all points of the path
	var id_path = astar_grid_2d.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(get_global_mouse_position())
	).slice(1)
	
	if id_path != []:
		current_id_path = id_path


var speed: float = 1.0

func _physics_process(delta: float) -> void:
	if current_id_path == []:
		return
	
	
	var target_position: Vector2 = tile_map.map_to_local(current_id_path[0])
	
	
	# Move to target position
	self.global_position = self.global_position.move_toward(target_position, speed)
	
	if self.global_position == target_position:
		current_id_path.pop_front()
