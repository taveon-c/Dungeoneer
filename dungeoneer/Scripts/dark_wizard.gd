extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"] + 1):
		for y in range(-info.action["range"], info.action["range"] + 1):
			var cell_position = Vector2(x, y) * level.info.TILE_SIZE
			if cell_position.length() <= info.action["range"] * level.info.TILE_SIZE:
				hints.generate_hint(Color.RED, cell_position)

func choose_action():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	var displacement = abs(player.global_position - global_position)
	if info.energy >= info.action["cost"] and global_position.distance_to(player.global_position) <= info.action["range"] * level.info.TILE_SIZE:
		take_action(attack, 1)
	elif info.energy >= info.weight:
		take_action(move.bind(2, ["enemy", "item"]), 0.3)
	else:
		emit_signal("end_turn")

func attack():
	print("Attack")
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	player.info.damage(
			{
				"cut" : info.action["cut"],
				"blunt" : info.action["blunt"]
			}
		)
	info.spend_energy(info.action["cost"])
	
	choose_action()
