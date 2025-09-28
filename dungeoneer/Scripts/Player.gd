extends Node2D
@export var info : PlayerInfo
@export var pickup_scene : PackedScene
@export var level_info : LevelInfo
var hints : Node2D
var is_moving : bool
var is_action : bool

signal moved

func _ready() -> void:
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")

func move(pos : Vector2) -> void:
	self.global_position = pos
	info.spend_energy(1)
	emit_signal("moved")

func attack(attack_info : Dictionary) -> void:
	info.spend_energy(attack_info["cost"])
	var state = get_world_2d().get_direct_space_state()
	for space in attack_info["spaces"]:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = space
		var result = state.intersect_point(query)
		if result and result.front()["collider"].is_in_group("enemy"):
			attack_info = result.front()["collider"].info.damage(attack_info)
			return 

func pickup(pos : Vector2):
	var state = get_world_2d().get_direct_space_state()
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = state.intersect_point(query)
	if result:
		var pickup = result.front()["collider"]
		match pickup.item.type:
			0:
				var weapon_drop = pickup_scene.instantiate()
				weapon_drop.item = info.weapon
				owner.add_child(weapon_drop)
				weapon_drop.global_position = pickup.global_position
				info.weapon = pickup.item
				pickup.queue_free()
				info.emit_signal("info_changed")
			1:
				info.armor += 1
				pickup.queue_free()
				info.emit_signal("info_changed")
