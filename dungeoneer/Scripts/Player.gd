extends Node2D
@export var info : Info
@export var hints : Node2D
@export var pickup_scene : PackedScene
@export var level_info : LevelInfo
var is_moving : bool
var is_action : bool

signal moved

func _ready() -> void:
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")

func move(pos : Vector2) -> void:
	self.global_position = pos
	info.spend_energy(info.weight)
	emit_signal("moved")

func attack(attack_info : Dictionary) -> void:
	var state = get_world_2d().get_direct_space_state()
	for space in attack_info["spaces"]:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = space
		var result = state.intersect_point(query)
		if result and result.front()["collider"].is_in_group("enemy"):
			attack_info = result.front()["collider"].info.damage(attack_info)
			if attack_info["cut"] <= 0:
				info.spend_energy(attack_info["cost"])
				return 
	info.spend_energy(attack_info["cost"])

func pickup(pos : Vector2):
	var state = get_world_2d().get_direct_space_state()
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = state.intersect_point(query)
	if result:
		var pickup = result.front()["collider"]
		var item_class = pickup.item.get_script().get_global_name()
		match item_class:
			"Weapon":
				var weapon_drop = pickup_scene.instantiate()
				weapon_drop.item = info.weapon
				owner.add_child(weapon_drop)
				weapon_drop.global_position = pickup.global_position
				info.weapon = pickup.item
				pickup.queue_free()
				info.emit_signal("info_changed")
			"Armor":
				if info.armor[pickup.item.type]:
					var armor_drop = pickup_scene.instantiate()
					armor_drop.item[pickup.item.type] = info.armor[pickup.item.type]
					owner.add_child(armor_drop)
					armor_drop.global_position = pickup.global_position
				info.armor[pickup.item.type] = pickup.item
				pickup.queue_free()
				info.emit_signal("info_changed")
