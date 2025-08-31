extends CanvasLayer
enum State {
	NONE,
	MOVE,
	ATTACK
}
var player : StaticBody2D

@export var hints : Node2D
@export var info : Label
@export var map : TileMapLayer
@export var current_state: State

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			hints.clear_hints()
			if player.stats.energy >= player.stats.weight:
				for x in [-1, 0, 1]:
					for y in [-1, 0, 1]:
						var direction = Vector2(x, y)
						if direction != Vector2.ZERO:
							hints.generate_hint(Color.DEEP_SKY_BLUE, player.global_position + direction * 16 - Vector2(8, 8))
				
				var mouse_position = player.get_global_mouse_position()
				var direction = player.global_position.direction_to(mouse_position).round()
				if direction != Vector2.ZERO:
					var new_position = player.global_position + direction * 16
					if map.get_cell_atlas_coords(map.local_to_map(new_position)) == Vector2i(0, 0) and mouse_position.distance_to(player.global_position) < 32:
						hints.generate_hint(Color.DEEP_SKY_BLUE, new_position - Vector2(8, 8))
						if Input.is_action_just_pressed("select"):
							player.move(direction)
		State.ATTACK:
			hints.clear_hints()
			if player.weapon.cost <= player.stats.energy:
				var mouse_position : Vector2 = player.get_global_mouse_position()
				var action_info = player.weapon.action(mouse_position, player)
				for hint in action_info["hints"]:
					hints.generate_hint(Color.RED, hint)
				if mouse_position.distance_to(player.global_position) < player.weapon.range * 16 + 24:
					for space in action_info["spaces"]:
						hints.generate_hint(Color.RED, space - Vector2(8, 8))
					if Input.is_action_just_pressed("select"):
						player.attack(action_info)

func set_state(state : State):
	hints.clear_hints()
	player = get_tree().get_first_node_in_group("player")
	current_state = state
