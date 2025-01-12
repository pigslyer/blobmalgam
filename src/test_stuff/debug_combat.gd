extends Control

var player_amalgam: Amalgam;
var enemy_amalgam: Amalgam;

@export var player_view: DebugAmalgamView;
@export var enemy_view: DebugAmalgamView;

func _ready() -> void:
	reset_amalgams();

func draw_player_abilities():
	var rng := RandomNumberGenerator.new();
	var actions = player_amalgam.get_combat_display_actions(rng, 5);
	
	player_view.display_actions(actions);

func reset_amalgams():
	player_amalgam = build_amalgam();
	enemy_amalgam = build_amalgam();
	
	player_view.display_amalgam(player_amalgam);
	enemy_view.display_amalgam(enemy_amalgam);

static func build_amalgam() -> Amalgam:
	var amalgam := Amalgam.new();
	
	var blob1 := Blob.new();
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	amalgam.blobs.append(blob1);
	
	blob1 = Blob.new();
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(CuteEyes.new());
	amalgam.blobs.append(blob1);
	
	return amalgam;


class PlayerResolver extends Ability.EffectResolver:
	var player: Amalgam;
	var enemy: Amalgam;
	
	var player_view: DebugAmalgamView;
	var enemy_view: DebugAmalgamView;
	
	@warning_ignore("shadowed_variable")
	func _init(player: Amalgam, enemy: Amalgam, player_view: DebugAmalgamView, enemy_view: DebugAmalgamView):
		self.player = player; self.enemy = enemy;
		self.player_view = player_view; self.enemy_view = enemy_view;
		
		player_view.blobs_selected.connect(_blobs_selected);
		enemy_view.blobs_selected.connect(_blobs_selected);
		player_view.limbs_selected.connect(_limbs_selected);
		enemy_view.limbs_selected.connect(_limbs_selected);
	
	signal blob_selection_fulfilled(selected: Array[Blob]);
	signal limb_selection_fulfilled(selected: Array[Limb]);
	
	func _blobs_selected(blobs: Array[Blob]) -> void:
		blob_selection_fulfilled.emit(blobs);
	
	func _limbs_selected(limbs: Array[Limb]):
		limb_selection_fulfilled.emit(limbs);
	
	func request_blobs(from_selection: Array[Blob], _count: int) -> Array[Blob]:
		enemy_view.set_selectable_blobs(from_selection);
		player_view.set_selectable_blobs(from_selection);
		
		var result: Array[Blob] = await blob_selection_fulfilled;
		
		return result;
	
	func request_limbs(from_selection: Array[Limb], _count: int) -> Array[Limb]:
		enemy_view.set_selectable_limbs(from_selection);
		player_view.set_selectable_limbs(from_selection);
		
		var result: Array[Limb] = await limb_selection_fulfilled;
		
		return result;
	
	func damage_blob(blob: Blob, amount: float, _userdata: Dictionary) -> void:
		blob._health -= amount;
		player_view.display_amalgam(player);
		enemy_view.display_amalgam(enemy);

func _on_player_ability_selected(tags: Dictionary) -> void:
	var resolver := PlayerResolver.new(player_amalgam, enemy_amalgam, player_view, enemy_view);
	var effector := Ability.Effector.new(resolver, player_amalgam, enemy_amalgam, tags);
	
	await tags[Ability.EFFECT].call(effector);
	await get_tree().process_frame;
	
	player_view.display_amalgam(player_amalgam);
	enemy_view.display_amalgam(enemy_amalgam);
