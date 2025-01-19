class_name BlobDisplay
extends RigidBody2D

var card: Blob = null;
var image: CompressedTexture2D = null;

signal blob_pressed(which: Blob);
signal blob_hovered(which: Blob, state: bool);

func _enter_tree() -> void:
	if image == null:
		push_warning("BlobDisplay image is null, setting to placeholder");
		return ;
	get_node("Sprite2D").texture = image;

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			# Emitted on all blobs (even dead)
			print_debug("Emitting blob_pressed with blob: ", self.name);
			emit_signal("blob_pressed", card);
			# start_drag(self);
			modulate = Color(1, 1, 1, 0.5);
		elif event.is_action_released("click"):
			# stop_drag();
			modulate = Color(1, 1, 1, 1);

func _on_mouse_entered() -> void:
	# Emitted on all blobs (even dead)
	print_debug("Emitting blob_hovered (state: true) with blob: ", self.name);
	emit_signal("blob_hovered", card, true);

func _on_mouse_exited() -> void:
	print_debug("Emitting blob_hovered (state: false) with blob: ", self.name);
	emit_signal("blob_hovered", card, false);
