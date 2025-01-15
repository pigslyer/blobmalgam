extends Node2D
class_name Amalgam_test

var is_dragging: bool = false;
var dragged_body: RigidBody2D = null;
@export var spring_constant: float = 1000.0;
@export var damping: float = 5.0;

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
			start_drag(self.get_node("Blob"));
			modulate = Color(1, 1, 1, 0.5);

func start_drag(node: RigidBody2D) -> void:
	dragged_body = node;
	is_dragging = true;

func stop_drag() -> void:
	is_dragging = false;
	dragged_body = null;

func _on_blob_mouse_entered() -> void:
	pass ;
	# print_debug("Mouse START hovering over blob");

func _on_blob_mouse_exited() -> void:
	pass ;
	# print_debug("Mouse STOP hovering over blob");

func _physics_process(delta: float) -> void:
	if is_dragging and dragged_body:
		var mouse_pos = get_viewport().get_mouse_position();
		var distance = mouse_pos - dragged_body.global_position;
		var velocity = dragged_body.linear_velocity;
		var spring_force = distance * spring_constant;
		var damping_force = -velocity * damping;
		var total_force = (spring_force + damping_force) * 1000 * delta;
		dragged_body.apply_force(total_force);
