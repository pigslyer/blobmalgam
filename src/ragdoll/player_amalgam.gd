extends Node2D
class_name PlayerAmalgam

var is_dragging: bool = false;
var dragged_body: RigidBody2D = null;
@export var drag_force_multiplier: float = 0.5;

func _ready() -> void:
	# get_viewport().set_physics_object_picking_sort(true);
	# get_viewport().set_physics_object_picking_first_only(true);
	pass ;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_released("click"):
			stop_drag();
			modulate = Color(1, 1, 1, 1);

func _on_blob_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			start_drag();
			modulate = Color(1, 1, 1, 0.5);

func start_drag() -> void:
	var mouse_pos = get_viewport().get_mouse_position();
	var space_state = get_world_2d().direct_space_state;
	var parameters = PhysicsPointQueryParameters2D.new();
	parameters.set_position(mouse_pos);
	var result = space_state.intersect_point(parameters, 1)[0];
	is_dragging = true;
	dragged_body = result.collider as RigidBody2D;

func stop_drag() -> void:
	is_dragging = false;
	dragged_body = null;

func _on_blob_mouse_entered() -> void:
	pass ;
	# print_debug("Mouse START hovering over blob");

func _on_blob_mouse_exited() -> void:
	pass ;
	# print_debug("Mouse STOP hovering over blob");

func _process(delta: float) -> void:
	if is_dragging and dragged_body:
		# print_debug("applying force to dragged body");
		var mouse_pos = get_viewport().get_mouse_position();
		var force = (mouse_pos - dragged_body.global_position) * drag_force_multiplier;
		dragged_body.apply_central_impulse(force);
