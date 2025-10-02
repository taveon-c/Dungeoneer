extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			level.hints.generate_hint(Color.RED, global_position + Vector2(x, y) * level.info.TILE_SIZE)

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
	var displacement = abs(player.global_position - global_position)
	if info.energy >= info.action["cost"] and displacement.x <= level.info.TILE_SIZE * info.action["range"] and displacement.y <= level.info.TILE_SIZE * info.action["range"]:
		take_action(attack, 1.1)
		player.info.energy -= info.action["stun"]
	elif info.energy > 0 and (displacement.x > 1 or displacement.y > 1):
		take_action(move.bind(["enemy", "pickup"], map.local_to_map(last_player_position)), 0.7)
	else:
		emit_signal("end_turn")
