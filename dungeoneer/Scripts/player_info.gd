extends Info
class_name PlayerInfo

@export var weapon : Weapon

func get_weight() -> int:
	return weight + weapon.weight + armor

func print() -> String:
	var string : String = ""
	string += "Player" + "\n"
	string += "health: " + str(health) + "/" + str(max_health) + "\n"
	string += "energy: " + str(energy) + "/" + str(max_energy) + "\n"
	
	string += "weight: " + str(get_weight()) + "\n"
	string += "armor: " + str(armor) + "\n"
	
	string += "\n"
	string += weapon.print()
	
	return string
