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
var is_moving = false
var is_action = false

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

func _on_turn_pressed() -> void:
	for enemy in Enemies.get_children():
		enemy.generate_action()
	
	Main.visible = false
	Movement.visible = false
	Action.visible = false
	Movement.is_moving = false
	Action.action = ""
	Origin.visible = false
	Info.update_points()
	
	generate_hints()
	
	timer.start()

func generate_hints():
	Hints.clear_hints()
	
	for step in Player.path:
		Hints.generate_hint(Color.DEEP_SKY_BLUE, step)
	if Player.action.has("spaces") and is_action:
		for space in Player.action["spaces"]:
			if Player.path.size() > 0:
				Hints.generate_hint(Color.RED, space + Player.path.back())
			else:
				Hints.generate_hint(Color.RED, space + Player.global_position)
	
	for enemy in Enemies.get_children():
		for step in enemy.path:
			Hints.generate_hint(Color.CORAL, step)
		for space in enemy.attack:
			Hints.generate_hint(Color.PURPLE, space)

func _on_timer_timeout() -> void:
	is_moving = false
	if Player.path.size() > 0:
		Player.energy -= 1
		Player.global_position = Player.path.pop_front()
		if Player.path.size() > 0:
			is_moving = true
	for enemy in Enemies.get_children():
		if enemy.path.size() > 0:
			enemy.move_points -= 1
			enemy.global_position = enemy.path.pop_front()
			if enemy.path.size() > 0:
				is_moving = true
	if is_moving:
		generate_hints()
	if not is_moving and not is_action:
		is_action = true
		generate_hints()
	elif not is_moving and is_action:
		timer.stop()
		turn += 1
		is_action = false
		
		for enemy in Enemies.get_children():
			for space in enemy.attack:
				if space == Player.global_position:
					Player.health -= enemy.attack_cost
			
			for space in Player.action["spaces"]:
				if space + Player.global_position == enemy.global_position:
					enemy.health -= Player.action["damage"]
			enemy.turn()
		
		Player.turn()
		
		Hints.clear_hints()
		Info.update_points()
		Info.update_turn()
		Main.visible = true
	
