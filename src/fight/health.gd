class_name ExportedAmalgamHealth;
extends ReferenceRect

signal blob_health_hovered(blob_index: int, state: bool);
signal blob_health_clicked(blob_index: int);

@export var _global: TextureProgressBar;
@export var _limbs_container: VBoxContainer

func _ready():
	for i in _limbs_container.get_child_count():
		var health_bar: TextureProgressBar = _limbs_container.get_child(i);
		
		health_bar.gui_input.connect(func(ev): _health_bar_gui_input(ev, i));
		health_bar.mouse_entered.connect(func(): blob_health_hovered.emit(i, true));
		health_bar.mouse_entered.connect(func(): blob_health_hovered.emit(i, false));

func update_health_instant(amalgam: Amalgam) -> void:
	_global.value = amalgam.current_global_health() / amalgam.total_global_health();
	
	for limb_health in _limbs_container.get_children():
		limb_health.hide();
	
	for idx in len(amalgam.blobs):
		var progress_bar: TextureProgressBar = _limbs_container.get_child(idx);
		progress_bar.value = amalgam.blobs[idx].health() / Blob.MAX_HEALTH;
		progress_bar.show();

func update_health_slow(amalgam: Amalgam) -> void:
	pass

func _health_bar_gui_input(event: InputEvent, blob_idx: int):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			blob_health_clicked.emit(blob_idx);
