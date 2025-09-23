extends Resource
class_name Info

@export_range(0, 99) var max_health : int
@export_range(0, 999) var max_energy : int
@export_range(0, 99) var energy_regen : int = 1
@export_range(0, 99) var weight : int = 0
@export_range(0, 99) var armor : int
var health = 0
var energy = 0

signal info_changed

func _init() -> void:
	health = max_health
	energy = max_energy

func damage(attack_info : Dictionary):
	if armor > 0:
		print(attack_info["armor_damage"])
		armor -= attack_info["armor_damage"]
		armor = maxi(0, armor)
	else:
		print(attack_info["health_damage"])
		health -= attack_info["health_damage"]
		
	emit_signal("info_changed")
	return attack_info

func spend_energy(cost : int):
	energy -= cost
	emit_signal("info_changed")

func regen_energy():
	energy += energy_regen
	energy = mini(energy, max_energy)
	emit_signal("info_changed")
