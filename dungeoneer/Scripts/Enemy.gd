extends StaticBody2D
class_name Enemy

@export var base_stats : EnemyStats
@onready var tilemap : TileMapLayer = $"../TileMapLayer"
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
