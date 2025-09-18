extends Resource
class_name Armor

enum Type {
	HEAD,
	SHOULDERS,
	CHEST,
	ARMS,
	LEGS
}

@export var name : String
@export var armor_type : Type
@export var armor : int
@export var weight : int

func print() -> String:
	var string = ""
	string +=  str(name) + "\n"
	string += "Armor Type: " + str(armor_type) + "\n"
	string += "Armor: " + str(armor) + "\n"
	string += "Weight: " + str(weight) + "\n"
	return string
