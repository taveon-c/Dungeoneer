extends Node2D
@export var base_stats : Stats
@export var weapon : Weapon
@onready var tilemap : TileMapLayer = $"../../TileMapLayer"
var astar_grid : AStarGrid2D
var actions : Array[Callable] = [move, attack]
var stats : Stats
signal end_turn

func _ready() -> void:
	stats.health = stats.max_health
	stats.energy = stats.max_energy
	stats.emit_signal("stats_changed")

func take_turn():
	var action = actions.pick_random()
	action.call()

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= weapon.cost and player.global_position.distance_to(self.global_position) < weapon.range * 16:
		player.stats.damage(
			{
				"cut" : weapon.cut,
				"blunt" : weapon.blunt
			}
		)
		stats.spend_energy(weapon.cost)
	else:
		self.emit_signal("end_turn")

func move():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= stats.weight:
		var self_id = tilemap.local_to_map(self.global_position)
		var player_id = tilemap.local_to_map(player.global_position)
		var path = astar_grid.get_point_path(self_id, player_id)
		if path.size() > 1:
			self.global_position = path[1]
			stats.spend_energy(stats.weight)
		else:
			self.emit_signal("end_turn")
	else:
		self.emit_signal("end_turn")
