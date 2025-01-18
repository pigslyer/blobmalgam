class_name LimbDisplay
extends RigidBody2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			# Emitted on all limbs (even dead)
			print_debug("Emitting limb_pressed with blob: ", self.name);
			emit_signal("limb_pressed", self);
			# start_drag(self);
			modulate = Color(1, 1, 1, 0.5);
		elif event.is_action_released("click"):
			# stop_drag();
			modulate = Color(1, 1, 1, 1);
