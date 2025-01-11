class_name DebugAmalgamView;
extends VBoxContainer

@export var _tree: Tree;
@export var _ability_list: HBoxContainer;
@export var _log: VBoxContainer;

func display_amalgam(amalgam: Amalgam):
	_tree.clear();
	var root: TreeItem = _tree.create_item();

	var idx := 0;
	for blob in amalgam.blobs:
		var blob_item: TreeItem = _tree.create_item(root);
		blob_item.set_text(0, "blob (%s)" % idx);
		blob_item.set_text(1, "health: %s" % blob.health);
		
		for limb in blob.limbs:
			var limb_item: TreeItem = _tree.create_item(blob_item);
			limb_item.set_text(0, limb.limb.debug_name());
		
		idx += 1;

func display_actions(actions: Array[Amalgam.CombatActionFrame]):
	for child in _ability_list.get_children():
		child.queue_free();
	
	var last_frame: Amalgam.CombatActionFrame  = actions[-1];
	for ability in last_frame.abilities:
		var panel = PanelContainer.new();
		var vbox = VBoxContainer.new();
		var display_name = Label.new();
		var desc = Label.new();
		
		display_name.text = ability.get(Limb.NAME, "<missing name>");
		desc.text = ability.get(Limb.DESC, "<missing description>");
		
		vbox.add_child(display_name);
		vbox.add_child(desc);
		panel.add_child(vbox);
		_ability_list.add_child(panel);
