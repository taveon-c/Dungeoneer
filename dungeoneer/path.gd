extends Node
@onready var Step_Label = $"../Action/Step"
@onready var Origin = $"../Origin"
@onready var Player = $"../Player"

func _on_undo_pressed() -> void:
	if self.get_child_count() > 0:
		var last = self.get_child(self.get_child_count()-1)
		self.remove_child(last)
		last.queue_free()
		Step_Label.text = "Step: " + str(self.get_child_count())
		var move_color = Color.DEEP_SKY_BLUE
		var attack_color = Color.RED
		move_color.a = 0.5
		attack_color.a = 0.5
		if self.get_child_count() == 0:
			Origin.global_position = Player.global_position
		elif last.color == move_color:
			var index = self.get_child_count() - 1
			while self.get_child(index).color == attack_color:
				if index == 0:
					Origin.global_position = Player.global_position
					return
				else:
					index -= 1
			Origin.global_position = self.get_child(index).global_position
