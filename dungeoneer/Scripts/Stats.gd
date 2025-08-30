extends Resource
class_name Stats

@export var max_health : int = 1
@export var armor : int = 1
@export var max_energy : int = 1
@export var energy_regen : int = 1
@export var inventory_slots : int = 0
@export var weight : int = 0
var health = max_health
var energy = max_energy

func print() -> String:
	var string : String = ""
	for property in self.get_property_list():
		if not "script" in property.name and not "resource" in property.name and property.name == property.name.to_lower():
			string = string + property.name + ": " + str(self.get(property.name)) + "\n"
	return string
