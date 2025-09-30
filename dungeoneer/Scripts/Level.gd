extends Node2D
var turn : int = 0

@onready var timer : Timer = $Timer
@onready var map : TileMapLayer = $Map
@onready var visibility : TileMapLayer = $Visiblity
@onready var astar_grid : AStarGrid2D = AStarGrid2D.new()
#0 = all tiles, 1 = wall tiles, 2 = ground tiles

@export var player : StaticBody2D
@export var hints : Node2D
@export var entities : Node
@export var stair : Sprite2D
@export var player_ui : CanvasLayer
@export var info : LevelInfo

var curr_level = 0

func _ready() -> void:
	player.global_position = map.map_to_local(Vector2i(info.MAP_SIZES[curr_level] / 2, info.MAP_SIZES[curr_level] / 2))
	generate_level()

func generate_level():
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	while true:
		clear_level()
		var map_rect = Rect2i(Vector2i(0, 0), Vector2i(info.MAP_SIZES[curr_level], info.MAP_SIZES[curr_level]))
		astar_grid.region = map_rect
		astar_grid.cell_size = Vector2(info.TILE_SIZE, info.TILE_SIZE)
		astar_grid.offset = Vector2(info.TILE_SIZE / 2, info.TILE_SIZE / 2)
		astar_grid.update()
		astar_grid.fill_solid_region(map_rect)
		var hall_points = generate_halls()
		generate_rooms(hall_points)
		map.update_internals()
		
		var tile_ids = map.get_used_cells()
		for id in tile_ids:
			visibility.set_cell(id, 0, Vector2i(0, 0))
		
		for i in range(8):
			stair.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
			var path = astar_grid.get_point_path(map.local_to_map(stair.global_position), map.local_to_map(player.global_position))
			if path.size() > info.STAIR_DISTANCES[curr_level]:
				var num_items = info.ITEM_NUMS[curr_level]
				var item_positions = []
				for item in num_items:
					var pickup = info.PICKUP_SCENE.instantiate()
					pickup.item = info.ITEMS.pick_random()
					entities.add_child(pickup)
					pickup.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
					while pickup.global_position == stair.global_position or pickup.global_position == player.global_position:
						pickup.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
					item_positions.append(pickup.global_position)
				
				var num_enemies = info.ENEMY_NUMS[curr_level]
				for num in num_enemies:
					var enemy = info.ENEMY_SCENES.pick_random().instantiate()
					enemy.player = player
					entities.add_child(enemy)
					enemy.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
					while enemy.global_position in item_positions or enemy.global_position == player.global_position:
						enemy.global_position = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
					
					if enemy.is_player_visible():
						enemy.last_player_position = player.global_position
					else:
						enemy.last_player_position = enemy.global_position
				
				timer.start()
				return

func generate_rooms(hall_points : Array[Vector2i]):
	for room in hall_points.size():
		var point = hall_points.pop_front()
		var width = randi_range(info.ROOM_LENGTH_MIN, info.ROOM_LENGTH_MAX)
		var height = randi_range(info.ROOM_LENGTH_MIN, info.ROOM_LENGTH_MAX)
		
		for x in range(point.x - width/2 - 1, point.x + width/2 + 2):
			for y in range(point.y - height/2 - 1, point.y + height/2 + 2):
				if map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					var coords = Vector2i(x, y)
					map.set_cell(coords, 0, Vector2i(1, 0))
		
		for x in range(point.x - width/2, point.x + width/2 + 1):
			for y in range(point.y - height/2, point.y + height/2 + 1):
				var coords = Vector2i(x, y)
				map.set_cell(coords, 0, Vector2i(0, 0))
				astar_grid.set_point_solid(coords, false)

func generate_halls() -> Array[Vector2i]:
	var hall_points : Array[Vector2i] = [map.local_to_map(player.global_position)]
	var hall_connects = {hall_points[0] : []}
	var valid_points = get_next_valid_hall_points(hall_points.back(), hall_connects)
	while valid_points.size() > 0:
		var curr = hall_points.back()
		var next = valid_points.pick_random()
		var left = mini(curr.x, next.x)
		var right = maxi(curr.x, next.x)
		var up = mini(curr.y, next.y)
		var down = maxi(curr.y, next.y)
		
		for x in range(left - 2, right + 3):
			for y in range(up - 2, down + 3):
				if map.get_cell_atlas_coords(Vector2i(x, y)) != Vector2i(0, 0):
					var coords = Vector2i(x, y)
					map.set_cell(coords, 0, Vector2i(1, 0))
		
		for x in range(left - 1, right + 2):
			for y in range(up - 1, down + 2):
				var coords = Vector2i(x, y)
				map.set_cell(coords, 0, Vector2i(0, 0))
				astar_grid.set_point_solid(coords, false)
		
		hall_connects[curr].append(next)
		if next in hall_connects.keys():
			hall_connects[next].append(curr)
			valid_points = get_next_valid_hall_points(curr, hall_connects)
		else:
			hall_connects[next] = [curr]
			hall_points.append(next)
			valid_points = get_next_valid_hall_points(next, hall_connects)
	return hall_points

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
					if next.x < info.MAP_SIZES[curr_level]- info.ROOM_LENGTH_MAX - 1:
						valid_points.append(next)
				Vector2i.UP:
					if next.y > info.ROOM_LENGTH_MAX:
						valid_points.append(next)
				Vector2i.DOWN:
					if next.y < info.MAP_SIZES[curr_level] - info.ROOM_LENGTH_MAX - 1:
						valid_points.append(next)
	return valid_points

func clear_level():
	astar_grid.clear()
	astar_grid.update()
		
	map.clear()
	visibility.clear()
	var items = get_tree().get_nodes_in_group("pickup")
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for item in items:
		item.queue_free()
	for enemy in enemies:
		enemy.queue_free()

func set_visible_tiles():
	var ground_cells = map.get_used_cells_by_id(0, Vector2i(0, 0))
	var wall_cells = map.get_used_cells_by_id(0, Vector2i(1, 0))
	for cell in wall_cells:
		visibility.set_cell(cell, 0, Vector2i(0, 0))
		
	for cell in ground_cells:
		visibility.set_cell(cell, 0, Vector2i(0, 0))
		var tile_position = map.map_to_local(cell)
		if player.global_position.distance_to(tile_position) < 10 * info.TILE_SIZE:
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(player.global_position, tile_position)
			query.collision_mask = 0b1
			var result = space_state.intersect_ray(query)
			if not result:
				visibility.erase_cell(cell)
				for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
					if map.get_cell_atlas_coords(cell + direction) != Vector2i(-1, -1):
						visibility.erase_cell(cell+direction)

func set_astar_obstacles(groups : Array, ignore : Node = null):
	for group in groups:
		var group_nodes = get_tree().get_nodes_in_group(group)
		for node in group_nodes:
			if ignore != node:
				astar_grid.set_point_solid(map.local_to_map(node.global_position))

func clear_astar_obstacles(groups : Array):
	for group in groups:
		var group_nodes = get_tree().get_nodes_in_group(group)
		for node in group_nodes:
			astar_grid.set_point_solid(map.local_to_map(node.global_position), false)

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
		player.info.spend_energy(player.info.get_weight())
	else:
		enemies[turn-1].info.regen_energy()
		enemies[turn-1].disconnect("end_turn", _on_turn_end)
	
	turn = (turn + 1) % (enemies.size() + 1)
	if turn == 0 or enemies.size() == 0:
		if player.info.health <= 0:
			print("YOU DIED")
			get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		else:
			player_ui.visible = true
	else:
		enemies[turn-1].connect("end_turn", _on_turn_end)
		enemies[turn-1].choose_action()
	
func _on_player_moved():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.is_player_visible():
			enemy.last_player_position = player.global_position
	
	if player.global_position == stair.global_position:
		curr_level += 1
		if curr_level == info.MAP_SIZES.size():
			print("YOU WIN")
			get_tree().change_scene_to_file("res://Scenes/menu.tscn")
			return
		else:
			player.info.max_energy += 1
			player.info.max_health += 1
			player.info.health = player.info.max_health
			generate_level()
	set_visible_tiles()
