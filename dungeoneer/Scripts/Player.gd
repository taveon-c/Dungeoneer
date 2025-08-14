extends Node2D
@onready var Hints = $"../Hints"
@export var stats : Stats
@export var weapon : Weapon
var health : int
var energy : int
var weight : int

func _ready() -> void:
	health = stats.max_health
	energy = stats.max_energy
	weight = 1
