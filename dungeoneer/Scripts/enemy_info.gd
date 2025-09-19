extends Resource
class_name EnemyInfo

@export var name : String
@export var max_health : int = 0
@export var armor : int = 0
@export var max_energy : int = 0
@export var energy_regen : int = 0
@export var weight : int = 0
@export var action : Dictionary[String, int]
var health : int = 0
var energy : int = 0

signal info_changed

func print() -> String:
	var string : String = ""
	string += name + "\n"
	string += "health: " + str(health) + "\n"
	string += "armor: " + str(armor) + "\n"
	string += "energy: " + str(energy) + "\n"
	string += "weight: " + str(weight) + "\n"
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
