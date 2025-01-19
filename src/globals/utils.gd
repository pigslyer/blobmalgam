extends Node

# const BLOB_RADIUS = 100; # TODO: should be imported

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
		#Cyber.reflex_booster(),
		
		Eldritch.tentacle(),
		Eldritch.eyes(),
		#Eldritch.wings(),
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


enum EnemyStrength {
	Weak = 0,
	Average = 1,
	Strong = 2,
	Boss = 3,
};

static func generate_enemy(str: EnemyStrength, rng: RandomNumberGenerator) -> Amalgam:
	var amalgam := Amalgam.new();
	var blob_count_range: Array = blob_count()[str];
	var blob_count: int = rng.randi_range(blob_count_range[0], blob_count_range[1]);
	
	# for 0, they're all weak. for average, 1 is weak. for strong, 2 are average. for boss, 3 are strong.
	var weaken_blob_after: int = blob_count - str;
	var previous_blob_pos := Vector2.ZERO;
	var current_blob_pos := Vector2.ZERO;
	for blob in blob_count:
		var generated_blob := Blob.new();
		
		var blob_str: int = str;
		if weaken_blob_after < blob:
			blob_str -= 1;
		
		var limb_count_range: Array = limb_count()[blob_str];
		var limb_count: int = rng.randi_range(limb_count_range[0], limb_count_range[1]);
		
		var weaken_limb_after: int = limb_count - str;
		for limb in limb_count:
			var limb_str: int = str;
			if weaken_limb_after < limb:
				limb_str -= 1;
			
			var limb_tier: Array = limb_tiers()[limb_str];
			var chosen_limb: Limb = limb_tier[rng.randi() % len(limb_tier)];
			
			generated_blob.add_limb(chosen_limb);
		
		amalgam.blobs.append(generated_blob);

		if blob == 0:
			continue ;

		var angle := rng.randf_range(-PI, 0);
		var direction = Vector2(cos(angle), sin(angle)).normalized();
		current_blob_pos = previous_blob_pos + direction * (AmalgamDisplay.BLOB_RADIUS * 2);

		var link = Amalgam.Link.new()
		link.from_idx = blob - 1;
		link.from_local_pos = previous_blob_pos;
		link.to_idx = blob;
		link.to_local_pos = current_blob_pos;
		amalgam.links.append(link)

		previous_blob_pos = current_blob_pos;
	
	if str == EnemyStrength.Weak:
		for blob in amalgam.blobs:
			blob._health *= 0.3;
	
	return amalgam;

static func blob_count() -> Dictionary:
	return {
		EnemyStrength.Weak: [2, 2],
		EnemyStrength.Average: [1, 3],
		EnemyStrength.Strong: [2, 5],
		EnemyStrength.Boss: [4, 6],
	}

static func limb_count() -> Dictionary:
	return {
		EnemyStrength.Weak: [1, 2],
		EnemyStrength.Average: [2, 3],
		EnemyStrength.Strong: [3, 5],
		EnemyStrength.Boss: [6, 6],
	}

static func limb_tiers() -> Dictionary:
	return {
		EnemyStrength.Weak: [
			Normal.leg(), Normal.leg(), Normal.leg(), Normal.leg(),
			Normal.arm(), Normal.arm(), Normal.arm(), Normal.arm(),
			Normal.eyes(), Normal.eyes(),
			Normal.mouth(), Normal.mouth(),
			
			Pixel.arm(), Pixel.arm(),
			Pixel.leg(), Pixel.leg(),
			Pixel.eyes(),
			Pixel.wings(),
			Pixel.mouth(),
			
			Cute.eyes(),
			Cute.wings(),
			Cute.arm(),
			Cute.cat_ears(),
		],
		
		EnemyStrength.Average: [
			Cute.eyes(),
			Cute.wings(),
			Cute.arm(),
			Cute.cat_ears(),
			Cute.leg(),
			
			Plant.flower(), Plant.flower(),
			Plant.mouth(), Plant.mouth(),
			Plant.tentacle(), Plant.tentacle(),
			
			Monster.arm(), Monster.arm(), Monster.arm(), Monster.arm(),
			Monster.eyes(), Monster.eyes(),
			Monster.leg(), Monster.leg(),
			Monster.wings(), Monster.wings(),
			Monster.tail(), Monster.tail(),
			
			Medieval.arm(), Medieval.arm(),
			Medieval.leg(), Medieval.leg(),
			Medieval.cape(),
			Medieval.crown(),
			Medieval.helmet(),
		],
		
		EnemyStrength.Strong: [
			Cyber.arm(),
			Cyber.arm(),
			Cyber.leg(),
			Cyber.leg(),
			Cyber.eyes(),
			Cyber.eyes(),
			Cyber.jetpack(),
			Cyber.jetpack(),
			#Cyber.reflex_booster(),
			#Cyber.reflex_booster(),
			
			Eldritch.tentacle(), Eldritch.tentacle(),
			Eldritch.mouth(), Eldritch.mouth(),
			#Eldritch.wings(), Eldritch.wings(),
			
			Angelic.eyes(),
			Angelic.wings(),
		],
		
		EnemyStrength.Boss: [
			Eldritch.tentacle(), Eldritch.tentacle(),
			Eldritch.mouth(), Eldritch.mouth(),
			#Eldritch.wings(), Eldritch.wings(),
			
			Angelic.eyes(),
			Angelic.wings(),
			Angelic.eyes(),
			Angelic.wings(),
			Angelic.eyes(),
			Angelic.wings(),
		]
	}

func blobs() -> Array[Texture]:
	return [
		preload("res://assets/normal_blob.png"),
		preload("res://assets/monstrous_blobpng.png"),
		preload("res://assets/plant_blob.png"),
		preload("res://assets/medieval_blob.png"),
		preload("res://assets/eldritch_blob.png"),
		preload("res://assets/cyber - blob.png"),
	];

var _unused_players: Array[AudioStreamPlayer];
func play_sfx(stream: AudioStream) -> void:
	var player: AudioStreamPlayer;
	if len(_unused_players) == 0:
		player = AudioStreamPlayer.new();
		player.bus = "Effects";
		add_child(player);
		# player.finished.connect(func(): Utils._unused_players.append(player));
	else:
		player = _unused_players.pop_back();
	
	player.stream = stream;
	player.play();
