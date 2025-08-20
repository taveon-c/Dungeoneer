extends Node2D
@export var stats : Stats
@onready var hints : Node = $"../../Hints"
@onready var tilemap : TileMapLayer = $"../../TileMapLayer"
var astar_grid : AStarGrid2D
var health : int
var energy : int
var actions : Array[Callable] = [move]
signal end_turn

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy

func take_turn():
	hints.clear_hints()
	var action = actions.pick_random()
	action.call()

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if energy >= 3 and player.global_position.distance_to(self.global_position) < 50:
		energy -= 3
		hints.generate_hint(Color.RED, player.global_position)
		player.health -= 1
		if player.health < 1:
			print("dead")
	else:
		self.emit_signal("end_turn")

func move():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if energy >= 1:
		var self_id = tilemap.local_to_map(self.global_position)
		var player_id = tilemap.local_to_map(player.global_position)
		var path = astar_grid.get_point_path(self_id, player_id)
		if path.size() > 1:
			self.global_position = path[1]
			energy -= 1
		else:
			self.emit_signal("end_turn")
	else:
		self.emit_signal("end_turn")

func regen():
	energy += stats.energy_regen
	energy = mini(energy, stats.max_energy)
