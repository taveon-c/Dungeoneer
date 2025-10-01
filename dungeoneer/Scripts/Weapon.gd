extends Item
class_name Weapon

@export var name : String
@export_range(0, 99) var range : int
@export_range(0, 99) var health_damage : int 
@export_range(0, 99) var armor_damage : int
@export_range(0, 99) var cost : int
@export_range(0, 99) var weight : int

func action(mouse_position: Vector2, player : Node2D) -> Dictionary:
	var hints : Array[Vector2] = []
	var tile_size = player.level_info.TILE_SIZE
	
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var direction = Vector2(x, y)
			if direction != Vector2.ZERO:
				for step in range(1, range + 1):
					hints.append(player.global_position + direction * tile_size * step)
	
	var spaces : Array[Vector2] = []
	var direction = player.global_position.direction_to(mouse_position).round()
	
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	for step in range(1, range + 1):
		spaces.append(player.global_position + direction * step * tile_size)
	return {
		"spaces" : spaces,
		"hints" : hints,
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
	string += "cost: " + str(cost) + "\n"
	return string
