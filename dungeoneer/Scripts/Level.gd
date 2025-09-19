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
	player.global_position = map.map_to_local(Vector2i(10, 10))
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
		
	
	for x in info.MAP_WIDTH:
		for y in info.MAP_HEIGHT:
			visibility.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	var room_points : Array[Vector2i] = [map.local_to_map(player.global_position)]
	var num_halls = randi_range(info.NUM_ROOMS_MAX, info.NUM_HALLS_MAX)
	var num_rooms = randi_range(info.NUM_ROOMS_MIN, info.NUM_ROOMS_MAX)
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	for i in num_halls:
		var possible_points = []
		var point : Vector2i
		var count : int = 0
		
		while possible_points.size() == 0:
			count += 1
			if count == 9:
				generate_level()
			possible_points = []
			point = room_points.pick_random()
			for direction in directions:
				var new_point = point + direction * info.HALL_LENGTH
				if in_bounds(new_point) and get_map_edge_distance(new_point) >= info.ROOM_RADII_MAX + 2 and map.get_cell_source_id(new_point) == -1:
					possible_points.append(new_point)
		
		var new_point = possible_points.pick_random()
		room_points.append(new_point)
		
		var max_y = maxi(point.y, new_point.y)
		var min_y = mini(point.y, new_point.y)
		var max_x = maxi(point.x, new_point.x)
		var min_x = mini(point.x, new_point.x)
		
		#Walls
		for x in range(min_x - 2, max_x + 3):
			for y in range(min_y - 2, max_y + 3):
				if map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					astar_layers[1].set_point_solid(Vector2i(x, y), false)
					astar_layers[2].set_point_solid(Vector2i(x, y))
					map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
		
		#Ground
		for x in range(min_x - 1, max_x + 2):
			for y in range(min_y - 1, max_y + 2):
				astar_layers[1].set_point_solid(Vector2i(x, y))
				astar_layers[2].set_point_solid(Vector2i(x, y), false)
				map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	room_points.pop_front()
	var stair_room = randi_range(0, num_rooms - 1)
	var num_weapons = randi_range(info.MIN_NUM_WEAPONS, info.MAX_NUM_WEAPONS)
	var item_rooms = []
	for weapon in num_weapons:
		var weapon_room = randi_range(0, num_rooms - 1)
		while weapon_room == stair_room or weapon_room in item_rooms:
			weapon_room = randi_range(0, num_rooms - 1)
		item_rooms.append(weapon_room)
	
	for i in num_rooms:
		var room = room_points.pick_random()
		room_points.erase(room)
		var left = randi_range(info.ROOM_RADII_MIN, info.ROOM_RADII_MAX)
		var right = randi_range(info.ROOM_RADII_MIN, info.ROOM_RADII_MAX)
		var up = randi_range(info.ROOM_RADII_MIN, info.ROOM_RADII_MAX)
		var down = randi_range(info.ROOM_RADII_MIN, info.ROOM_RADII_MAX)
		
		for x in range(room.x - left - 1, room.x + right + 2):
			for y in range(room.y - up - 1, room.y + down + 2):
				if in_bounds(Vector2i(x, y)) and map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					astar_layers[1].set_point_solid(Vector2i(x, y), false)
					astar_layers[2].set_point_solid(Vector2i(x, y))
					map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
		
		for x in range(room.x - left, room.x + right + 1):
			for y in range(room.y - up, room.y + down + 1):
				if in_bounds(Vector2i(x, y)):
					astar_layers[1].set_point_solid(Vector2i(x, y))
					astar_layers[2].set_point_solid(Vector2i(x, y), false)
					map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		if i == stair_room:
			stair.global_position = map.map_to_local(room)
		elif i in item_rooms:
			var pickup = info.PICKUP_SCENE.instantiate()
			pickup.item = info.ITEMS.pick_random()
			spawns.add_child(pickup)
			pickup.global_position = map.map_to_local(room)
	
	var taken_spawns : Array[Vector2] = []
	var num_enemy = randi_range(info.MIN_ENEMY, info.MAX_ENEMY)
	for i in num_enemy:
		var enemy_spawn = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		while enemy_spawn in taken_spawns:
			enemy_spawn = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		var enemy = info.ENEMY_SCENES.pick_random().instantiate()
		spawns.add_child(enemy)
		enemy.global_position = enemy_spawn
		enemy.connect("end_turn", _on_turn_end)
	map.update_internals()

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
	if coords.x >= 0 and coords.y >= 0 and coords.x < info.MAP_WIDTH and coords.y < info.MAP_HEIGHT:
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
