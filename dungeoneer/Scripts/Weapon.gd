extends Resource
class_name Weapon

@export var name : String
@export var range : int = 1
@export var cut : int = 0
@export var blunt : int = 1
@export var cost : int = 0

func action(mouse_position: Vector2, player : Node2D) -> Dictionary:
	var hints : Array[Vector2] = []
	var tile_size = player.level_info.TILE_SIZE
	
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var direction = Vector2(x, y)
			if direction != Vector2.ZERO:
				for step in range(1, range + 1):
					hints.append(player.global_position + direction * tile_size * step - Vector2(tile_size/2, tile_size/2))
	
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
		"cut" : cut,
		"blunt" : blunt
	}

func print() -> String:
	var string = ""
	string +=  str(name) + "\n"
	string += "Range: " + str(range) + "\n"
	string += "Cut: " + str(cut) + "\n"
	string += "Blunt: " + str(blunt) + "\n"
	string += "Cost: " + str(cost) + "\n"
	return string
