class_name AmalgamDisplay
extends Node2D

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
	emit_signal("blob_pressed", blob);
func _on_blob_hovered(blob: Blob, state: bool) -> void:
	emit_signal("blob_hovered", blob, state);
func _on_limb_pressed(limb: Limb) -> void:
	emit_signal("limb_pressed", limb);

func _ready() -> void:
	pass ;

func connect_blob_signals(blob_display: BlobDisplay, amalgam_display: AmalgamDisplay = self) -> void:
	blob_display.connect("blob_pressed", Callable(amalgam_display, "_on_blob_pressed"));
	blob_display.connect("blob_hovered", Callable(amalgam_display, "_on_blob_hovered"));

func connect_limb_signals(limb_display: LimbDisplay, amalgam_display: AmalgamDisplay = self) -> void:
	limb_display.connect("limb_pressed", Callable(amalgam_display, "_on_limb_pressed"));

func _init_blob(blob: Blob) -> BlobDisplay:
	var blob_display := blob_scene.instantiate();
	blob_display.name = name + "_blob_" + str(blob.get_instance_id());
	# blob_display.image = preload("res://src/ragdoll/placeholder/blob.png");
	blob_display.card = blob;
	# blob_display.position
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

	for blob in amalgam.blobs:
		var blob_display := _init_blob(blob);
		add_child(blob_display);
		connect_blob_signals(blob_display);
		blob_display.freeze = true;

		var limbs_node = blob_display.get_node("Limbs");
		for positioned_limb in blob.limbs:
			var limb_display := _init_limb(positioned_limb);
			limbs_node.add_child(limb_display);
			connect_limb_signals(limb_display);
			limb_display.freeze = true;
			

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
	animation_finished.emit();
	pass ;

## Elements of limbs_or_blobs are either limbs or blobs.
## EffectKind should be set to all limbs_or_blobs in array, or disabled if array is empty.
## A single limb or blob should support multiple effects at once
## You shouldn't assume that all limbs or blobs received are on displayed amalgam.
func effect(kind: EffectKind, limbs_or_blobs: Array) -> void:
	pass ;

func _physics_process(delta: float) -> void:
	pass ;
