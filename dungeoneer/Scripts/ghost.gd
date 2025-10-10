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
		var path_to_player = get_grid_path(["enemy", "pickup", "player"], map.local_to_map(last_player_position), true)
		var displacement = abs(player.global_position - global_position)
		if displacement.x <= level.info.TILE_SIZE and displacement.y <= level.info.TILE_SIZE and info.energy >= info.action["cost"]:
			take_action(attack, 0.7)
			player.info.max_health -= info.action["drain"]
			player.info.health = mini(player.info.health, player.info.max_health)
		elif path_to_player.size() < info.energy - 2:
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.7)
		elif info.energy >= info.action["cost"]:
			var direction = global_position.direction_to(last_player_position)
			var target_position = global_position - direction * level.info.TILE_SIZE * info.energy
			take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(target_position)), 0.7)
		else:
			emit_signal("end_turn")
	elif info.energy >= info.action["cost"]:
		take_action(move.bind(["enemy", "pickup", "player"], map.local_to_map(last_player_position)), 0.7)
	else:
		emit_signal("end_turn")
