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
