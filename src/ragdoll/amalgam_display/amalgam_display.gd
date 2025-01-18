class_name AmalgamDisplay
extends Node2D

@onready var card: Amalgam = null;

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

# Called when redraw needed (state change, e.g. blob has died, limb has changed)
func display_amalgam(amalgam: Amalgam) -> void:
	print_debug("display_amalgam called, will redraw: ", amalgam);

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
