extends Enemy

func generate_hints():
	pass

func choose_action():
	if is_player_visible():
		last_player_position = player.global_position
	var displacement = abs(player.global_position - global_position) / level.info.TILE_SIZE
	var in_range = displacement.x <= info.action["range"] and (displacement.y <= info.action["range"] and displacement.x == 0 or displacement.x <= info.action["range"] and displacement.y == 0 or displacement.x == displacement.y)
	if info.energy >= info.action["cost"] and in_range:
		take_action(attack, 1)
	elif info.energy > 0:
		var direction_to_player = global_position.direction_to(last_player_position)
		var target_position = last_player_position + direction_to_player * info.action["range"] * level.info.TILE_SIZE
		take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(target_position)), 0.3)
	else:
		emit_signal("end_turn")
