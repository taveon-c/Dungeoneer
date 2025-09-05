extends Resource
class_name Weapon

@export var range : int = 1
@export var cut : int = 0
@export var blunt : int = 1
@export var cost : int = 0
@export var texture : Texture2D

func action(mouse_position: Vector2, Player : Node2D) -> Dictionary:
	var hints : Array[Vector2] = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			var direction = Vector2(x, y)
			if direction != Vector2.ZERO:
				for step in range(1, range + 1):
					hints.append(Player.global_position + direction * 16 * step - Vector2(8, 8))
	
	var spaces : Array[Vector2] = []
	var direction = Player.global_position.direction_to(mouse_position).round()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	for step in range(1, range + 1):
		spaces.append(Player.global_position + direction * step * 16)
	return {
		"spaces" : spaces,
		"hints" : hints,
		"cost" : cost,
		"cut" : cut,
		"blunt" : blunt
	}
