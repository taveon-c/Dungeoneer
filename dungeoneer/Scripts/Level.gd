extends Node2D
var turn : int = 0

@onready var timer : Timer = $Timer
@onready var map : TileMapLayer = $TileMapLayer
@onready var astar_layers : Array[AStarGrid2D] = [AStarGrid2D.new(), AStarGrid2D.new(), AStarGrid2D.new()]
#0 = all tiles, 1 = wall tiles, 2 = ground tiles

@export var player : StaticBody2D
@export var stair : Sprite2D
@export var player_ui : CanvasLayer
@export var level_info : LevelInfo

func _ready() -> void:
	player.global_position = map.map_to_local(Vector2i(10, 10))
	generate_level()

func generate_level():
	clear_level()
	
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for astar_grid in astar_layers:
		astar_grid.region = Rect2i(Vector2i(0, 0), Vector2i(level_info.MAP_WIDTH, level_info.MAP_HEIGHT))
		astar_grid.cell_size = Vector2(level_info.TILE_SIZE, level_info.TILE_SIZE)
		astar_grid.offset = Vector2(level_info.TILE_SIZE / 2, level_info.TILE_SIZE / 2)
		astar_grid.update()
		
	
	for x in level_info.MAP_WIDTH:
		for y in level_info.MAP_HEIGHT:
			astar_layers[2].set_point_solid(Vector2i(x, y))
			map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
	
	var room_points : Array[Vector2i] = [map.local_to_map(player.global_position)]
	var num_halls = randi_range(level_info.NUM_ROOMS_MAX, level_info.NUM_HALLS_MAX)
	var num_rooms = randi_range(level_info.NUM_ROOMS_MIN, level_info.NUM_ROOMS_MAX)
	
	for i in num_halls:
		var point = room_points.pick_random()
		var dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
		var new_point = point + dir * level_info.HALL_LENGTH
		while not in_bounds(new_point) or map.get_cell_atlas_coords(new_point) != Vector2i(4, 3):
			point = room_points.pick_random()
			dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
			new_point = point + dir * level_info.HALL_LENGTH
		room_points.append(new_point)
		var x_sign = signi(new_point.x - point.x)
		var y_sign = signi(new_point.y - point.y)
		for x in range(mini(point.x, new_point.x) - 1, maxi(point.x, new_point.x) + 2):
			for y in range(mini(point.y, new_point.y) - 1, maxi(point.y, new_point.y) + 2):
				if in_bounds(Vector2i(x, y)):
					astar_layers[1].set_point_solid(Vector2i(x, y))
					astar_layers[2].set_point_solid(Vector2i(x, y), false)
					map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	room_points.pop_front()
	var stair_room = randi_range(0, num_rooms - 1)
	var num_weapons = randi_range(level_info.MIN_NUM_WEAPONS, level_info.MAX_NUM_WEAPONS)
	var weapon_rooms = []
	for weapon in num_weapons:
		var weapon_room = randi_range(0, num_rooms - 1)
		while weapon_room == stair_room or weapon_room in weapon_rooms:
			weapon_room = randi_range(0, num_rooms - 1)
		weapon_rooms.append(weapon_room)
	
	for i in num_rooms:
		var room = room_points.pick_random()
		room_points.erase(room)
		var left = randi_range(level_info.ROOM_RADII_MIN, level_info.ROOM_RADII_MAX)
		var right = randi_range(level_info.ROOM_RADII_MIN, level_info.ROOM_RADII_MAX)
		var up = randi_range(level_info.ROOM_RADII_MIN, level_info.ROOM_RADII_MAX)
		var down = randi_range(level_info.ROOM_RADII_MIN, level_info.ROOM_RADII_MAX)
		
		for x in range(room.x - left, room.x + right):
			for y in range(room.y - up, room.y + down):
				if x > 0 and y > 0 and x < level_info.MAP_WIDTH and y < level_info.MAP_HEIGHT:
					map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		if i == stair_room:
			stair.global_position = map.map_to_local(room)
		elif i in weapon_rooms:
			var pickup = level_info.WEAPON_PICKUP_SCENE.instantiate()
			pickup.weapon = level_info.WEAPONS.pick_random()
			add_child(pickup)
			pickup.global_position = map.map_to_local(room)
	
	var taken_spawns : Array[Vector2] = []
	var num_enemy = randi_range(level_info.MIN_ENEMY, level_info.MAX_ENEMY)
	for i in num_enemy:
		var enemy_spawn = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		while enemy_spawn in taken_spawns:
			enemy_spawn = map.map_to_local(map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		var enemy = level_info.ENEMY_SCENES.pick_random().instantiate()
		add_child(enemy)
		enemy.global_position = enemy_spawn
		enemy.connect("end_turn", _on_turn_end)

func clear_level():
	for astar_grid in astar_layers:
		astar_grid.clear()
		astar_grid.update()
		
	map.clear()
	var weapons = get_tree().get_nodes_in_group("weapon")
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for weapon in weapons:
		weapon.queue_free()
	for enemy in enemies:
		enemy.queue_free()
	

func in_bounds(point : Vector2i) -> bool:
	if point.x > 0 and point.y > 0 and point.x < level_info.MAP_WIDTH and point.y < level_info.MAP_HEIGHT:
		return true
	else:
		return false

func _on_turn_end() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	turn += 1
	if turn == enemies.size() + 1:
		turn = 0
	else:
		enemies[turn - 1].stats.regen_energy()
	timer.start()

func _on_timer_timeout() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if turn == 0:
		timer.stop()
		player.stats.regen_energy()
		player_ui.visible = true
	else:
		enemies[turn - 1].take_turn()
	
func _on_player_moved():
	if player.global_position == stair.global_position:
		generate_level()
