extends Node2D
class_name PlayerAmalgam

###########################
# (shiloh) shit what i need

## emitted when one of the animations request to play has finished
signal animation_finished;

# these should be emitted on all blobs, even dead ones
signal blob_pressed(which: Blob);
signal blob_hovered(which: Blob, state: bool);

signal limb_pressed(which: Limb);

## amalgam should grow up and left/right
## this will also be called when the amalgam's state changes and i want it to update
## e.g. a blob has died (grey it and all its limbs out), a limb has been changed
func display_amalgam(amalgam: Amalgam) -> void:
	pass

enum IdleKinds {
	None, ## no passive movement animations, used for selecting stuff
	Standing, ## blob is standing, probably doing some swaying, breathing, what have you
}

func idle(kind: IdleKinds) -> void:
	pass

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
	pass

enum EffectKind {
	Selectable,
	Selected,
}
## Elements of limbs_or_blobs are either limbs or blobs.
## EffectKind should be set to all limbs_or_blobs in array, or disabled if array is empty.
## A single limb or blob should support multiple effects at once
## You shouldn't assume that all limbs or blobs received are on displayed amalgam.
func effect(kind: EffectKind, limbs_or_blobs: Array) -> void:
	pass


###########################


var is_dragging: bool = false;
var dragged_body: RigidBody2D = null;
@export var spring_constant: float = 1000.0;
@export var damping: float = 5.0;

func _ready() -> void:
	# get_viewport().set_physics_object_picking_sort(true);
	# get_viewport().set_physics_object_picking_first_only(true);
	pass ;

func _physics_process(delta: float) -> void:
	if is_dragging and dragged_body:
		var mouse_pos = get_viewport().get_mouse_position();
		var distance = mouse_pos - dragged_body.global_position;
		var velocity = dragged_body.linear_velocity;
		var spring_force = distance * spring_constant;
		var damping_force = -velocity * damping;
		var total_force = (spring_force + damping_force) * 1000 * delta;
		dragged_body.apply_force(total_force);
