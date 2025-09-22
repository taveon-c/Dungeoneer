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

func generate_level():
	clear_level()
	
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for astar_grid in astar_layers:
		astar_grid.region = Rect2i(Vector2i(0, 0), Vector2i(info.MAP_WIDTH, info.MAP_HEIGHT))
		astar_grid.cell_size = Vector2(info.TILE_SIZE, info.TILE_SIZE)
		astar_grid.offset = Vector2(info.TILE_SIZE / 2, info.TILE_SIZE / 2)
		astar_grid.update()
	
	var num_rooms = randi_range(info.NUM_ROOMS_MIN, info.NUM_ROOMS_MAX)
	var num_halls = randi_range(num_rooms, info.NUM_HALLS_MAX)
	var hall_points = [map.local_to_map(player.global_position)]
	var hall_connects = {hall_points[0] : []}
	
	for hall in num_halls:
		var valid_points = get_next_valid_hall_points(hall_points.back(), hall_connects)
		var curr = hall_points.back()
		if valid_points.size() < 1:
			break
		var next = valid_points.pick_random()
		var left = mini(curr.x, next.x)
		var right = maxi(curr.x, next.x)
		var up = mini(curr.y, next.y)
		var down = maxi(curr.y, next.y)
		
		for x in range(left - 2, right + 3):
			for y in range(up - 2, down + 3):
				if map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					var coords = Vector2i(x, y)
					map.set_cell(coords, 0, Vector2i(4, 3))
					astar_layers[1].set_point_solid(coords, false)
					astar_layers[2].set_point_solid(coords)
		
		for x in range(left - 1, right + 2):
			for y in range(up - 1, down + 2):
				var coords = Vector2i(x, y)
				map.set_cell(coords, 0, Vector2i(0, 0))
				astar_layers[1].set_point_solid(coords)
				astar_layers[2].set_point_solid(coords, false)
		
		hall_connects[curr].append(next)
		if next in hall_connects.keys():
			hall_connects[next].append(curr)
		else:
			hall_connects[next] = [curr]
		
		hall_points.append(next)
	
	for room in mini(num_rooms, hall_points.size()):
		var point = hall_points.pop_at(randi_range(0, hall_points.size() - 1))
		var width = randi_range(info.ROOM_LENGTH_MIN, info.ROOM_LENGTH_MAX)
		var height = randi_range(info.ROOM_LENGTH_MIN, info.ROOM_LENGTH_MAX)
		
		for x in range(point.x - width/2 - 1, point.x + width/2 + 2):
			for y in range(point.y - height/2 - 1, point.y + height/2 + 2):
				if map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					var coords = Vector2i(x, y)
					map.set_cell(coords, 0, Vector2i(4, 3))
					astar_layers[1].set_point_solid(coords, false)
					astar_layers[2].set_point_solid(coords)
		
		for x in range(point.x - width/2, point.x + width/2 + 1):
			for y in range(point.y - height/2, point.y + height/2 + 1):
				var coords = Vector2i(x, y)
				map.set_cell(coords, 0, Vector2i(0, 0))
				astar_layers[1].set_point_solid(coords)
				astar_layers[2].set_point_solid(coords, false)
	
	var tile_ids = map.get_used_cells()
	for id in tile_ids:
		visibility.set_cell(id, 0, Vector2i(0, 0))
	
	var num_enemies = randi_range(info.MIN_ENEMY, info.MAX_ENEMY)
	var num_items = randi_range(info.MIN_ITEMS, info.MAX_ITEMS)
	
	stair.global_position = map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random()
	var path = astar_layers[2].get_id_path(map.local_to_map(player.global_position), map.local_to_map(stair.global_position))
	while path.size() < 10:
		stair.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		path = astar_layers[2].get_id_path(map.local_to_map(player.global_position), map.local_to_map(stair.global_position))
	
	var item_positions = []
	for item in num_items:
		var pickup = info.PICKUP_SCENE.instantiate()
		pickup.item = info.ITEMS.pick_random()
		add_child(pickup)
		pickup.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		while pickup.global_position == stair.global_position or pickup.global_position == player.global_position:
			pickup.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		item_positions.append(pickup.global_position)
	
	for num in num_enemies:
		var enemy = info.ENEMY_SCENES.pick_random().instantiate()
		add_child(enemy)
		enemy.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		while enemy.global_position in item_positions or enemy.global_position == player.global_position:
			enemy.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
	
	timer.start()

func get_next_valid_hall_points(hall_point, hall_connects):
	var valid_points = []
	var connections = hall_connects[hall_point]
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var next = hall_point + direction * info.HALL_LENGTH
		if not next in connections:
			match direction:
				Vector2i.LEFT:
					if next.x > info.ROOM_LENGTH_MAX:
						valid_points.append(next)
				Vector2i.RIGHT:
					if next.x < info.MAP_WIDTH - info.ROOM_LENGTH_MAX - 1:
						valid_points.append(next)
				Vector2i.UP:
					if next.y > info.ROOM_LENGTH_MAX:
						valid_points.append(next)
				Vector2i.DOWN:
					if next.y < info.MAP_HEIGHT - info.ROOM_LENGTH_MAX - 1:
						valid_points.append(next)
	return valid_points

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
	var ground_cells = map.get_used_cells_by_id(0, Vector2i(0, 0))
	var wall_cells = map.get_used_cells_by_id(0, Vector2i(4, 3))
	for cell in wall_cells:
		visibility.set_cell(cell, 0, Vector2i(0, 0))
		
	for cell in ground_cells:
		visibility.set_cell(cell, 0, Vector2i(0, 0))
		var tile_position = map.map_to_local(cell)
		if player.global_position.distance_to(tile_position) < 16 * info.TILE_SIZE:
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(player.global_position, tile_position)
			query.collision_mask = 0b1
			var result = space_state.intersect_ray(query)
			if not result:
				visibility.erase_cell(cell)
				var neighbor_cells = map.get_surrounding_cells(cell)
				for neighbor in neighbor_cells:
					if map.get_cell_atlas_coords(neighbor) == Vector2i(4, 3):
						visibility.erase_cell(neighbor)

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
	
	if turn == 0:
		player.info.regen_energy()
	else:
		enemies[turn-1].info.regen_energy()
		enemies[turn-1].disconnect("end_turn", _on_turn_end)
	
	turn = (turn + 1) % (enemies.size() + 1)
	print(turn)
	print(enemies.size())
	print()
	if turn == 0:
		if player.info.health <= 0:
			print("YOU DIED")
			get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		else:
			player_ui.visible = true
	else:
		enemies[turn-1].connect("end_turn", _on_turn_end)
		enemies[turn-1].choose_action()
	
func _on_player_moved():
	if player.global_position == stair.global_position:
		generate_level()
	set_visible_tiles()
