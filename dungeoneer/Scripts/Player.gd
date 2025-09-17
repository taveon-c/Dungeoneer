extends Node2D
@export var info : Info
@export var weapon : Weapon
@export var weapon_sprite : Sprite2D
@export var hints : Node2D
@export var weapon_pickup_scene : PackedScene
@export var level_info : LevelInfo
var is_moving : bool
var is_action : bool

signal moved

func _ready() -> void:
	info.health = info.max_health
	info.energy = info.max_energy
	info.emit_signal("info_changed")
	update_weapon_sprite()

func move(dir : Vector2) -> void:
	self.global_position = self.global_position + dir * level_info.TILE_SIZE
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

func pickup(dir : Vector2):
	var pickup_position = self.global_position + dir * level_info.TILE_SIZE
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
