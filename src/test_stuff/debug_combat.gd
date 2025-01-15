extends Control

var player_amalgam: Amalgam;
var enemy_amalgam: Amalgam;

@export var player_view: DebugAmalgamView;
@export var enemy_view: DebugAmalgamView;

@export var confirm_count: Label;
@export var confirm_button: Button;

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
	blob1.add_limb(Normal.leg());
	blob1.add_limb(Normal.leg());
	blob1.add_limb(Normal.leg());
	amalgam.blobs.append(blob1);
	
	blob1 = Blob.new();
	blob1.add_limb(Normal.leg());
	blob1.add_limb(Normal.leg());
	blob1.add_limb(Normal.leg());
	blob1.add_limb(Cute.eyes());
	amalgam.blobs.append(blob1);
	
	return amalgam;


class PlayerResolver extends Ability.EffectResolver:
	signal selection_finished;
	
	var player: Amalgam;
	var enemy: Amalgam;
	
	var player_view: DebugAmalgamView;
	var enemy_view: DebugAmalgamView;
	
	var _confirm_button: Button;
	var _confirm_label: Label;
	var _selection_count: int = 0;
	
	@warning_ignore("shadowed_variable")
	func _init(player: Amalgam, enemy: Amalgam, player_view: DebugAmalgamView, enemy_view: DebugAmalgamView, confirm_button: Button, confirm_label: Label):
		self.player = player; self.enemy = enemy;
		self.player_view = player_view; self.enemy_view = enemy_view;
		_confirm_button = confirm_button; _confirm_label = confirm_label;
		
		player_view.total_selection_updated.connect(_updated_selection);
		enemy_view.total_selection_updated.connect(_updated_selection);
		_confirm_button.pressed.connect(_confirmed_selection);
	
	func _updated_selection() -> void:
		await _confirm_button.get_tree().process_frame;
		
		var selected_count: int = len(player_view.total_selection()) + len(enemy_view.total_selection());
		
		_confirm_label.text = "%d/%d" % [selected_count, _selection_count];
		_confirm_button.disabled = selected_count > _selection_count;
	
	func _confirmed_selection() -> void:
		selection_finished.emit(player_view.total_selection() + enemy_view.total_selection());
	
	func request_blobs(from_selection: Array[Blob], count: int) -> Array[Blob]:
		enemy_view.set_selectable_blobs(from_selection);
		player_view.set_selectable_blobs(from_selection);
		start_confirm(count);
		
		var result: Array[Blob];
		result.assign(await selection_finished);
		_confirm_button.disabled = true;
		_confirm_label.text = "";
		
		return result;
	
	func request_limbs(from_selection: Array[Limb], count: int) -> Array[Limb]:
		enemy_view.set_selectable_limbs(from_selection);
		player_view.set_selectable_limbs(from_selection);
		start_confirm(count);
		
		var result: Array[Limb];
		result.assign(await selection_finished);
		_confirm_button.disabled = true;
		_confirm_label.text = "";
		
		return result;
	
	func damage_blob(blob: Blob, amount: float, _userdata: Dictionary) -> void:
		blob._health -= amount;
		player_view.display_amalgam(player);
		enemy_view.display_amalgam(enemy);
	
	func start_confirm(count: int):
		_selection_count = count;
		_confirm_label.text = "0/%d" % count;
		_confirm_button.disabled = false;

func _on_player_ability_selected(tags: Dictionary) -> void:
	var rng := RandomNumberGenerator.new();
	var resolver := PlayerResolver.new(player_amalgam, enemy_amalgam, player_view, enemy_view, confirm_button, confirm_count);
	var effector := Ability.Effector.new(resolver, player_amalgam, enemy_amalgam, tags);
	
	await tags[Ability.EFFECT].call(effector);
	await get_tree().process_frame;
	
	player_view.display_amalgam(player_amalgam);
	enemy_view.display_amalgam(enemy_amalgam);
