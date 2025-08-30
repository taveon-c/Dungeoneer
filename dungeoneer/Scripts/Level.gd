extends Node2D
var turn : int = 0

@onready var timer : Timer = $Timer
@onready var Enemies = $Enemies
@onready var Main = $Main
@onready var Movement = $Movement
@onready var Action = $Action
@onready var Hints = $Hints
@onready var Map : TileMapLayer = $TileMapLayer
@onready var astar_grid : AStarGrid2D = AStarGrid2D.new()

@export var enemy_scenes : Array[PackedScene]
@export var player_scene : PackedScene

var player : Node2D

var MAP_HEIGHT : int = 39
var MAP_WIDTH : int = 70
var HALL_LENGTH : int = 11
var ROOM_RADII_MAX : int = 5
var ROOM_RADII_MIN : int = 3
var NUM_HALLS_MAX : int = 9
var NUM_ROOMS_MIN : int = 3
var NUM_ROOMS_MAX : int = 6
var MIN_ENEMY : int = 3
var MAX_ENEMY : int = 6

func _ready() -> void:
	generate_level()

func generate_level():
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	for x in MAP_WIDTH + 1:
		for y in MAP_HEIGHT + 1:
			Map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))

	var player_spawn = Map.map_to_local(Vector2i(10, 10))
	player = player_scene.instantiate()
	self.add_child(player)
	player.global_position = player_spawn
	
	var room_points : Array[Vector2i] = [Map.local_to_map(player.global_position)]
	var num_halls = randi_range(NUM_ROOMS_MAX, NUM_HALLS_MAX)
	var num_rooms = randi_range(NUM_ROOMS_MIN, NUM_ROOMS_MAX)
	
	for i in num_halls:
		var point = room_points.pick_random()
		var dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
		var new_point = point + dir * HALL_LENGTH
		while not in_bounds(new_point) or Map.get_cell_atlas_coords(new_point) != Vector2i(4, 3):
			point = room_points.pick_random()
			dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
			new_point = point + dir * HALL_LENGTH
		room_points.append(new_point)
		var x_sign = signi(new_point.x - point.x)
		var y_sign = signi(new_point.y - point.y)
		for x in range(mini(point.x, new_point.x) - 1, maxi(point.x, new_point.x) + 2):
			for y in range(mini(point.y, new_point.y) - 1, maxi(point.y, new_point.y) + 2):
				if in_bounds(Vector2i(x, y)):
					Map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	room_points.pop_front()
	var stair_room = randi_range(0, num_rooms - 1)
	var chest_room = randi_range(0, num_rooms - 1)
	while chest_room == stair_room:
		chest_room = randi_range(0, num_rooms)
	
	
	for i in num_rooms:
		var room = room_points.pick_random()
		room_points.erase(room)
		var left = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		var right = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		var up = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		var down = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		
		for x in range(room.x - left, room.x + right):
			for y in range(room.y - up, room.y + down):
				if x > 0 and y > 0 and x < MAP_WIDTH and y < MAP_HEIGHT:
					Map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		if i == stair_room:
			Map.set_cell(room, 0, Vector2i(9, 0))
		elif i == chest_room:
			Map.set_cell(room, 0, Vector2i(5, 7))
	
	astar_grid.region = Map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.offset = Vector2(8, 8)
	astar_grid.update()
	var walls = Map.get_used_cells_by_id(0, Vector2i(4, 3))
	for cell in walls:
		astar_grid.set_point_solid(cell)
	
	var taken_spawns : Array[Vector2] = []
	var num_enemy = randi_range(MIN_ENEMY, MAX_ENEMY)
	for i in num_enemy:
		var enemy_spawn = Map.map_to_local(Map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		while enemy_spawn in taken_spawns:
			enemy_spawn = Map.map_to_local(Map.get_used_cells_by_id(0, Vector2i(0, 0)).pick_random())
		var enemy = enemy_scenes.pick_random().instantiate()
		enemy.astar_grid = astar_grid
		Enemies.add_child(enemy)
		enemy.global_position = enemy_spawn

func in_bounds(point : Vector2i) -> bool:
	if point.x > 0 and point.y > 0 and point.x < MAP_WIDTH and point.y < MAP_HEIGHT:
		return true
	else:
		return false

func _on_turn_end() -> void:
	if turn > 0:
		Enemies.get_child(turn - 1).end_turn.disconnect(_on_turn_end)
	
	turn += 1
	if turn == Enemies.get_child_count() + 1:
		turn = 0
	else:
		Enemies.get_child(turn - 1).end_turn.connect(_on_turn_end)
		Enemies.get_child(turn - 1).regen()
	timer.start()

func _on_timer_timeout() -> void:
	if turn == 0:
		timer.stop()
		player.regen()
		Main.visible = true
	else:
		Enemies.get_child(turn - 1).take_turn()
