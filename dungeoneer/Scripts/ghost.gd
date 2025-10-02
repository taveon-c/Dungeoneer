extends Enemy

func generate_hints():
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			level.hints.generate_hint(Color.RED, global_position + Vector2(x, y) * level.info.TILE_SIZE)

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
		var distance_to_player = global_position.distance_to(last_player_position)
		var displacement = abs(player.global_position - global_position)
		if distance_to_player < info.energy * level.info.TILE_SIZE:
			var target_position = global_position - global_position.direction_to(last_player_position) * level.info.TILE_SIZE * 2
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(target_position)), 0.7)
	else:
		emit_signal("end_turn")
