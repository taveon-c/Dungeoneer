extends Sprite2D
@export var stats : Stats
@onready var Player : Sprite2D = $"../../Player"
var health : int
var action_points : int
var move_points : int
var path : Array[Vector2]
var attack : Vector2

func _ready() -> void:
	health = stats.health
	action_points = stats.strength
	move_points = stats.speed

func generate_path():
	var steps : int = randi_range(0, move_points)
	move_points -= steps
	var origin : Vector2 = self.global_position
	for i in steps:
		var direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
		while direction == Vector2.ZERO:
			direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
		origin += direction * 16
		path.append(origin)

func generate_attack():
	if action_points > 0:
		var steps : int = randi_range(0, 3)
		var prediction : Vector2 = Player.global_position
		for i in steps:
			var direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			while direction == Vector2.ZERO:
				direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			prediction += direction * 16
		attack = prediction
		action_points -= 1
	
