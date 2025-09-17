extends Resource
class_name Info

@export var max_health : int
@export var max_energy : int
@export var energy_regen : int = 1
@export var inventory_slots : int = 0
@export var weight : int = 0
@export var weapon : Weapon
@export var armor : Dictionary[String, Armor]
var health = 0
var energy = 0

signal info_changed

func _init() -> void:
	health = max_health
	energy = max_energy

func print() -> String:
	var string : String = ""
	for property in self.get_property_list():
		if not "script" in property.name and not "resource" in property.name and property.name == property.name.to_lower():
			string = string + property.name + ": " + str(self.get(property.name)) + "\n"
	return string

func damage(attack_info : Dictionary):
	attack_info["cut"] -= armor
	var damage = maxi(attack_info["blunt"] + attack_info["cut"], 0)
	health -= damage
	emit_signal("info_changed")
	return attack_info

func spend_energy(cost : int):
	energy -= cost
	emit_signal("info_changed")

func regen_energy():
	energy += energy_regen
	energy = mini(energy, max_energy)
	emit_signal("info_changed")
