class_name DebugAmalgamView;
extends VBoxContainer

const BLOB_META = "blob_item";
const LIMB_META = "limb_item";
const SELECTABLE_META = "selectable_item";

signal ability_selected(tags: Dictionary);
signal total_selection_updated;

@export var _tree: Tree;
@export var _ability_list: HBoxContainer;

func display_amalgam(amalgam: Amalgam):
	_tree.clear();
	
	var root: TreeItem = _tree.create_item();
	var idx := 0;
	for blob in amalgam.blobs:
		var blob_item: TreeItem = _tree.create_item(root);
		blob_item.set_text(0, "Blob (%s);   Health: %s" % [idx, blob.health()]);
		blob_item.set_meta(BLOB_META, blob);
		
		for limb in blob.limbs:
			var limb_item: TreeItem = _tree.create_item(blob_item);
			limb_item.set_text(0, limb.limb.tags[Ability.NAME]);
			limb_item.set_meta(LIMB_META, limb.limb);
		
		idx += 1;

func display_actions(frames: Array[Amalgam.CombatActionFrame]):
	for child in _ability_list.get_children():
		child.queue_free();
	
	#for frame in frames:
		#print(str(frame.abilities));
	
	var last_frame: Amalgam.CombatActionFrame  = frames[-1];
	for ability in last_frame.abilities:
		var button := Button.new();
		button.add_theme_font_size_override("font_size", 12);
		button.text = "%s\n%s" % [
			ability.get(Ability.NAME, "<missing name>"), 
			ability.get(Ability.DESC, "<missing description>")
		];
		
		_ability_list.add_child(button);
		button.pressed.connect(func(): 
			if !Ability.EFFECT in ability:
				push_warning("ability has no %s:\n%s" % [Ability.EFFECT, ability]);
				return;
			ability_selected.emit(ability));


func set_selectable_blobs(blobs: Array[Blob]) -> void:
	reset_selectable();
	
	var items: Array[TreeItem] = [_tree.get_root()];
	while len(items) > 0:
		var cur: TreeItem = items.pop_back();
		items.append_array(cur.get_children());
		
		if cur.has_meta(BLOB_META) && blobs.find(cur.get_meta(BLOB_META)) != -1:
			cur.set_custom_bg_color(0, Color.RED, true);
			cur.set_meta(SELECTABLE_META, 0);

func set_selectable_limbs(limbs: Array[Limb]) -> void:
	reset_selectable();
	
	var items: Array[TreeItem] = [_tree.get_root()];
	while len(items) > 0:
		var cur: TreeItem = items.pop_back();
		items.append_array(cur.get_children());
		
		if cur.has_meta(LIMB_META) && limbs.find(cur.get_meta(LIMB_META)) != -1:
			cur.set_custom_bg_color(0, Color.RED, true);
			cur.set_meta(SELECTABLE_META, 1);

func reset_selectable():
	_tree.deselect_all();
	
	var items: Array[TreeItem] = [_tree.get_root()];
	while len(items) > 0:
		var cur: TreeItem = items.pop_back();
		items.append_array(cur.get_children());
		
		cur.clear_custom_bg_color(0);
		cur.remove_meta(SELECTABLE_META);

func _on_tree_multi_selected(item: TreeItem, _column: int, _selected: bool) -> void:	
	var is_selectable: bool = item.has_meta(SELECTABLE_META);
	
	if !is_selectable:
		item.deselect(0);
		return;
	
	total_selection_updated.emit();

func total_selection() -> Array:
	var arr: Array = [];
	
	var cur: TreeItem = _tree.get_next_selected(null);
	while cur != null:
		if cur.has_meta(BLOB_META):
			arr.append(cur.get_meta(BLOB_META));
		if cur.has_meta(LIMB_META):
			arr.append(cur.get_meta(LIMB_META));
		
		cur = _tree.get_next_selected(cur);
	
	return arr;
