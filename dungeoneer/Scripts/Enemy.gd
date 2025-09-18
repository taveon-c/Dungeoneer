extends StaticBody2D
class_name Enemy

@export var base_info : EnemyInfo
@onready var map : TileMapLayer = $"../../Map"
@onready var level : Node2D = $"../.."
@onready var info_label : Label = $"CanvasLayer/Panel/Info"
@onready var indicator : Sprite2D = $"Indicator"
var actions : Array[Callable]
var info : EnemyInfo
signal end_turn

func _ready() -> void:
	info = base_info.duplicate()
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")
	info.connect("info_changed", on_info_changed)
	info.connect("info_changed", info_label.update_info)
	connect("end_turn", indicator.set_visible.bind(false))
	info_label.update_info()

func take_turn():
	var action = actions.pick_random()
	action.call()

func emit_end_turn():
	self.emit_signal("end_turn")

func on_info_changed():
	if info.health <= 0:
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
