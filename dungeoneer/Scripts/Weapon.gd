extends Resource
class_name Weapon

var actions : Dictionary[String, Callable] = {
	"Thrust" : thrust
}
var range : int = 3

func thrust(direction: Vector2) -> Dictionary:
	var spaces : Array[Vector2] = []
	for step in range(1, range + 1):
		spaces.append(direction * step)
	return {
		"spaces" : spaces,
		"cost" : 1,
		"damage" : 3
	}
