extends Node2D
@export var base_stats : Stats
@export var weapon : Weapon
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
	attack_info["cut"] -= stats.armor
	var damage = maxi(attack_info["blunt"] + attack_info["cut"], 0)
	stats.health -= damage
	print("Enemy health: " + str(stats.health))
	if stats.health <= 0:
		print("ENEMY DEAD")
		queue_free()
	return attack_info

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= weapon.cost and player.global_position.distance_to(self.global_position) < weapon.range * 16:
		player.damage(
			{
				"cut" : weapon.cut,
				"blunt" : weapon.blunt
			}
		)
		self.stats.energy -= weapon.cost
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
			stats.energy -= stats.weight
		else:
			self.emit_signal("end_turn")
	else:
		self.emit_signal("end_turn")

func regen():
	stats.energy += stats.energy_regen
	stats.energy = mini(stats.energy, stats.max_energy)
