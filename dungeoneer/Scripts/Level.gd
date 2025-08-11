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
var HALL_LENGTH : int = 11
var ROOM_RADII_MAX : int = 5
var ROOM_RADII_MIN : int = 3
var NUM_HALLS_MAX : int = 9
var NUM_ROOMS_MIN : int = 3
var NUM_ROOMS_MAX : int = 6

func _ready() -> void:
	generate_level()

func generate_level():
	var hall_dirs : Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	for x in MAP_WIDTH + 1:
		for y in MAP_HEIGHT + 1:
			Map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
	
	var room_points : Array[Vector2i] = [Map.local_to_map(Player.global_position)]
	var num_halls = randi_range(NUM_ROOMS_MAX, NUM_HALLS_MAX)
	var num_rooms = randi_range(NUM_ROOMS_MIN, NUM_ROOMS_MAX)
	
	for i in num_halls:
		var point = room_points.pick_random()
		var dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
		var new_point = point + dir * HALL_LENGTH
		while not in_bounds(new_point) or Map.get_cell_source_id(new_point) == -1:
			point = room_points.pick_random()
			dir = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)].pick_random()
			new_point = point + dir * HALL_LENGTH
		room_points.append(new_point)
		var x_sign = signi(new_point.x - point.x)
		var y_sign = signi(new_point.y - point.y)
		for x in range(mini(point.x, new_point.x) - 1, maxi(point.x, new_point.x) + 2):
			for y in range(mini(point.y, new_point.y) - 1, maxi(point.y, new_point.y) + 2):
				if in_bounds(Vector2i(x, y)):
					Map.erase_cell(Vector2i(x, y))
	
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
