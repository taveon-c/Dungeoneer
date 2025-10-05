extends Item
class_name Weapon

@export var name : String
@export_range(0, 99) var range : int
@export_range(0, 99) var health_damage : int 
@export_range(0, 99) var armor_damage : int
@export_range(0, 99) var cost : int
@export_range(0, 99) var weight : int
@export_range(0, 99) var durability : int

func generate_hints(level : Node2D):
	level.hints.clear_hints()
	var player_pos = level.player.global_position
	var player_cell = level.map.local_to_map(player_pos)
	var enemies = level.get_tree().get_nodes_in_group("enemy")
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var direction = Vector2(x, y)
			if direction != Vector2.ZERO:
				for step in range(1, range + 1):
					var cell = player_cell + Vector2i(direction * step)
					var cell_pos = level.map.map_to_local(cell)
					if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
						level.hints.generate_hint(Color.RED, cell_pos)
						var is_enemy = false
						for enemy in enemies:
							if enemy.global_position == cell_pos:
								is_enemy = true
								break
						if is_enemy:
							break
					else:
						break

func get_options(level):
	var options = []
	var player_pos = level.player.global_position
	var player_cell = level.map.local_to_map(player_pos)
	var enemies = level.get_tree().get_nodes_in_group("enemy")
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var direction = Vector2(x, y)
			if direction != Vector2.ZERO:
				for step in range(1, range + 1):
					var cell = player_cell + Vector2i(direction * step)
					var cell_pos = level.map.map_to_local(cell)
					if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
						var is_enemy = false
						for enemy in enemies:
							if enemy.global_position == cell_pos:
								is_enemy = true
								break
						if is_enemy:
							options.append(cell)
							break
					else:
						break
	return options

func get_attack_info() -> Dictionary:
	return {
		"cost" : cost,
		"health damage" : health_damage,
		"armor damage" : armor_damage
	}

func print() -> String:
	var string = ""
	string +=  str(name) + "\n"
	string += "range: " + str(range) + "\n"
	string += "health damage: " + str(health_damage) + "\n"
	string += "armor damage: " + str(armor_damage) + "\n"
	string += "weight: " + str(weight) + "\n"
	string += "durability: " + str(durability) + "\n"
	string += "cost: " + str(cost) + "\n"
	return string
