extends Info
class_name EnemyInfo

@export var name : String
@export var action : Dictionary[String, int] = {
	"health damage" : 1,
	"armor damage" : 1,
	"cost" : 1
}

func print() -> String:
	var string : String = ""
	string += name + "\n"
	string += "health: " + str(health) + "\n"
	string += "armor: " + str(armor) + "\n"
	string += "energy: " + str(energy) + "\n\n"
	
	string += "Action\n"
	for stat in action.keys():
		string += stat + ": " + str(action[stat]) + "\n"
	
	return string
