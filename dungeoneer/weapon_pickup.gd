extends Area2D
class_name WeaponPickup

var weapon : Weapon

func _init(weapon : Weapon):
	self.weapon = weapon

func _ready() -> void:
	$Sprite2D.texture = weapon.texture
	
