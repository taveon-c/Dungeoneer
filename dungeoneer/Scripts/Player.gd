extends Sprite2D
@onready var Hints = $"../Hints"
@onready var Info = $"../Info"
@export var stats : Stats
@export var weapon : Weapon
var health : int
var energy : int
var weight : int
var action : Dictionary
var path : Array[Vector2]

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy
	weight = 1

func update_player_hints():
	Hints.clear_hints()
	if path.size() > 0:
		for step in path:
			Hints.generate_hint(Color.DEEP_SKY_BLUE, step)
	elif action.has("spaces"):
		for space in action["spaces"]:
			Hints.generate_hint(Color.RED, space + self.global_position)

func turn():
	if health < 1:
		print("DEAD")
	
	action.clear()
	energy = mini(energy + stats.energy_regen, stats.max_energy)
