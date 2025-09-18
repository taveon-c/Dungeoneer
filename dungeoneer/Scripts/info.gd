extends Resource
class_name Info

@export var max_health : int
@export var max_energy : int
@export var energy_regen : int = 1
@export var inventory_slots : int = 0
@export var weight : int = 0
@export var weapon : Weapon
@export var armor : Dictionary[Armor.Type, Armor]
var health = 0
var energy = 0

signal info_changed

func _init() -> void:
	health = max_health
	energy = max_energy

func print() -> String:
	var string : String = ""
	string += "Player" + "\n"
	string += "Max Health: " + str(max_health) + "\n"
	string += "Max Energy: " + str(max_energy) + "\n"
	string += "Energy Regen: " + str(energy_regen) + "\n"
	
	var total_weight = weight
	var total_armor = 0
	for type in armor.keys():
		total_weight += armor[type].weight
		total_armor += armor[type].armor
	string += "Weight: " + str(total_weight) + "\n"
	string += "Armor: " + str(total_armor) + "\n"
	
	string += "Health: " + str(health) + "\n"
	string += "Energy: " + str(energy) + "\n"
	
	string += "\n"
	string += weapon.print()
	
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
