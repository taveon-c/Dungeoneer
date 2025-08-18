extends Node2D
@onready var Hints = $"../Hints"
@export var stats : Stats
@export var weapon : Weapon
var health : int
var energy : int
var weight : int
var is_moving : bool
var is_action : bool

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy
	weight = 1

func move(dir : Vector2) -> void:
	self.global_position = self.global_position + dir * 16
	energy -= 1

func attack(attack_info : Dictionary) -> void:
	var state = get_world_2d().get_direct_space_state()
	var query = PhysicsPointQueryParameters2D.new()
	for space in attack_info["spaces"]:
		query.position = space
		var result = state.intersect_point(query)
		if result:
			if result.front()["collider"].is_in_group("enemy"):
				result.front()["collider"].health -= attack_info["damage"]
				print("Enemy Health: " + str(result.front()["collider"].health))
	energy -= attack_info["cost"]
