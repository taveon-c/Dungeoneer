extends Node2D
@onready var Hints = $"../Hints"
@onready var Info = $"../Info"
@export var stats : Stats
@export var weapon : Weapon
var is_moving : bool
var is_action : bool

func _ready() -> void:
	stats.health = stats.max_health
	stats.energy = stats.max_energy
	stats.weight = stats.weight
	Info.update_info()

func damage(attack_info : Dictionary):
	stats.health -= attack_info["damage"]
	if stats.health <= 0:
		print("DEAD")

func move(dir : Vector2) -> void:
	self.global_position = self.global_position + dir * 16
	stats.energy -= 1
	Info.update_info()

func attack(attack_info : Dictionary) -> void:
	var state = get_world_2d().get_direct_space_state()
	for space in attack_info["spaces"]:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = space
		var result = state.intersect_point(query)
		if result and result.front()["collider"].is_in_group("enemy"):
			result.front()["collider"].damage(attack_info)
	stats.energy -= attack_info["cost"]
	Info.update_info()

func regen() -> void:
	stats.energy += stats.energy_regen
	stats.energy = mini(stats.energy, stats.max_energy)
	Info.update_info()
