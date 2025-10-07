extends StaticBody2D
class_name Enemy

@export var base_info : EnemyInfo
@onready var map : TileMapLayer = $"../../Map"
@onready var level : Node2D = $"../.."
@onready var timer : Timer = $"Timer"
var player : Node2D
var last_player_position : Vector2
var info : EnemyInfo
signal end_turn

func _ready() -> void:
	info = base_info.duplicate()
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")
	info.connect("info_changed", on_info_changed)

func generate_hints():
	pass

func choose_action():
	pass

func take_action(action : Callable, time_step : int):
	if timer.timeout.has_connections():
		timer.timeout.disconnect(timer.timeout.get_connections()[0]["callable"])
	if is_player_visible():
		timer.timeout.connect(action)
		timer.start(time_step)
	else:
		action.call()

func is_player_visible():
	var invisible_cells = level.visibility.get_used_cells()
	var curr_cell = map.local_to_map(global_position)
	if curr_cell in invisible_cells:
		return false
	else:
		return true

func on_info_changed():
	if info.health <= 0:
		queue_free()

func get_grid_path(obstacles : Array, target_id : Vector2i, partial : bool):
	level.set_astar_obstacles(obstacles, self)
	var self_id = map.local_to_map(self.global_position)
	var path : Array = level.astar_grid.get_point_path(self_id, target_id, partial)
	level.clear_astar_obstacles(obstacles)
	return path

func move(obstacles : Array, target_id : Vector2i):
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	level.set_astar_obstacles(obstacles, self)
	var self_id = map.local_to_map(self.global_position)
	var path : Array = level.astar_grid.get_point_path(self_id, target_id, true)
	level.clear_astar_obstacles(obstacles)
	if path.size() > 1:
		self.global_position = path[1]
		info.spend_energy(1)
		choose_action()
	else:
		emit_signal("end_turn")

func attack():
	player.info.damage(
			{
				"health damage" : info.action["health damage"],
				"armor damage" : info.action["armor damage"]
			}
		)
	info.spend_energy(info.action["cost"])
	
	choose_action()
