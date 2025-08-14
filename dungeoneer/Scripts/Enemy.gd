extends Node2D
@export var stats : Stats
@onready var Hints : Node = $"../../Hints"
var health : int
var energy : int
var actions : Array[Callable] = [emit_signal.bind("end_turn"), attack, move]
signal end_turn

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy

func take_turn():
	Hints.clear_hints()
	var action = actions.pick_random()
	action.call()

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if energy >= 3 and player.global_position.distance_to(self.global_position) < 50:
		energy -= 3
		Hints.generate_hint(Color.RED, player.global_position)
		player.health -= 2
		if player.health < 1:
			print("dead")
	else:
		self.emit_signal("end_turn")

func move():
	if energy >= 1:
		var direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
		while direction == Vector2.ZERO:
			direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
		self.global_position += direction * 16
		energy -= 1
	else:
		self.emit_signal("end_turn")
