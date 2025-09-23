extends Info
class_name EnemyInfo

@export var name : String
@export var action : Dictionary[String, int] = {
	"health_damage" : 1,
	"armor_damage" : 1,
	"cost" : 1
}

func print() -> String:
	var string : String = ""
	string += name + "\n"
	string += "health: " + str(health) + "\n"
	string += "armor: " + str(armor) + "\n"
	string += "energy: " + str(energy) + "\n"
	string += "weight: " + str(weight) + "\n"
	return string
