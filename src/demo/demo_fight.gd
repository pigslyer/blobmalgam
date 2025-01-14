extends Control

var player: Amalgam;
var enemy: Amalgam;
@export var player_view: Tree;
@export var enemy_view: Tree;

@export var selection_root: Control;
@export var selection_cancel: Button;
@export var selection_confirm: Button;
@export var selection_count: Label;

func _ready():
	player = generate_player_amalgam();
	display_amalgam(player_view, player);
	
	var rng := RandomNumberGenerator.new();
	var abilities := player.get_combat_display_actions_simult(rng, 5);
	print(abilities);

func _on_regen_pressed() -> void:
	pass # Replace with function body.


func _on_breakdown_pressed() -> void:
	pass # Replace with function body.

static func generate_player_amalgam() -> Amalgam:
	var amalgam := Amalgam.new();
	
	var blob := Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.mouth());
	blob.add_limb(Normal.eyes());
	
	return amalgam;



static func generate_enemy_amalgam() -> Amalgam:
	return null;


const BLOB_META = "BLOB_META";
const LIMB_META = "LIMB_META";
static func display_amalgam(tree: Tree, amalgam: Amalgam) -> void:
	tree.clear();
	
	var root := tree.create_item();
	var idx := 1;
	for blob in amalgam.blobs:
		var blob_item := tree.create_item(root);
		blob_item.set_text(0, "Blob %d;   Health: %d" % [idx, blob.health()]);
		blob_item.set_meta(BLOB_META, blob);
		
		for limb in blob.limbs:
			var limb_item := tree.create_item(blob_item);
			limb_item.set_text(0, limb.limb.tags[Ability.NAME]);
			limb_item.set_tooltip_text(0, str(limb.limb.tags));
			limb_item.set_meta(LIMB_META, limb);
