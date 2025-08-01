extends Resource
class_name Weapon

var actions : Dictionary[String, Callable] = {
	"Thrust" : thrust
}
var range : float = 5

func thrust(direction : Vector2, position : Vector2i) -> Dictionary:
	var cells : Array[Vector2] = []
	var target_position = (position + Vector2i((direction * range).ceil()))
	
	var dx = target_position.x - position.x
	var dy = target_position.y - position.y
	var p = 2 * dy - dx
	var x = position.x
	var y = position.y

	while x < target_position.x:
		x+=1
		if (p < 0) :
			p += 2 * dy
		else:
			y+=1
		p += 2 * (dy - dx)
		cells.append(Vector2i(x, y) * 16)
	
	return {
		"spaces" : cells
	}
