extends CanvasLayer

@onready var Player : Sprite2D = $"../Player"
@onready var Turn : Label = $"Turn Info"
@onready var Points : Label = $"Points Info"
@onready var stats : Label = $"Stats Info"

func _ready() -> void:
	update_points()
	update_stats()

func update_turn():
	Turn.text = "Steps: " + str(Player.path.size()) + "\n"
	Turn.text += "Attack: " + str(Player.attack_cost)

func update_points():
	Points.text = "Action Points: " + str(Player.action_points) + "\n"
	Points.text += "Move Points: " + str(Player.move_points) + "\n"
	Points.text += "Health Points: " + str(Player.health)

func update_stats():
	stats.text = "Vigor: " + str(Player.stats.vigor) + "\n"
	stats.text += "Strength: " + str(Player.stats.strength) + "\n"
	stats.text += "Speed: " + str(Player.stats.speed) + "\n"
	stats.text += "Stamina: " + str(Player.stats.stamina)
