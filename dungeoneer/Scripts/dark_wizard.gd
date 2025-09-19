extends Enemy

func _init() -> void:
	actions = [attack]

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if info.energy >= info.action["cost"] and player.global_position.distance_to(self.global_position) < info.action["range"] * 16:
		player.info.damage(
			{
				"cut" : info.action["cut"],
				"blunt" : info.action["blunt"]
			}
		)
		info.spend_energy(info.action["cost"])
	else:
		move(2, ["player", "enemy", "item"])
