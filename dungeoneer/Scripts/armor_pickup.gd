extends Area2D

var armor : Armor

func _ready() -> void:
	get_child(1).texture = armor.texture
