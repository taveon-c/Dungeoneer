extends Enemy

func _init():
	actions = [attack]

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	var displacement = player.global_position - global_position
	var direction = displacement.sign()
	if info.energy >= info.action["cost"] and abs(displacement.x) <= 16 and abs(displacement.y) <= 16:
		player.info.spend_energy(info.action["stun"])
		player.info.damage(
			{
				"cut" : 0,
				"blunt" : info.action["blunt"]
			}
		)
		info.spend_energy(info.action["cost"])
	else:
		move(2, ["player", "enemy", "item"])
