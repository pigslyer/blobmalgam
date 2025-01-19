class_name UpgradeScreen
extends Control

signal finished;

@onready var display: AmalgamDisplay = %Player;
@onready var count: Label = %CountLabel;
@onready var origin: Control = %Origin;

var new_items := []
var current_ix := 0;
var preview_display: Control = null;
var is_active := false;


func upgrade(amalgam: Amalgam, new_blobs_or_limbs: Array) -> void:
	is_active = true;
	display.display_amalgam(amalgam);
	display.card = amalgam;
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

func process_next_item(gl_pos: Vector2) -> void:
	if current_ix >= len(new_items):
		is_active = false;
		finished.emit();
		return ;
	
	# %CountLabel.text = "o"
	%CountLabel.text = "%d/%d body parts upgraded" % [current_ix, len(new_items)];
	
	var new_item = new_items[current_ix];
	%NewBlobDisplay.visible = false;
	%NewLimbDisplay.visible = false;
	if new_item is Blob:
		preview_display = %NewBlobDisplay;
		display.card.blobs.push_back(new_item);
		var link := Amalgam.Link.new();
		link.from_idx = 0;
		link.to_idx = current_ix;
		link.from_local_pos = Vector2.ZERO;
		link.to_local_pos = gl_pos - origin.global_position;
		display.card.links.push_back(link);
	elif new_item is Limb:
		preview_display = %NewLimbDisplay;
		# preview_display.image = new_item["blob_images"];
		var positioned_limb = PositionedLimb.new();
		positioned_limb.limb = new_item;
		positioned_limb.position = Vector2.ZERO;
		display.card.blobs[display.card.blobs.size() - 1].limbs.push_back(positioned_limb);
	preview_display.visible = true;
	display.display_amalgam(display.card);
	current_ix += 1;


func _input(event: InputEvent) -> void:
	if is_active == false:
		return ;
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
			process_next_item(event.global_position);
			return ;
