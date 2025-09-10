extends Enemy

func _init():
	actions = [attack, move]

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	var displacement = player.global_position - global_position
	var direction = displacement.sign()
	if stats.energy >= stats.action["cost"] and abs(displacement.x) <= 16 and abs(displacement.y) <= 16:
		player.stats.spend_energy(stats.action["stun"])
		player.stats.damage(
			{
				"cut" : 0,
				"blunt" : stats.action["blunt"]
			}
		)
		stats.spend_energy(stats.action["cost"])
	else:
		emit_end_turn()

func move():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if stats.energy >= stats.weight:
		var self_id = map.local_to_map(self.global_position)
		var player_id = map.local_to_map(player.global_position)
		var path = get_parent().astar_layers[2].get_point_path(self_id, player_id)
		if path.size() > 1:
			self.global_position = path[1]
			stats.spend_energy(stats.weight)
		else:
			emit_end_turn()
	else:
		emit_end_turn()
