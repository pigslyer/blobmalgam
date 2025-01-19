class_name ExportedAmalgamHealth;
extends Control

signal blob_health_hovered(blob_index: int, state: bool);
signal blob_health_clicked(blob_index: int);

@export var _global: FightHealthbar;
@export var _limbs_container: VBoxContainer

func _ready():
	for i in _limbs_container.get_child_count():
		var health_bar: FightHealthbar = _limbs_container.get_child(i);
		
		health_bar.gui_input.connect(func(ev): _health_bar_gui_input(ev, i));
		health_bar.mouse_entered.connect(func(): blob_health_hovered.emit(i, true));
		health_bar.mouse_entered.connect(func(): blob_health_hovered.emit(i, false));

func update_health_instant(amalgam: Amalgam) -> void:
	_global.update_instant(amalgam.current_global_health(), amalgam.total_global_health(), 0, 0, 0);
	
	for limb_health in _limbs_container.get_children():
		limb_health.hide();
	
	for idx in len(amalgam.blobs):
		var progress_bar: FightHealthbar = _limbs_container.get_child(idx);
		progress_bar.show();
		var blob: Blob = amalgam.blobs[idx];
		progress_bar.update_instant(blob.health(), Blob.MAX_HEALTH, blob.stun(), blob.poison(), blob.armor());


func update_health_slow(amalgam: Amalgam) -> void:
	_global.update_slow(amalgam.current_global_health(), amalgam.total_global_health(), 0, 0, 0);
	
	for limb_health in _limbs_container.get_children():
		limb_health.hide();
	
	for idx in len(amalgam.blobs):
		var progress_bar: FightHealthbar = _limbs_container.get_child(idx);
		progress_bar.show();
		var blob: Blob = amalgam.blobs[idx];
		progress_bar.update_slow(blob.health(), Blob.MAX_HEALTH, blob.stun(), blob.poison(), blob.armor());


func _health_bar_gui_input(event: InputEvent, blob_idx: int):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			blob_health_clicked.emit(blob_idx);
