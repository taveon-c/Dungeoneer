extends Sprite2D
@onready var Hints = $"../Hints"
@onready var Info = $"../Info"
@export var stats : Stats
@export var weapon : Weapon
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

func turn():
	if health < 1:
		print("DEAD")
	
	action_points += stats.stamina / 2 + 1 - attack_cost
	action_points = mini(action_points, stats.strength)
	attack_cost = 0
	attack.clear()
	
	move_points += stats.stamina / 2 + 1
	move_points = mini(move_points, stats.speed)
