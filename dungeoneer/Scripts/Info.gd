extends CanvasLayer

@onready var Player : Node2D = get_tree().get_first_node_in_group("player")
@onready var Turn : Label = $"Turn Info"
@onready var Points : Label = $"Points Info"
@onready var stats : Label = $"Stats Info"

func _ready() -> void:
	update_points()
	update_stats()

func update_turn():
	if Player.path.size() > 0:
		Turn.text = "Cost: " + str(Player.path.size())
	elif Player.action.has("cost"):
		Turn.text = "Cost: " + str(Player.action["cost"])
	else:
		Turn.text = "Cost: " + str(0)

func update_points():
	Points.text = "Energy: " + str(Player.energy) + "\n"
	Points.text += "Health: " + str(Player.health)

func update_stats():
	stats.text = "Max Health: " + str(Player.stats.max_health) + "\n"
	stats.text += "Max Energy: " + str(Player.stats.max_energy) + "\n"
	stats.text += "Energy Regen: " + str(Player.stats.energy_regen)
