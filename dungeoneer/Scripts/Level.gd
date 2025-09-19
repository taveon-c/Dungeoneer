extends Node2D
var turn : int = 0

@onready var timer : Timer = $Timer
@onready var map : TileMapLayer = $Map
@onready var visibility : TileMapLayer = $Visiblity
@onready var spawns : Node2D = $Spawns
@onready var astar_layers : Array[AStarGrid2D] = [AStarGrid2D.new(), AStarGrid2D.new(), AStarGrid2D.new()]
#0 = all tiles, 1 = wall tiles, 2 = ground tiles

@export var player : StaticBody2D
@export var stair : Sprite2D
@export var player_ui : CanvasLayer
@export var info : LevelInfo

func _ready() -> void:
	player.global_position = map.map_to_local(Vector2i(info.MAP_WIDTH / 2, info.MAP_HEIGHT / 2))
	generate_level()
	timer.start()

func generate_level():
	clear_level()
	
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for astar_grid in astar_layers:
		astar_grid.region = Rect2i(Vector2i(0, 0), Vector2i(info.MAP_WIDTH, info.MAP_HEIGHT))
		astar_grid.cell_size = Vector2(info.TILE_SIZE, info.TILE_SIZE)
		astar_grid.offset = Vector2(info.TILE_SIZE / 2, info.TILE_SIZE / 2)
		astar_grid.update()
	
	var num_rooms = randi_range(info.NUM_ROOMS_MIN, info.NUM_ROOMS_MAX)
	var num_halls = randi_range(info.num_rooms, info.NUM_HALLS_MAX)
	var room_dict = {}
	var room_positions = []
	
	for room in range(num_rooms):
		room_dict[room] = []
	
	for hall in range(num_halls):
		var index = randi_range(0, num_rooms)

func clear_level():
	for astar_grid in astar_layers:
		astar_grid.clear()
		astar_grid.update()
		
	map.clear()
	visibility.clear()
	var items = get_tree().get_nodes_in_group("item")
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for item in items:
		item.queue_free()
	for enemy in enemies:
		enemy.queue_free()
	map.update_internals()

func set_visible_tiles():
	var tile_ids = map.get_used_cells()
	for id in tile_ids:
		visibility.set_cell(id, 0, Vector2i(0, 0))
		var tile_position = map.map_to_local(id)
		if player.global_position.distance_to(tile_position) < 16 * info.TILE_SIZE:
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(tile_position, player.global_position)
			query.collision_mask = 0b1
			var result = space_state.intersect_ray(query)
			if not result:
				if map.get_cell_atlas_coords(id):
					visibility.erase_cell(id)
					var neighbor_cells = map.get_surrounding_cells(id)
					for cell in neighbor_cells:
						if map.get_cell_atlas_coords(cell) == Vector2i(4, 3):
							visibility.erase_cell(cell)
				else:
					visibility.erase_cell(id)

func set_astar_obstacles(layer: int, groups : Array):
	for group in groups:
		var group_nodes = get_tree().get_nodes_in_group(group)
		for node in group_nodes:
			astar_layers[layer].set_point_solid(map.local_to_map(node.global_position))

func clear_astar_obstacles(layer: int, groups : Array):
	for group in groups:
		var group_nodes = get_tree().get_nodes_in_group(group)
		for node in group_nodes:
			astar_layers[layer].set_point_solid(map.local_to_map(node.global_position), false)

func in_bounds(coords : Vector2i) -> bool:
	if coords.x > 0 and coords.y > 0 and coords.x < info.MAP_WIDTH and coords.y < info.MAP_HEIGHT:
		return true
	else:
		return false

func get_map_edge_distance(coords : Vector2i):
	var left = coords.x
	var right = info.MAP_WIDTH - coords.x - 1
	var up = coords.y
	var down = info.MAP_HEIGHT - coords.y - 1
	
	return min(left, right, up, down)

func _on_turn_end() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	turn += 1
	if turn == enemies.size() + 1:
		turn = 0
	else:
		enemies[turn - 1].info.regen_energy()
		enemies[turn - 1].indicator.set_visible(true)
	
	timer.start()

func _on_timer_timeout() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if turn == 0:
		set_visible_tiles()
		timer.stop()
		player.info.regen_energy()
		player_ui.visible = true
	else:
		enemies[turn - 1].take_turn()
	
func _on_player_moved():
	if player.global_position == stair.global_position:
		generate_level()
	set_visible_tiles()
