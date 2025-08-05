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
var ROOM_RADII : Array[int] = [1, 10]
var STEPS : int = 4

func _ready() -> void:
	generate_level()

func generate_level():
	for x in MAP_WIDTH + 1:
		for y in MAP_HEIGHT + 1:
			Map.set_cell(Vector2i(x, y), 0, Vector2i(4, 3))
	
	var room_points : Array[Vector2i] = [Map.local_to_map(Player.global_position)]
	for step in STEPS:
		var new_points : Array[Vector2i] = []
		while room_points.size() > 0:
			var point = room_points.pop_front()
			var top_radius = ROOM_RADII.pick_random()
			var left_radius = ROOM_RADII.back() - top_radius + ROOM_RADII.front()
			var top : int = point.y - top_radius
			var bottom : int = point.y + top_radius
			var left : int = point.x - left_radius
			var right : int = point.x + left_radius
			for x in [left, right]:
				for y in [top, bottom]:
					if (x > 0 and y > 0 and x < MAP_WIDTH and y < MAP_HEIGHT) or Map.get_cell_source_id(Vector2i(x, y)) != -1:
						new_points.append(Vector2i(x, y))
			for x in range(left, right + 1):
				for y in range(top, bottom + 1):
					if x > 0 and y > 0 and x < MAP_WIDTH and y < MAP_HEIGHT:
						Map.erase_cell(Vector2i(x, y))
		room_points.append_array(new_points)

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
