extends Node2D
var turn : int = 0
@onready var timer : Timer = $Timer
@onready var Player = $Player
@onready var Enemies = $Enemies
@onready var Main = $Main
@onready var Movement = $Movement
@onready var Action = $Action
@onready var Origin = $Origin
@onready var Hints = $Hints
@onready var Info = $Info
@onready var Map : TileMapLayer = $TileMapLayer
var MAP_HEIGHT : int = 40
var MAP_WIDTH : int = 75
var HALL_LENGTH_MIN : int = 15
var HALL_LENGTH_MAX : int = 20
var ROOM_RADII_MAX : int = 6
var ROOM_RADII_MIN : int = 3
var NUM_HALLS : int = 12
var NUM_ROOMS : int = 5

func _ready() -> void:
	generate_level()

func generate_level():
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	for x in MAP_WIDTH + 1:
		for y in MAP_HEIGHT + 1:
			Map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
	
	var room_points : Array[Vector2i] = [Map.local_to_map(Player.global_position)]
	for i in NUM_HALLS:
		var point = room_points.pick_random()
		var dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
		var hall_length = randi_range(HALL_LENGTH_MIN, HALL_LENGTH_MAX)
		var new_point = point + dir * hall_length
		while not in_bounds(new_point) or Map.get_cell_source_id(new_point) == -1:
			point = room_points.pick_random()
			dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
			hall_length = randi_range(HALL_LENGTH_MIN, HALL_LENGTH_MAX)
			new_point = point + dir * hall_length
		room_points.append(new_point)
		var x_sign = signi(new_point.x - point.x)
		var y_sign = signi(new_point.y - point.y)
		for x in range(mini(point.x, new_point.x) - 1, maxi(point.x, new_point.x) + 2):
			for y in range(mini(point.y, new_point.y) - 1, maxi(point.y, new_point.y) + 2):
				if in_bounds(Vector2i(x, y)):
					Map.erase_cell(Vector2i(x, y))
	
	for i in NUM_ROOMS:
		var room_index = randi_range(0, room_points.size()-1)
		var room = room_points.pop_at(room_index)
		var room_x = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		var room_y = randi_range(ROOM_RADII_MIN, ROOM_RADII_MAX)
		for x in range(room.x - room_x, room.x + room_x):
			for y in range(room.y - room_y, room.y + room_y):
				if x > 0 and y > 0 and x < MAP_WIDTH and y < MAP_HEIGHT:
					Map.erase_cell(Vector2i(x, y))

func in_bounds(point : Vector2i) -> bool:
	if point.x > 0 and point.y > 0 and point.x < MAP_WIDTH and point.y < MAP_HEIGHT:
		return true
	else:
		return false

func _on_turn_end() -> void:
	turn += 1
	if turn == Enemies.get_child_count() + 1:
		turn = 0
	timer.start()

func _on_timer_timeout() -> void:
	if turn == 0:
		timer.stop()
		Main.visible = true
	else:
		Enemies.get_child(turn - 1).take_turn()
