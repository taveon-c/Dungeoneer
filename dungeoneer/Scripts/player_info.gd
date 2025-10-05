extends Info
class_name PlayerInfo

@export var weapon : Weapon
@export var fists : Weapon

func get_weight() -> int:
	return weapon.weight + armor / 2

func tick_durability():
	if weapon.name != "Fists":
		weapon.durability -= 1
		if weapon.durability < 1:
			weapon = fists
	emit_signal("info_changed")

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
