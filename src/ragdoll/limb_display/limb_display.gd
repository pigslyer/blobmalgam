class_name LimbDisplay
extends Control

var card: Limb = null;
var image: CompressedTexture2D = null;

signal limb_pressed(which: Limb);

func _enter_tree() -> void:
	if image == null:
		push_warning("BlobDisplay image is null, setting to placeholder");
		return ;
	get_node("Sprite2D").texture = image;

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			# Emitted on all limbs (even dead)
			emit_signal("limb_pressed", self.card);
			# start_drag(self);
			modulate = Color(1, 1, 1, 0.5);
		elif event.is_action_released("click"):
			# stop_drag();
			modulate = Color(1, 1, 1, 1);


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			limb_pressed.emit(card);
