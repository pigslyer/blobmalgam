class_name UpgradeScreen
extends Control

signal finished;

@onready var display: AmalgamDisplay = %Player;
@onready var count: Label = %CountLabel;
var new_items := []
var current_ix := 0;
var preview_display: Control = null;


func upgrade(amalgam: Amalgam, new_blobs_or_limbs: Array) -> void:
	display.display_amalgam(amalgam);
	new_items = new_blobs_or_limbs;
	%CountLabel.text = "%d/%d body parts upgraded" % [current_ix, len(new_items)];
	current_ix = 0;
	setup();

func setup() -> void:
	var new_item = new_items[current_ix];
	%NewBlobDisplay.visible = false;
	%NewLimbDisplay.visible = false;
	if new_item is Blob:
		preview_display = %NewBlobDisplay;
	elif new_item is Limb:
		preview_display = %NewLimbDisplay;
	preview_display.visible = true;

func process_next_item() -> void:
	if current_ix >= len(new_items):
		finished.emit();
		return ;
	
	# %CountLabel.text = "o"
	%CountLabel.text = "%d/%d body parts upgraded" % [current_ix, len(new_items)];
	
	var new_item = new_items[current_ix];
	%NewBlobDisplay.visible = false;
	%NewLimbDisplay.visible = false;
	if new_item is Blob:
		preview_display = %NewBlobDisplay;
	elif new_item is Limb:
		preview_display = %NewLimbDisplay;
	preview_display.visible = true;
	current_ix += 1;


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if preview_display != null:
			preview_display.position = event.position;
	elif event is InputEventMouseButton:
		if preview_display == null:
			return ;
		if event.is_action_pressed("click"):
			preview_display.modulate = Color(1, 1, 1, 0.5);
			return ;
		elif event.is_action_released("click"):
			preview_display.modulate = Color(1, 1, 1, 1);
			process_next_item();
			return ;
