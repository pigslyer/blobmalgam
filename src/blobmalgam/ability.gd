class_name Ability
extends Object

const NAME = "display_name";
const DESC = "desc";
const PORTRAIT = "portrait_tex";
const EFFECT = "card_effect";
const ENERGY_COST = "card_energy_cost";
const DAMAGE = "damage";
const CAN_REUSE = "allowed_to_reuse";


const ARM = "arm";
const LEG = "leg";
const EYES = "eyes";
const MOUTH = "mouth";
const WINGS = "wings";
const TAIL = "tail";


const NORMAL = "normal";
const PIXEL = "pixel";
const MONSTER = "monster";
const MEDIEVAL = "medieval";
const CYBER = "cyber";
const ELDRITCH = "eldritch";
const CUTE = "cute";
const ANGELIC = "angelic";
const PLANT = "plant";


const FIRE = "fire_attack";
const POISON = "poison_attack";
const STUN = "intimidating_attack";
const BLEED = "bleed_attack";
const SCORE_MULT = "score_mult_per_fight";

const BODYSLAM = "bodyslam_ability";
const EXCHANGE = "exchange_ability";
const WEAPON = "weapon_ability";

class EffectResolver:
	func request_blobs(_from_selection: Array[Blob], _count: int) -> Array[Blob]:
		Utils.not_implemented(self);
		var arr: Array[Blob];
		@warning_ignore("redundant_await")
		return await arr;
	
	func request_limbs(_from_selection: Array[Limb], _count: int) -> Array[Limb]:
		Utils.not_implemented(self);
		var arr: Array[Limb];
		@warning_ignore("redundant_await")
		return await arr;
	
	func damage_blob(_blob: Blob, _amount: float, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);


class Effector:
	var me: Amalgam;
	var them: Amalgam;
	
	var tags: Dictionary;
	var _resolver: EffectResolver;
	
	@warning_ignore("shadowed_variable")
	func _init(r: EffectResolver, me: Amalgam, them: Amalgam, tags: Dictionary):
		_resolver = r;
		self.me = me; self.them = them; self.tags = tags;
	
	func request_limb_p(predicate: Callable):
		return _first_or_null(await request_limbs_p(predicate, 1));
	func request_limbs_p(predicate: Callable, count: int):
		var limbs: Array[Limb];
		for blob in me.blobs:
			for limb in blob.limbs:
				if (predicate.call(limb.limb)):
					limbs.append(limb.limb);
		for blob in them.blobs:
			for limb in blob.limbs:
				if (predicate.call(limb.limb)):
					limbs.append(limb.limb);
		
		return await _resolver.request_limbs(limbs, count);
	
	func request_blob_p(predicate: Callable) -> Blob:
		return _first_or_null(await request_blobs_p(predicate, 1));
	func request_blobs_p(predicate: Callable, count: int) -> Array[Blob]:
		return await _resolver.request_blobs((me.blobs + them.blobs).filter(predicate), count);
	
	func request_blob_on(a: Amalgam) -> Blob:
		return _first_or_null(await request_blobs_on(a, 1));
	func request_blobs_on(a: Amalgam, count: int) -> Array[Blob]:
		return await _resolver.request_blobs(a.blobs, count);
	
	func request_limb_on(a: Amalgam) -> Limb:
		return _first_or_null(await request_limbs_on(a, 1));
	func request_limbs_on(a: Amalgam, count: int) -> Array[Limb]:
		var limbs: Array[Limb];
		for blob in a.blobs:
			for limb in blob.limbs:
				limbs.append(limb.limb);
		
		return await _resolver.request_limbs(limbs, count);
	
	static func _first_or_null(arr: Array):
		if len(arr) > 0:
			return arr[0];
		else:
			return null;
	
	func damage_blob(blob: Blob, amount: float, userdata: Dictionary = { }):
		if (blob == null):
			push_warning("Attempted to damage null blob, probably from a cancelled cast.");
			return;
		
		_resolver.damage_blob(blob, amount, userdata);


static func bodyslam(a: Amalgam) -> Dictionary:
	return {
		NAME : "Bodyslam",
		DESC : "Your body is your weapon!\nDeal 10 damage per blob (%s)." % (10 * len(a.blobs)),
		EFFECT : func(e: Effector): 
			var target: Blob = await e.request_blob_on(e.them);
			await e.damage_blob(target, len(e.me.blobs) * 10);
			
			pass,
		
		ENERGY_COST : 1,
		CAN_REUSE : 1,
		BODYSLAM : 1,
	}

static func exchange(_a: Amalgam) -> Dictionary:
	return {
		NAME : "Exchange",
		DESC : "Swap parts with opponent.",
		ENERGY_COST : 1,
		EXCHANGE : 1,
		EFFECT: func(e: Effector):
			var enemy_limb: Limb = await e.request_limb_on(e.them);
			if enemy_limb == null:
				return;
			
			var player_limb: Limb = await e.request_limb_on(e.me);
			if player_limb == null:
				return;
			
			var enemy_blob: LimbOwner = _limb_owner(enemy_limb, e.them.blobs);
			var player_blob: LimbOwner = _limb_owner(player_limb, e.me.blobs);
			
			enemy_blob.owning_blob.limbs[enemy_blob.index_in_blob].limb = player_limb;
			player_blob.owning_blob.limbs[player_blob.index_in_blob].limb = enemy_limb;
	}

static func upgrade(previous: Dictionary, new_tags: Dictionary) -> Dictionary:
	var merge_result: MergeResult = _merge_tags(previous, new_tags);
	
	# nothing merged, so this may just transform random bullshit
	# if len is zero, then we're adding an ability
	if len(previous) > 0 && !merge_result.anything_upgraded:
		return previous;
	
	var merged := merge_result.merged;
	
	var has_reached = func(pairs: Array):
		for i in range(0, len(pairs), 2):
			var key = pairs[i + 0];
			var value = pairs[i + 1];
			
			var is_enough_now: bool = merged.get(key, 0) >= value;
			if !is_enough_now:
				return false;
			
			# This allows us to update card data every time, so no fucking around with callables
			# and descriptions.
			#var was_enough_before = previous.get(key, 0) >= value;
			#if was_enough_before:
				#return false;
		
		return true;

	var ability = func(ability_def: Dictionary) -> Dictionary:
		ability_def.merge(merged);
		
		return ability_def;
	
	# EXCHANGE SPECIALIZATION
	if EXCHANGE in merged:
		return previous;
	
	
	# BODYSLAM SPECIALIZATION
	if BODYSLAM in merged:
		if has_reached.call([WINGS, 1]):
			return ability.call({
				NAME : "Flying Bodyslam",
				DESC : "BECOME BULLET.",
			});
		
		return previous;
	
	# GENERIC
	if has_reached.call([LEG, 3]):
		return ability.call({
			NAME : "Consecutive normal kick",
			DESC : "Kick your opponent with all your legs!\nDeal 10 damage per legs (%s)." % (merged.get(LEG) * 10),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.request_blob_on(e.them), e.tags[LEG] * 10);
		});
	
	if has_reached.call([LEG, 1]):
		return ability.call({
			NAME : "Kick",
			DESC : "Kick your opponent!\nDeal 5 damage per legs (%s)." % (merged.get(LEG) * 5),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.request_blob_on(e.them), e.tags[LEG] * 5);
		});
	
	if !merge_result.anything_upgraded:
		return previous;
	
	return merged;


class MergeResult:
	var merged: Dictionary;
	var anything_upgraded: bool;
static func _merge_tags(previous: Dictionary, new_tags: Dictionary) -> MergeResult:
	var merged_tags := previous.duplicate();
	
	var any_upgraded := false;
	for tag in new_tags:
		var has_added_tag := false;
		
		if tag in merged_tags:
			var val = new_tags[tag];
			
			if val is int || val is float:
				merged_tags[tag] += val;
				
				any_upgraded = true;
				has_added_tag = true;
		
		if !has_added_tag:
			merged_tags[tag] = new_tags[tag];
	
	var result := MergeResult.new();
	result.merged = merged_tags;
	result.anything_upgraded = any_upgraded;
	
	return result;

class LimbOwner:
	var owning_blob: Blob;
	var index_in_blob: int;
static func _limb_owner(sought: Limb, blobs: Array[Blob]) -> LimbOwner:
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
