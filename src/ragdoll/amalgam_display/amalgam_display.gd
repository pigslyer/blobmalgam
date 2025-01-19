class_name AmalgamDisplay
extends Control

@onready var card: Amalgam = null;
@onready var blob_scene := preload("res://src/ragdoll/blob_display/blob_display.tscn");
@onready var limb_scene := preload("res://src/ragdoll/limb_display/limb_display.tscn");

signal animation_finished;
signal blob_pressed(which: Blob);
signal blob_hovered(which: Blob, state: bool);
signal limb_pressed(which: Limb);

enum IdleKinds {
	None, ## no passive movement animations, used for selecting stuff
	Standing, ## blob is standing, probably doing some swaying, breathing, what have you
}
enum EffectKind {
	Selectable,
	Selected,
}

# Signal passing
func _on_blob_pressed(blob: Blob) -> void:
	print_debug("Emitting blob_pressed with blob: ", self.name);
	blob_pressed.emit(blob);
func _on_blob_hovered(blob: Blob, state: bool) -> void:
	print_debug("Emitting blob_hovered with blob: ", self.name);
	blob_hovered.emit(blob, state);
func _on_limb_pressed(limb: Limb) -> void:
	print_debug("Emitting limb_pressed with limb: ", self.name);
	limb_pressed.emit(limb);
func _on_test_signal(viewport, event, shape_idx) -> void:
	print_debug("Test signal received");
func _ready() -> void:
	pass ;

func connect_blob_signals(blob_display: BlobDisplay, amalgam_display: AmalgamDisplay = self) -> void:
	blob_display.blob_pressed.connect(func(blob: Blob): amalgam_display._on_blob_pressed(blob));
	blob_display.blob_hovered.connect(func(blob: Blob, state: bool): amalgam_display._on_blob_hovered(blob, state));


func connect_limb_signals(limb_display: LimbDisplay, amalgam_display: AmalgamDisplay = self) -> void:
	limb_display.limb_pressed.connect(func(limb: Limb): amalgam_display._on_limb_pressed(limb));

func _init_blob(blob: Blob) -> BlobDisplay:
	var blob_display := blob_scene.instantiate();
	blob_display.name = name + "_blob_" + str(blob.get_instance_id());
	# blob_display.image = preload("res://src/ragdoll/placeholder/blob.png");
	blob_display.card = blob;
	return blob_display;

func _init_limb(limb: PositionedLimb) -> LimbDisplay:
	var limb_display := limb_scene.instantiate();
	limb_display.name = name + "_limb_" + str(limb.get_instance_id());
	limb_display.card = limb.limb;
	limb_display.position = limb.position;
	if limb.limb.tags.has("blob_images"):
		if limb.limb.tags["blob_images"] is Array:
			# TODO: add both for eyes
			limb_display.image = limb.limb.tags["blob_images"][0];
		else:
			limb_display.image = limb.limb.tags["blob_images"];
	return limb_display;

# Called when redraw needed (state change, e.g. blob has died, limb has changed)
func display_amalgam(amalgam: Amalgam) -> void:
	print_debug("display_amalgam called on ", name);
	card = amalgam;
	for child in get_children():
		child.queue_free();

	var blob_y_offset := 0;
	for blob in amalgam.blobs:
		var blob_display := _init_blob(blob);
		blob_y_offset -= blob_display.get_node("Sprite2D").texture.get_height() * blob_display.get_node("Sprite2D").scale.y / 2; # assuming circle
		add_child(blob_display);
		connect_blob_signals(blob_display);
		blob_display.position = Vector2(0, blob_y_offset);
		blob_y_offset -= blob_display.get_node("Sprite2D").texture.get_height() * blob_display.get_node("Sprite2D").scale.y / 2; # add own radius to make space for next one

		var limbs_node = blob_display.get_node("Limbs");
		for positioned_limb in blob.limbs:
			var limb_display := _init_limb(positioned_limb);
			limbs_node.add_child(limb_display);
			connect_limb_signals(limb_display);
			

func idle(kind: IdleKinds) -> void:
	pass ;

## the following formats should exist (atm):
##
##	Ability.ANIM_SLASH: Array[Blob]
##		play a simple slash animation across all blobs marked
##	Ability.ANIM_HEAL: Array[Blob]
##		play a simple heal animation across all blobs marked
##
##	animation should probably be staggered if there are more than 1 targets
##	don't presuppose that you won't get the same blob in one at the same time
##	don't presuppose that i won't start multiple animations at once
##	animations should be in global space i.e. ignoring idle animations
func play_animation(userdata: Dictionary) -> void:
	await get_tree().process_frame;
	animation_finished.emit();
	pass ;

## Elements of limbs_or_blobs are either limbs or blobs.
## EffectKind should be set to all limbs_or_blobs in array, or disabled if array is empty.
## A single limb or blob should support multiple effects at once
## You shouldn't assume that all limbs or blobs received are on displayed amalgam.
func effect(kind: EffectKind, limbs_or_blobs: Array) -> void:
	pass ;
