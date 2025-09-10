extends StaticBody2D
class_name Enemy

@export var base_stats : EnemyStats
@onready var map : TileMapLayer = $"../TileMapLayer"
@onready var level : Node2D = $".."
@onready var info : Label = $"CanvasLayer/Panel/Info"
var actions : Array[Callable]
var stats : EnemyStats
signal end_turn

func _ready() -> void:
	stats = base_stats.duplicate()
	stats.health = stats.max_health
	stats.energy = stats.max_energy
	stats.emit_signal("stats_changed")
	stats.connect("stats_changed", on_stats_changed)
	stats.connect("stats_changed", info.update_info)
	info.update_info()

func take_turn():
	var action = actions.pick_random()
	action.call()

func emit_end_turn():
	self.emit_signal("end_turn")

func on_stats_changed():
	if stats.health <= 0:
		queue_free()

func set_astar_obstacles(groups : Array[String]):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var player = get_tree().get_nodes_in_group("player")[0]
	var weapons = get_tree().get_nodes_in_group("weapon")
	
	for astar_grid in level.astar_layers:
		for enemy in enemies:
			if enemy != self:
				astar_grid.set_point_solid(map.local_to_map(enemy.global_position), true)
		astar_grid.set_point_solid(map.local_to_map(player.global_position), true)
		for weapon in weapons:
			astar_grid.set_point_solid(map.local_to_map(weapon.global_position), true)

func clear_astar_obstacles(groups : Array[String]):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var player = get_tree().get_nodes_in_group("player")[0]
	var weapons = get_tree().get_nodes_in_group("weapon")
	
	for astar_grid in level.astar_layers:
		for enemy in enemies:
			astar_grid.set_point_solid(map.local_to_map(enemy.global_position), false)
		astar_grid.set_point_solid(map.local_to_map(player.global_position), false)
		for weapon in weapons:
			astar_grid.set_point_solid(map.local_to_map(weapon.global_position), false)
