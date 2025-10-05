extends Node2D
@export var info : PlayerInfo
@export var weapon_pickup_scene : PackedScene

signal moved

func _ready() -> void:
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")

func move(pos : Vector2) -> void:
	self.global_position = pos
	info.spend_energy(1)
	emit_signal("moved")

func attack(pos : Vector2) -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.global_position == pos:
			var attack_info = info.weapon.get_attack_info()
			info.spend_energy(attack_info["cost"])
			if enemy.info.armor > 1:
				info.tick_durability()
			enemy.info.damage(attack_info)

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
				if info.weapon.name != "Fists":
					var new_weapon = pickup.item
					pickup.item = info.weapon
					info.weapon = new_weapon
				else:
					info.weapon = pickup.item
					pickup.queue_free()
				info.emit_signal("info_changed")
			1:
				info.armor += 2
				pickup.queue_free()
				info.emit_signal("info_changed")

func drop(pos : Vector2):
	var weapon_drop = weapon_pickup_scene.instantiate()
	weapon_drop.item = info.weapon
	info.weapon = info.fists
	owner.add_child(weapon_drop)
	weapon_drop.global_position = pos
	info.emit_signal("info_changed")
