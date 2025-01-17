class_name Utils;
extends Object

static func not_implemented(on: Object) -> void:
	var frame = get_stack();
	
	var last = frame[len(frame) - 1 - 1];
	var caller_func: String = last["function"];
	
	var script: Script = on.get_script();
	var script_name: String = script.resource_name;
	
	push_warning("%s has not implemented %s!" % [script_name, caller_func]);

const BLOB_META = "BLOB_META";
const LIMB_META = "LIMB_META";
static func display_amalgam(tree: Tree, amalgam: Amalgam) -> void:
	tree.clear();
	
	var root := tree.create_item();
	var idx := 1;
	for blob in amalgam.blobs:
		var blob_item := tree.create_item(root);
		blob_item.set_meta(BLOB_META, blob);
		
		var text: String = "Blob %d;   Health: %d" % [idx, blob.health()]
		if blob.stun() > 0:
			text += "    Stun: %d" % blob.stun();
		if blob.poison() > 0:
			text += "    Poison: %d" % blob.poison();
		blob_item.set_text(0, text);
		
		for limb in blob.limbs:
			var limb_item := tree.create_item(blob_item);
			limb_item.set_text(0, limb.limb.tags[Ability.NAME]);
			limb_item.set_tooltip_text(0, str(limb.limb.tags));
			limb_item.set_meta(LIMB_META, limb.limb);

const SELECTABLE_META = "SELECTABLE_META";
const SELECTABLE_SIGNAL_META = "SELECTABLE_SIGNAL";
static func select_on(tree: Tree, available: Array, on_selected: Callable) -> void:
	clear_selection(tree);
	
	var on_selected_lambda = func(item: TreeItem, _column, _selected):
		var is_selectable: bool = item.has_meta(SELECTABLE_META);
		
		if !is_selectable:
			item.deselect(0);
		
		on_selected.call();
	
	tree.set_meta(SELECTABLE_SIGNAL_META, on_selected_lambda);
	tree.multi_selected.connect(on_selected_lambda);
	
	var available_untyped: Array;
	available_untyped.assign(available);
	var items: Array[TreeItem] = [tree.get_root()];
	while len(items) > 0:
		var cur: TreeItem = items.pop_back();
		items.append_array(cur.get_children());
		
		if cur.has_meta(LIMB_META) && available_untyped.find(cur.get_meta(LIMB_META)) != -1:
			cur.set_custom_bg_color(0, Color.RED, true);
			cur.set_meta(SELECTABLE_META, 1);
		
		if cur.has_meta(BLOB_META) && available_untyped.find(cur.get_meta(BLOB_META)) != -1:
			cur.set_custom_bg_color(0, Color.RED, true);
			cur.set_meta(SELECTABLE_META, 1);

static func total_selection(tree: Tree) -> Array:
	var arr: Array = [];
	
	var cur: TreeItem = tree.get_next_selected(null);
	while cur != null:
		if cur.has_meta(BLOB_META):
			arr.append(cur.get_meta(BLOB_META));
		if cur.has_meta(LIMB_META):
			arr.append(cur.get_meta(LIMB_META));
		
		cur = tree.get_next_selected(cur);
	
	return arr;

static func clear_selection(tree: Tree) -> void:
	tree.deselect_all();
	if tree.has_meta(SELECTABLE_SIGNAL_META):
		tree.multi_selected.disconnect(tree.get_meta(SELECTABLE_SIGNAL_META));
		tree.remove_meta(SELECTABLE_SIGNAL_META);
	
	var items: Array[TreeItem] = [tree.get_root()];
	while len(items) > 0:
		var cur: TreeItem = items.pop_back();
		items.append_array(cur.get_children());
		
		cur.clear_custom_bg_color(0);
		cur.remove_meta(SELECTABLE_META);

class LimbOwner:
	var owning_blob: Blob;
	var index_in_blob: int;
static func limb_owner(sought: Limb, blobs: Array[Blob]) -> LimbOwner:
	for blob in blobs:
		var idx := 0;
		for limb in blob.limbs:
			if limb.limb == sought:
				var result := LimbOwner.new();
				result.owning_blob = blob;
				result.index_in_blob = idx;
				return result;
			
			idx += 1;
	
	return null;

static func limb_table() -> Array[Limb]:
	return [
		Normal.leg(),
		Normal.arm(),
		Normal.eyes(),
		Normal.mouth(),
		
		Pixel.leg(),
		Pixel.arm(),
		Pixel.eyes(),
		Pixel.wings(),
		Pixel.mouth(),
		
		Monster.leg(),
		Monster.arm(),
		Monster.eyes(),
		Monster.wings(),
		Monster.mouth(),
		Monster.tail(),
		
		Medieval.leg(),
		Medieval.arm(),
		Medieval.cape(),
		
		Cyber.leg(),
		Cyber.arm(),
		Cyber.eyes(),
		Cyber.jetpack(),
		Cyber.reflex_booster(),
		
		Eldritch.tentacle(),
		Eldritch.eyes(),
		Eldritch.wings(),
		Eldritch.mouth(),
		
		Cute.arm(),
		Cute.leg(),
		Cute.cat_ears(),
		Cute.eyes(),
		Cute.wings(),
		
		Angelic.wings(),
		Angelic.eyes(),
		
		Plant.tentacle(),
		Plant.mouth(),
		Plant.flower(),
	];

static func default_amalgam() -> Amalgam:
	var ret := Amalgam.new();
	var blob := Blob.new();
	ret.blobs.append(blob);
	
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.eyes());
	blob.add_limb(Normal.mouth());
	
	return ret;
