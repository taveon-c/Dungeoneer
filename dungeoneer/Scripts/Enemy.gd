extends Node2D
@export var base_stats : Stats
@onready var stats = base_stats.duplicate()
@onready var hints : Node = $"../../Hints"
@onready var tilemap : TileMapLayer = $"../../TileMapLayer"
var astar_grid : AStarGrid2D
var actions : Array[Callable] = [move, attack]
signal end_turn

func _ready() -> void:
	stats.health = stats.max_health
	stats.energy = stats.max_energy

func take_turn():
	hints.clear_hints()
	var action = actions.pick_random()
	action.call()

func damage(attack_info : Dictionary):
	stats.health -= attack_info["damage"]
	print("Enemy health: " + str(stats.health))
	if stats.health <= 0:
		print("ENEMY DEAD")
		queue_free()

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= 3 and player.global_position.distance_to(self.global_position) < 50:
		stats.energy -= 3
		hints.generate_hint(Color.RED, player.global_position)
		player.health -= 1
		if player.health < 1:
			print("dead")
	else:
		self.emit_signal("end_turn")

func move():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= 1:
		var self_id = tilemap.local_to_map(self.global_position)
		var player_id = tilemap.local_to_map(player.global_position)
		var path = astar_grid.get_point_path(self_id, player_id)
		if path.size() > 1:
			self.global_position = path[1]
			stats.energy -= 1
		else:
			self.emit_signal("end_turn")
	else:
		self.emit_signal("end_turn")

func regen():
	stats.energy += stats.energy_regen
	stats.energy = mini(stats.energy, stats.max_energy)
