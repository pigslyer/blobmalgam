class_name BlobDisplay
extends Control

var card: Blob = null;
var image: CompressedTexture2D = null;

signal blob_pressed(which: Blob);
signal blob_hovered(which: Blob, state: bool);

func _enter_tree() -> void:
	if image == null:
		push_warning("BlobDisplay image is null, setting to placeholder");
		return ;
	get_node("Sprite2D").texture = image;

func _process(delta: float) -> void:
	pass ;

func _on_mouse_entered() -> void:
	# Emitted on all blobs (even dead)
	blob_hovered.emit(card, true);

func _on_mouse_exited() -> void:
	blob_hovered.emit(card, false);

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			# Emitted on all blobs (even dead)
			print_debug("Emitting blob_pressed with blob: ", self.name);
			blob_pressed.emit(card);
			# start_drag(self);
			modulate = Color(1, 1, 1, 0.5);
		elif event.is_action_released("click"):
			# stop_drag();
			modulate = Color(1, 1, 1, 1);
