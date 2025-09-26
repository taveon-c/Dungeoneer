extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			level.hints.generate_hint(Color.RED, global_position + Vector2(x, y) * level.info.TILE_SIZE)

func choose_action():
	var displacement = abs(player.global_position - global_position)
	if info.energy >= info.action["cost"] and displacement.x <= level.info.TILE_SIZE * info.action["range"] and displacement.y <= level.info.TILE_SIZE * info.action["range"]:
		take_action(attack, 1.1)
	elif info.energy >= info.weight and (displacement.x > level.info.TILE_SIZE * info.action["range"] or displacement.y > level.info.TILE_SIZE * info.action["range"]):
		take_action(move.bind(2, ["enemy", "pickup"]), 0.7)
	else:
		emit_signal("end_turn")
