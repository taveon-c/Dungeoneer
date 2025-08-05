extends Node2D
@export var stats : Stats
@onready var Player : Node2D = $"../../Player"
var health : int
var energy : int
signal end_turn

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy

func take_turn():
	if energy >= 3:
		pass #attack
	if energy > 0:
		pass #move
	if energy <= 0:
		self.emit_signal("end_turn")
	
