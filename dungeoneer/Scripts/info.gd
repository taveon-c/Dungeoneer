extends Resource
class_name Info

@export_range(0, 99) var max_health : int
@export_range(0, 999) var max_energy : int
@export_range(0, 99) var armor : int
var health = 0
var energy = 0

signal info_changed

func _init() -> void:
	health = max_health
	energy = max_energy

func damage(attack_info : Dictionary):
	if armor > 0:
		armor -= attack_info["armor damage"]
		armor = maxi(0, armor)
	else:
		health -= attack_info["health damage"]
		
	emit_signal("info_changed")
	return attack_info

func spend_energy(cost : int):
	energy -= cost
	emit_signal("info_changed")

func regen_energy():
	energy = max_energy
	emit_signal("info_changed")
