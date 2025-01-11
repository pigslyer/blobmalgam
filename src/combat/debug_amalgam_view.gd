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

func display_actions(abilities: Array[CombatAction]):
	pass
