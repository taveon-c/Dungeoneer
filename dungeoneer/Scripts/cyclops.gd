extends Enemy

func generate_hints():
	for x in range(-2, 3):
		for y in range(-2, 3):
			hints.generate_hint(Color.RED, Vector2(x, y) * level.info.TILE_SIZE)

func choose_action():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	var displacement = abs(player.global_position - global_position)
	if info.energy >= info.action["cost"] and displacement.x <= level.info.TILE_SIZE * 2 and displacement.y <= level.info.TILE_SIZE * 2:
		take_action(attack, 1.1)
	elif info.energy >= info.weight:
		take_action(move.bind(2, ["enemy", "item"]), 0.7)
	else:
		emit_signal("end_turn")

func attack():
	print("Attack")
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	player.info.spend_energy(info.action["stun"])
	player.info.damage(
		{
			"cut" : 0,
			"blunt" : info.action["blunt"]
		}
	)
	info.spend_energy(info.action["cost"])
	
	choose_action()
