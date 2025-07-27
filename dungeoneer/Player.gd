extends Sprite2D
@onready var Hints = $"../Hints"
@onready var Info = $"../Info"
@export var stats : Stats
var health : int
var action_points : int
var move_points : int
var path : Array[Vector2]
var attack : Array[Vector2]
var attack_cost : int

func _ready() -> void:
	health = stats.vigor
	action_points = stats.strength
	move_points = stats.speed

func update_player_hints():
	Hints.clear_hints()
	for step in path:
		Hints.generate_hint(Color.DEEP_SKY_BLUE, step)
	for space in attack:
		if path.size() > 0:
			Hints.generate_hint(Color.RED, space + path.back())
		else:
			Hints.generate_hint(Color.RED, space + self.global_position)
