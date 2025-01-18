extends Control

const MAX_ENERGY = 3;

var player: Amalgam;
var player_abilities: Array[Dictionary];
var enemy: Amalgam;

@export var player_view: Tree;
@export var enemy_view: Tree;

@export var ability_list: HBoxContainer;
@export var energy_cost_display: Label;

@export var selection_root: Control;
@export var selection_cancel: Button;
@export var selection_confirm: Button;
@export var selection_count: Label;

@export var breakdown_popup: Popup;
@export var breakdown_tree: Tree;

func _ready():
	_regen();

func _on_regen_pressed() -> void:
	_regen();

func _regen() -> void:
	player = generate_player_amalgam();
	Utils.display_amalgam(player_view, player);
	
	enemy = generate_enemy_amalgam();
	Utils.display_amalgam(enemy_view, enemy);
	
	var rng := RandomNumberGenerator.new();
	player_abilities = player.combat_display_actions_simult_flattened(rng, 5, true);
	
	display_cards(ability_list, player_abilities, _on_card_pressed);

class PlayerResolver extends Ability.EffectResolver:
	signal selection_finished(selected: Array);
	signal confirm_finished(state: bool);
	
	var _rng: RandomNumberGenerator;
	
	var _selection_root: Control;
	var _selection_cancel: Button;
	var _selection_confirm: Button;
	var _selection_count: Label;
	
	var _player: Amalgam;
	var _player_view: Tree;
	
	var _enemy: Amalgam;
	var _enemy_view: Tree; 
	var _was_side_effecting: bool = false;
	var _is_awaiting = false;
	
	func blobs(from_selection: Array[Blob], count: int) -> Array[Blob]:
		var arr: Array[Blob];
		arr.assign(await _select(from_selection, count));
		return arr;
	
	func limbs(from_selection: Array[Limb], count: int) -> Array[Limb]:
		var arr: Array[Limb];
		arr.assign(await _select(from_selection, count));
		return arr;
	
	func _select(from: Array, count: int) -> Array:
		_selection_count.text = "0/%d" % count;
		_selection_confirm.disabled = false;
		_selection_root.show();
		
		var on_selected = func():
			var sum: Array = Utils.total_selection(_player_view) + Utils.total_selection(_enemy_view);
			_selection_count.text = "%d/%d" % [len(sum), count];
			_selection_confirm.disabled = len(sum) > count;
	
		var on_confirmed = func():
			self.selection_finished.emit(Utils.total_selection(_player_view) + Utils.total_selection(_enemy_view));
		
		var on_cancelled = func():
			self.selection_finished.emit([]);
		
		Utils.select_on(_player_view, from, on_selected);
		Utils.select_on(_enemy_view, from, on_selected);
		_selection_confirm.pressed.connect(on_confirmed);
		_selection_cancel.pressed.connect(on_cancelled);
		
		_is_awaiting = true;
		var selection = await selection_finished;
		_is_awaiting = false;
		
		Utils.clear_selection(_player_view);
		Utils.clear_selection(_enemy_view);
		_selection_confirm.pressed.disconnect(on_confirmed);
		_selection_cancel.pressed.disconnect(on_cancelled);
		_selection_root.hide();
		
		return selection;
	
	func dice_roll(r: int, _userdata: Dictionary) -> int:
		var roll: int = _rng.randi() % r;
		print("Got %d from dice roll" % roll);
		
		_was_side_effecting = true;
		return roll;
	
	func damage_blob(blob: Blob, amount: float, _userdata: Dictionary) -> void:
		blob._health -= amount;
		
		Utils.display_amalgam(_player_view, _player);
		Utils.display_amalgam(_enemy_view, _enemy);
		_was_side_effecting = true;
	
	func stun_blob(blob: Blob, turn_count: int, _userdata: Dictionary) -> void:
		blob._stun += turn_count;
		
		Utils.display_amalgam(_player_view, _player);
		Utils.display_amalgam(_enemy_view, _enemy);
		_was_side_effecting = true;
	
	func poison_blob(blob: Blob, amount: int, _userdata: Dictionary) -> void:
		blob._poison += amount;
		
		Utils.display_amalgam(_player_view, _player);
		Utils.display_amalgam(_enemy_view, _enemy);
		_was_side_effecting = true;
	
	func heal_blob(blob: Blob, amount: float, _userdata: Dictionary) -> void:
		blob._health += amount;
		
		Utils.display_amalgam(_player_view, _player);
		Utils.display_amalgam(_enemy_view, _enemy);
		_was_side_effecting = true;
	
	func swap_limbs(a: Limb, b: Limb, _userdata: Dictionary) -> void:
		var all_blobs: Array[Blob] = _player.blobs + _enemy.blobs;
		
		var a_owner: Utils.LimbOwner = Utils.limb_owner(a, all_blobs);
		var b_owner: Utils.LimbOwner = Utils.limb_owner(b, all_blobs);
		
		if a_owner == null:
			push_warning("failed to identify owner of limb a: %s", str(a.tags));
		if b_owner == null:
			push_warning("failed to identify owner of limb b: %s", str(b.tags));
		
		a_owner.owning_blob.limbs[a_owner.index_in_blob].limb = b;
		b_owner.owning_blob.limbs[b_owner.index_in_blob].limb = a;
		_was_side_effecting = true;
	
	func confirm_choice(_userdata: Dictionary) -> bool:
		_selection_confirm.disabled = false;
		_selection_root.show();
		_selection_count.text = "Please confirm";
		
		var on_confirmed = func():
			confirm_finished.emit(true);
		var on_cancelled = func():
			confirm_finished.emit(false);
		
		_selection_confirm.pressed.connect(on_confirmed);
		_selection_cancel.pressed.connect(on_cancelled);
		
		_is_awaiting = true;
		var confirmed: bool = await confirm_finished;
		_is_awaiting = false;
		
		_selection_cancel.pressed.disconnect(on_cancelled);
		_selection_confirm.pressed.disconnect(on_confirmed);
		
		return confirmed;
	
	func cancel_awaits():
		while _is_awaiting:
			confirm_finished.emit(false);
			selection_finished.emit([]);
		

var _last_resolver: PlayerResolver = null;

func _on_card_pressed(ability_idx: int) -> void:
	if _last_resolver != null:
		_last_resolver.cancel_awaits();
		_last_resolver = null;
		await get_tree().process_frame;
	
	var ability: Dictionary = player_abilities[ability_idx];
	
	
	var resolver := PlayerResolver.new()
	_last_resolver = resolver;
	resolver._rng = RandomNumberGenerator.new();
	
	resolver._selection_root = selection_root;
	resolver._selection_count = selection_count;
	resolver._selection_cancel = selection_cancel;
	resolver._selection_confirm = selection_confirm;
	
	resolver._player = player;
	resolver._enemy = enemy;
	resolver._player_view = player_view;
	resolver._enemy_view = enemy_view;
	
	var effector := Ability.Effector.new(resolver, player, enemy, ability);
	await ability[Ability.EFFECT].call(effector);
	await get_tree().process_frame;
	
	Utils.display_amalgam(player_view, player);
	Utils.display_amalgam(enemy_view, enemy);
	
	_last_resolver = null;
	
	var is_still_same_card: bool = ability_idx < len(player_abilities) && player_abilities[ability_idx] == ability;
	
	# ability did something
	if  is_still_same_card && resolver._was_side_effecting:
		print("ending turn");
		_on_end_turn_pressed();

func _on_breakdown_pressed() -> void:
	#Utils.display_ability_breakdown(breakdown_tree, player_abilities);
	breakdown_popup.popup();


func _on_end_turn_pressed() -> void:
	var rng := RandomNumberGenerator.new();
	player_abilities = player.combat_display_actions_simult_flattened(rng, 5, true);
	
	display_cards(ability_list, player_abilities, _on_card_pressed);

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
	var amalgam := Amalgam.new();
	
	var blob := Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	return amalgam;


const ABILITY_META = "ABILITY_META";
static func display_cards(under_parent: Control, abilities: Array[Dictionary], on_pressed: Callable):
	for child in under_parent.get_children():
		child.queue_free();
	
	var idx := 0;
	for ability in abilities:
		var button := Button.new();
		button.text = "%s\n%s" % [ability.get(Ability.NAME, "NONE"), ability.get(Ability.DESC, "NONE")];
		button.set_meta(ABILITY_META, ability);
		button.pressed.connect(func(): on_pressed.call(idx));
		
		under_parent.add_child(button);
		idx += 1;
