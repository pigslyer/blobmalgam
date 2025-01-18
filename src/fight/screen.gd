class_name BattleScreen;
extends Control

signal player_won;
signal player_lost;

var player: Amalgam;
var player_drawn_abilities: Array[Dictionary];

var enemy: Amalgam;

@onready var player_health: ExportedAmalgamHealth = $PlayerHealth;
@onready var enemy_health: ExportedAmalgamHealth = $EnemyHealth;

@onready var player_ragdoll: AmalgamDisplay = $PlayerRagdollArea/Origin/AmalgamRagdoll;
@onready var enemy_ragdoll: AmalgamDisplay = $EnemyRagdollArea/Origin/AmalgamRagdoll;

@onready var exchange: ExportedCard = $ExchangeCard/Card;
@onready var bodyslam: ExportedCard = $BodySlamCard/Card;

@onready var player_cards: VBoxContainer = $Cards/Player;
@onready var enemy_cards: VBoxContainer = $Cards/Enemy;
@onready var skip: Button = $SkipTurn;

var skip_animations: bool;

func _ready():
	for i in player_cards.get_children():
		var player_card: ExportedCard = i;
		
		player_card.selected.connect(_on_player_card_selected);
	
	
@warning_ignore("shadowed_variable")
func begin_fight(player: Amalgam, enemy: Amalgam) -> void:
	self.player = player;
	self.enemy = enemy;
	
	player_health.update_health_instant(player);
	player_ragdoll.display_amalgam(player);
	player_ragdoll.idle(AmalgamDisplay.IdleKinds.Standing);
	
	enemy_health.update_health_instant(enemy);
	enemy_ragdoll.display_amalgam(enemy);
	enemy_ragdoll.idle(AmalgamDisplay.IdleKinds.Standing);
	
	player_turn();

func player_turn():
	skip.show();
	var rng := RandomNumberGenerator.new();
	var abilities: Array[Dictionary] = player.combat_display_actions_simult_flattened(rng, 5, true);
	
	player_drawn_abilities = abilities;
	
	exchange.show();
	bodyslam.show();
	
	exchange.display_card(abilities[0], player, enemy);
	bodyslam.display_card(abilities[1], player, enemy);
	
	for i in range(2, len(abilities)):
		if !Ability.EFFECT in abilities[i]:
			push_warning("No effect found in card ", abilities[i]);
			continue ;
		
		var card: ExportedCard = player_cards.get_child(i - 2);
		card.display_card(abilities[i], player, enemy);
		card.show();


class PlayerEffectResolver extends Ability.EffectResolver:
	var battle_screen: BattleScreen;
	var _is_awaiting: bool = false;
	var _had_side_effects: bool = false;
	
	signal selection_finished(selected: Array);
	
	func blobs(from_selection: Array[Blob], count: int) -> Array[Blob]:
		_begin_selection(from_selection, count);
		
		var arr: Array[Blob];
		_is_awaiting = true;
		arr.assign(await selection_finished);
		_is_awaiting = false;
		
		battle_screen.player_ragdoll.blob_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.player_ragdoll.limb_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.blob_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.limb_pressed.disconnect(_on_ragdoll_selection);
		
		battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, []);
		battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, []);
		battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, []);
		battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, []);
		
		return arr;
	
	func limbs(from_selection: Array[Limb], count: int) -> Array[Limb]:
		_begin_selection(from_selection, count);
		
		var arr: Array[Limb];
		_is_awaiting = true;
		arr.assign(await selection_finished);
		_is_awaiting = false;
		
		battle_screen.player_ragdoll.blob_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.player_ragdoll.limb_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.blob_pressed.disconnect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.limb_pressed.disconnect(_on_ragdoll_selection);
		
		battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, []);
		battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, []);
		battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, []);
		battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, []);
		
		return arr;
	
	func dice_roll(r: int, _userdata: Dictionary) -> int:
		var value: int = randi() % r;
		print("rolled ", value);
		_had_side_effects = true;
		return value;
	
	func damage_blobs(blobs: Array[Blob], amount: float, _userdata: Dictionary) -> void:
		for blob in blobs:
			blob._health -= amount;
			_had_side_effects = true;
		
		if len(blobs) > 0:
			await _update_blob(_blobs_amalgam(blobs[0]), {
				Ability.ANIM_SLASH: blobs,
			});
	
	func stun_blob(blob: Blob, turn_count: int, _userdata: Dictionary) -> void:
		blob._stun += turn_count;
		_had_side_effects = true;
		
		await _update_blob(_blobs_amalgam(blob), {});
	
	func poison_blob(blob: Blob, amount: int, _userdata: Dictionary) -> void:
		blob._poison = amount;
		_had_side_effects = true;
		
		await _update_blob(_blobs_amalgam(blob), {
			Ability.ANIM_SLASH: [blob],
		});
	
	func heal_blobs(blobs: Array[Blob], amount: float, _userdata: Dictionary) -> void:
		for blob in blobs:
			blob._health += amount;
			_had_side_effects = true;
		
		if len(blobs) > 0:
			await _update_blob(_blobs_amalgam(blobs[0]), {
				Ability.ANIM_SLASH: blobs,
			});
	
	func _update_blob(ragdoll: AmalgamDisplay, userdata: Dictionary):
		battle_screen.player_health.update_health_slow(battle_screen.player);
		battle_screen.enemy_health.update_health_slow(battle_screen.enemy);
		
		if len(userdata) > 0:
			ragdoll.play_animation(userdata);
			
			if !battle_screen.skip_animations:
				await ragdoll.animation_finished;
	
	func _blobs_amalgam(blob: Blob) -> AmalgamDisplay:
		var is_player_blob: int = battle_screen.player.blobs.find(blob) != -1;
		var is_enemy_blob: int = battle_screen.enemy.blobs.find(blob) != -1;
		assert(is_player_blob ^ is_enemy_blob);
		
		if is_player_blob:
			return battle_screen.player_ragdoll;
		else:
			return battle_screen.enemy_ragdoll;
	
	
	func _blobs_ragdoll(blob: Blob) -> AmalgamDisplay:
		var is_player_blob: int = battle_screen.player.blobs.find(blob) != -1;
		var is_enemy_blob: int = battle_screen.enemy.blobs.find(blob) != -1;
		assert(is_player_blob ^ is_enemy_blob);
		
		if is_player_blob:
			return battle_screen.player_ragdoll;
		else:
			return battle_screen.enemy_ragdoll;
	
	func swap_limbs(a: Limb, b: Limb, _userdata: Dictionary) -> void:
		var all_blobs: Array[Blob] = battle_screen.player.blobs + battle_screen.enemy.blobs;
		var a_owner: Utils.LimbOwner = Utils.limb_owner(a, all_blobs);
		var b_owner: Utils.LimbOwner = Utils.limb_owner(b, all_blobs);
		assert(a_owner != null && b_owner != null);
		
		a_owner.owning_blob.limbs[a_owner.index_in_blob].limb = b;
		b_owner.owning_blob.limbs[b_owner.index_in_blob].limb = a;
		
		_had_side_effects = true;
		battle_screen.player_ragdoll.display_amalgam(battle_screen.player);
		battle_screen.enemy_ragdoll.display_amalgam(battle_screen.enemy);
	
	var _valid_selection: Array;
	var _currently_selected: Array;
	var _required_count: int;
	func _begin_selection(selectable: Array, count: int) -> void:
		print_stack();
		
		battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, selectable);
		battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selectable, selectable);
		
		_valid_selection = selectable;
		_currently_selected.clear();
		_required_count = count;
		
		battle_screen.player_ragdoll.blob_pressed.connect(_on_ragdoll_selection);
		battle_screen.player_ragdoll.limb_pressed.connect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.blob_pressed.connect(_on_ragdoll_selection);
		battle_screen.enemy_ragdoll.limb_pressed.connect(_on_ragdoll_selection);
	
	func _on_ragdoll_selection(what) -> void:
		assert(what is Blob || what is Limb);
		
		var is_selectable: bool = _valid_selection.find(what) != -1;
		if is_selectable:
			var idx: int = _currently_selected.find(what);
			if idx == -1:
				_currently_selected.append(what);
			else:
				_currently_selected.remove_at(idx);
			
			battle_screen.player_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, _currently_selected);
			battle_screen.enemy_ragdoll.effect(AmalgamDisplay.EffectKind.Selected, _currently_selected);
		
		var is_finished: bool = len(_currently_selected) <= _required_count;
		if is_finished:
			var selected: Array = _currently_selected;
			_currently_selected = [];
			_valid_selection.clear();
			
			selection_finished.emit(selected);
	
	func cancel_awaits() -> void:
		while _is_awaiting:
			selection_finished.emit([]);
	
	func had_side_effects() -> bool:
		return _had_side_effects;

var _last_resolver: PlayerEffectResolver;
func _on_player_card_selected(card: Dictionary):
	print("selecting card!", card);
	_cancel_active_cast();
	
	var card_idx: int = player_drawn_abilities.find(card);
	assert(card_idx != -1);
	
	var resolver := PlayerEffectResolver.new();
	resolver.battle_screen = self;
	var effector := Ability.Effector.new(resolver, player, enemy, card);
	
	_last_resolver = resolver;
	
	var ability: Callable = card.get(Ability.EFFECT, func(_e): push_error("No effect found on card!"));
	await ability.call(effector);
	
	_last_resolver = null;
	
	var is_same_ability: bool = card_idx == player_drawn_abilities.find(card);
	print("wrapping up ability ", card)
	if is_same_ability && resolver.had_side_effects():
		_end_player_turn();

func _on_skip_turn_pressed() -> void:
	_end_player_turn();

func _end_player_turn() -> void:
	if _last_resolver != null:
		_last_resolver.cancel_awaits();
		_last_resolver = null;
	
	skip.hide();
	exchange.hide();
	bodyslam.hide();
	
	for card in player_cards.get_children():
		card.hide();
	
	player_drawn_abilities = [];
	
	var player_died := player.current_global_health() <= 0;
	var enemy_died := enemy.current_global_health() <= 0;
	
	if player_died:
		_player_lost();
	
	if enemy_died:
		_enemy_lost();
	
	if !player_died && !enemy_died:
		enemy_turn();

class EnemyResolver extends Ability.EffectResolver:
	var battle_screen: BattleScreen;
	var rng: RandomNumberGenerator;
	
	func blobs(from_selection: Array[Blob], count: int) -> Array[Blob]:
		if count <= len(from_selection):
			return from_selection;
		
		var ret: Array[Blob];
		for _i in count:
			var idx := rng.randi() % len(from_selection);
			ret.append(from_selection[idx]);
			from_selection.remove_at(idx);
		
		return ret;
	
	func limbs(from_selection: Array[Limb], count: int) -> Array[Limb]:
		if count <= len(from_selection):
			return from_selection;
		
		var ret: Array[Limb];
		for _i in count:
			var idx := rng.randi() % len(from_selection);
			ret.append(from_selection[idx]);
			from_selection.remove_at(idx);
		
		return ret;
	
	func dice_roll(r: int, _userdata: Dictionary) -> int:
		var value := rng.randi() % r;
		print("rolled ", value);
		return value;
	
	func damage_blobs(blobs: Array[Blob], amount: float, userdata: Dictionary) -> void:
		for blob in blobs:
			blob._health -= amount;
			
		if len(blobs) > 0:
			_update_blob(_blobs_ragdoll(blobs[0]), userdata);
	
	func stun_blob(blob: Blob, turn_count: int, userdata: Dictionary) -> void:
		blob._stun += turn_count;
		
		_update_blob(_blobs_ragdoll(blob), userdata);
	
	func poison_blob(blob: Blob, amount: int, userdata: Dictionary) -> void:
		blob._poision += amount;
		
		_update_blob(_blobs_ragdoll(blob), userdata);
	
	func heal_blobs(blobs: Array[Blob], amount: float, userdata: Dictionary) -> void:
		for blob in blobs:
			blob._health += amount;
			
		if len(blobs) > 0:
			_update_blob(_blobs_ragdoll(blobs[0]), userdata);
	
	func _update_blob(ragdoll: AmalgamDisplay, userdata: Dictionary):
		battle_screen.player_health.update_health_slow(battle_screen.player);
		battle_screen.enemy_health.update_health_slow(battle_screen.enemy);
		
		if len(userdata) > 0:
			ragdoll.play_animation(userdata);
			
			if !battle_screen.skip_animations:
				await ragdoll.animation_finished;
	
	func _blobs_ragdoll(blob: Blob) -> AmalgamDisplay:
		var is_player_blob: int = battle_screen.player.blobs.find(blob) != -1;
		var is_enemy_blob: int = battle_screen.enemy.blobs.find(blob) != -1;
		assert(is_player_blob ^ is_enemy_blob);
		
		if is_player_blob:
			return battle_screen.player_ragdoll;
		else:
			return battle_screen.enemy_ragdoll;
	
	func swap_limbs(a: Limb, b: Limb, _userdata: Dictionary) -> void:
		var all_blobs: Array[Blob] = battle_screen.player.blobs + battle_screen.enemy.blobs;
		var a_owner: Utils.LimbOwner = Utils.limb_owner(a, all_blobs);
		var b_owner: Utils.LimbOwner = Utils.limb_owner(b, all_blobs);
		assert(a_owner != null && b_owner != null);
		
		a_owner.owning_blob.limbs[a_owner.index_in_blob].limb = b;
		b_owner.owning_blob.limbs[b_owner.index_in_blob].limb = a;
		
		battle_screen.player_ragdoll.display_amalgam(battle_screen.player);
		battle_screen.enemy_ragdoll.display_amalgam(battle_screen.enemy);
	

func enemy_turn() -> void:
	_apply_start_of_turn(enemy, enemy_ragdoll);
	
	if enemy.total_global_health() > 0:
		var rng := RandomNumberGenerator.new();
		var abilities: Array[Dictionary] = enemy.combat_display_actions_simult_flattened(rng, 5, false);
		
		for i in len(abilities):
			var shown_card: ExportedCard = enemy_cards.get_child(i);
			shown_card.display_card(abilities[i], enemy, player);
			shown_card.show();
		
		await get_tree().create_timer(1).timeout;
		
		var chosen: int = rng.randi() % len(abilities);
		var card: ExportedCard = enemy_cards.get_child(chosen);
		
		card.modulate = Color.RED;
		await get_tree().create_timer(0.3).timeout;
		
		var resolver := EnemyResolver.new();
		resolver.battle_screen = self;
		resolver.rng = rng;
		
		var effector := Ability.Effector.new(resolver, enemy, player, abilities[chosen]);
		await abilities[chosen][Ability.EFFECT].call(effector);
		
		for child in enemy_cards.get_children():
			child.hide();
			child.modulate = Color.WHITE;
	
	var player_died := player.current_global_health() <= 0;
	var enemy_died := enemy.current_global_health() <= 0;
	
	if player_died:
		_player_lost();
	
	if enemy_died:
		_enemy_lost();
	
	if !player_died && !enemy_died:
		player_turn();

func _apply_start_of_turn(on: Amalgam, displayed_on: AmalgamDisplay) -> void:
	
	
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			_cancel_active_cast();

func _cancel_active_cast() -> void:
	if _last_resolver != null:
		_last_resolver.cancel_awaits();
		_last_resolver = null;
		
		# maybe
		#await get_tree().process_frame

func _player_lost() -> void:
	player_lost.emit();


func _enemy_lost() -> void:
	player_won.emit();
