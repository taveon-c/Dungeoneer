extends StaticBody2D
class_name Enemy

@export var base_info : EnemyInfo
@onready var map : TileMapLayer = $"../../Map"
@onready var level : Node2D = $"../.."
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
	connect("end_turn", indicator.set_visible.bind(false))

func take_turn():
	var action = actions.pick_random()
	action.call()

func emit_end_turn():
	self.emit_signal("end_turn")

func on_info_changed():
	if info.health <= 0:
		queue_free()
