extends Area2D

var weapon : Weapon

func _ready() -> void:
	get_child(1).texture = weapon.texture
	
