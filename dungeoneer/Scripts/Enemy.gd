extends StaticBody2D
class_name Enemy

@export var base_info : EnemyInfo
@onready var map : TileMapLayer = $"../Map"
@onready var level : Node2D = $"../"
@onready var indicator : Sprite2D = $"Indicator"
@onready var timer : Timer = $"Timer"
var actions : Array[Callable]
var info : EnemyInfo
signal end_turn

func _ready() -> void:
	info = base_info.duplicate()
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")
	info.connect("info_changed", on_info_changed)
	connect("end_turn", indicator.set_visible.bind(false))

func choose_action():
	pass

func take_action(action : Callable, time_step : int):
	if timer.timeout.has_connections():
		timer.timeout.disconnect(timer.timeout.get_connections()[0]["callable"])
	timer.timeout.connect(action)
	timer.start(time_step)

func on_info_changed():
	if info.health <= 0:
		queue_free()

func move(layer : int, obstacles : Array):
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	level.set_astar_obstacles(layer, obstacles)
	var self_id = map.local_to_map(self.global_position)
	var player_id = map.local_to_map(player.global_position)
	var path = get_parent().astar_layers[layer].get_point_path(self_id, player_id, true)
	level.clear_astar_obstacles(layer, obstacles)
	if path.size() > 1:
		self.global_position = path[1]
		info.spend_energy(info.weight)
	
	choose_action()
