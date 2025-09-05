extends Node2D
@export var stats : Stats
@export var weapon : Weapon
@export var weapon_sprite : Sprite2D
@export var weapon_pickup_scene : PackedScene
var is_moving : bool
var is_action : bool

signal moved

func _ready() -> void:
	stats.health = stats.max_health
	stats.energy = stats.max_energy
	stats.emit_signal("stats_changed")
	update_weapon_sprite()

func move(dir : Vector2) -> void:
	self.global_position = self.global_position + dir * 16
	stats.spend_energy(stats.weight)
	emit_signal("moved")

func attack(attack_info : Dictionary) -> void:
	var state = get_world_2d().get_direct_space_state()
	for space in attack_info["spaces"]:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = space
		var result = state.intersect_point(query)
		if result and result.front()["collider"].is_in_group("enemy"):
			attack_info = result.front()["collider"].stats.damage(attack_info)
			if attack_info["cut"] <= 0:
				stats.spend_energy(attack_info["cost"])
				return 
	stats.spend_energy(attack_info["cost"])

func pickup(dir : Vector2):
	var pickup_position = self.global_position + dir * 16
	var state = get_world_2d().get_direct_space_state()
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pickup_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = state.intersect_point(query)
	if result and result.front()["collider"].is_in_group("weapon"):
		var weapon_drop = weapon_pickup_scene.instantiate()
		weapon_drop.weapon = weapon
		owner.add_child(weapon_drop)
		weapon_drop.global_position = result.front()["collider"].global_position
		weapon = result.front()["collider"].weapon
		result.front()["collider"].queue_free()
		update_weapon_sprite()

func update_weapon_sprite():
	weapon_sprite.texture = weapon.texture
