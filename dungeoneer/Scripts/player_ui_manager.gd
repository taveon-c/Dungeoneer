extends CanvasLayer
enum State {
	NONE,
	MOVE,
	ATTACK,
	PICKUP
}
var player : StaticBody2D
@export var player_info_label : Label
@export var select_info_label : Label
@export var level : Node2D
@export var current_state: State

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and current_state == State.NONE:
		var mouse_position = get_parent().get_global_mouse_position()
		var items = get_tree().get_nodes_in_group("item")
		var enemies = get_tree().get_nodes_in_group("enemy")
		for item in items:
			if item.global_position == level.map.map_to_local(level.map.local_to_map(mouse_position)):
				select_info_label.display_info(item.item)
				return
		for enemy in enemies:
			if enemy.global_position == level.map.map_to_local(level.map.local_to_map(mouse_position)):
				select_info_label.display_info(enemy.info)
				return
		select_info_label.clear_info()
		

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			player.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy", "item"])
			if player.info.energy >= player.info.weight:
				var options = []
				for option in options:
					player.hints.generate_hint(Color.DEEP_SKY_BLUE, level.map.map_to_local(option))
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					player.hints.generate_hint(Color.DEEP_SKY_BLUE, new_position - Vector2(level.info.TILE_SIZE/2, level.info.TILE_SIZE/2))
					if Input.is_action_just_pressed("select"):
						player.move(new_position)
			level.clear_astar_obstacles(2, ["enemy", "item"])
		State.ATTACK:
			player.hints.clear_hints()
			if player.info.weapon.cost <= player.info.energy:
				var mouse_position : Vector2 = player.get_global_mouse_position()
				var action_info = player.info.weapon.action(mouse_position, player)
				for hint in action_info["hints"]:
					player.hints.generate_hint(Color.RED, hint)
				if mouse_position.distance_to(player.global_position) < (player.info.weapon.range + 1) * level.info.TILE_SIZE:
					for space in action_info["spaces"]:
						player.hints.generate_hint(Color.RED, space - Vector2(level.info.TILE_SIZE/2, level.info.TILE_SIZE/2))
					if Input.is_action_just_pressed("select"):
						player.attack(action_info)
		State.PICKUP:
			player.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy"])
			if player.info.energy >= player.info.weight:
				var options = []
				for option in options:
					player.hints.generate_hint(Color.WHITE, level.map.map_to_local(option))
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					player.hints.generate_hint(Color.WHITE, new_position - Vector2(level.info.TILE_SIZE/2, level.info.TILE_SIZE/2))
					if Input.is_action_just_pressed("select"):
						player.move(new_position)
			level.clear_astar_obstacles(2, ["enemy"])

func set_state(state : State):
	player = get_tree().get_first_node_in_group("player")
	player.hints.clear_hints()
	current_state = state
