extends Enemy

func generate_markers(level):
	var hints = []
	var options = []
	for x in range(-info.action["range"], info.action["range"]+1):
		for y in range(-info.action["range"], info.action["range"]+1):
			var cell_offset = Vector2(x, y)
			if not cell_offset == Vector2.ZERO:
				var cell_position = global_position + cell_offset * level.info.TILE_SIZE
				var cell = level.map.local_to_map(cell_position)
				if level.map.get_cell_atlas_coords(cell) == Vector2i(0, 0):
					if level.player.global_position == cell_position:
						options.append(cell_position)
					else:
						hints.append(cell_position)
	level.markers.set_markers(Color.RED, options, hints)

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
