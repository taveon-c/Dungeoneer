extends Sprite2D
@export var stats : Stats
@onready var Player : Sprite2D = $"../../Player"
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

func generate_path():
	path.clear()
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
	attack.clear()
	if action_points >= 3:
		var steps : int = randi_range(0, Player.move_points)
		var prediction : Vector2 = Player.global_position
		for i in steps:
			var direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			while direction == Vector2.ZERO:
				direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
			prediction += direction * 16
		attack.append(prediction)
		action_points -= 3
		attack_cost = 3

func turn():
	if health < 1:
		queue_free()
	attack_cost = 0
	action_points += stats.stamina / 2 + 1
	action_points = mini(action_points, stats.strength)
	move_points += stats.stamina / 2 + 1
	move_points = mini(move_points, stats.speed)
	
