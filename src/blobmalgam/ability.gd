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
const SCORE_MULT = "score_mult";
const REFLEX = "reflex_booster";
const THROW = "throw_attack";
const CONSUMING = "consuming_attack";
const GRABBY = "grabby";

const BODYSLAM = "bodyslam_ability";
const EXCHANGE = "exchange_ability";
const WEAPON = "weapon_ability";

class EffectResolver:
	func blobs(_from_selection: Array[Blob], _count: int) -> Array[Blob]:
		Utils.not_implemented(self);
		var arr: Array[Blob];
		@warning_ignore("redundant_await")
		return await arr;
	
	func limbs(_from_selection: Array[Limb], _count: int) -> Array[Limb]:
		Utils.not_implemented(self);
		var arr: Array[Limb];
		@warning_ignore("redundant_await")
		return await arr;
	
	func dice_roll(_range: int, _userdata: Dictionary) -> int:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		return await 0;
	
	func damage_blob(_blob: Blob, _amount: float, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);
		# fake to make linter aware this is an async method
		@warning_ignore("redundant_await")
		var _discard = await 2 + 2;
	
	func stun_blob(_blob: Blob, _turn_count: int, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		var _discard = await 2 + 2;
	
	func poison_blob(_blob: Blob, _amount: int, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		var _discard = await 2 + 2;
	
	func heal_blob(_blob: Blob, _amount: float, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		var _discard = await 2 + 2;
	
	
	func swap_limbs(_a: Limb, _b: Limb, _userdata: Dictionary) -> void:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		var _discard = await 2 + 2;
	
	func confirm_choice(_userdata: Dictionary) -> bool:
		Utils.not_implemented(self);
		@warning_ignore("redundant_await")
		return await false;
	

class Effector:
	var me: Amalgam;
	var them: Amalgam;
	
	var tags: Dictionary;
	var _resolver: EffectResolver;
	
	@warning_ignore("shadowed_variable")
	func _init(r: EffectResolver, me: Amalgam, them: Amalgam, tags: Dictionary):
		_resolver = r;
		self.me = me; self.them = them; self.tags = tags;
	
	func limb_p(predicate: Callable):
		return _first_or_null(await limbs_p(predicate, 1));
	func limbs_p(predicate: Callable, count: int):
		var limbs: Array[Limb];
		for blob in me.blobs:
			for limb in blob.limbs:
				if (predicate.call(limb.limb)):
					limbs.append(limb.limb);
		for blob in them.blobs:
			for limb in blob.limbs:
				if (predicate.call(limb.limb)):
					limbs.append(limb.limb);
		
		return await _resolver.limbs(limbs, count);
	
	func blob_p(predicate: Callable) -> Blob:
		return _first_or_null(await blobs_p(predicate, 1));
	func blobs_p(predicate: Callable, count: int) -> Array[Blob]:
		return await _resolver.blobs((me.blobs + them.blobs).filter(predicate), count);
	
	func blob_on(a: Amalgam) -> Blob:
		return _first_or_null(await blobs_on(a, 1));
	func blobs_on(a: Amalgam, count: int) -> Array[Blob]:
		return await _resolver.blobs(a.blobs, count);
	
	func limb_on(a: Amalgam) -> Limb:
		return _first_or_null(await limbs_on(a, 1));
	func limbs_on(a: Amalgam, count: int) -> Array[Limb]:
		var limbs: Array[Limb];
		for blob in a.blobs:
			for limb in blob.limbs:
				limbs.append(limb.limb);
		
		return await _resolver.limbs(limbs, count);
	
	static func _first_or_null(arr: Array):
		if len(arr) > 0:
			return arr[0];
		else:
			return null;
	
	func d20(base: int, required: int, userdata: Dictionary) -> bool:
		var result = await _resolver.dice_roll(20, userdata);
		return (base + result) > required;
	
	func dice_roll(sides: int, userdata: Dictionary) -> bool:
		return await _resolver.dice_roll(sides, userdata);
	
	func damage_blob(blob: Blob, amount: float, userdata: Dictionary = { }):
		if (blob == null):
			push_warning("Attempted to damage null blob, probably from a cancelled cast.");
			return;
		
		_resolver.damage_blob(blob, amount, userdata);
	
	
	func stun_blob(blob: Blob, turn_count: int, userdata: Dictionary) -> void:
		if blob == null:
			return;
		
		await _resolver.stun_blob(blob, turn_count, userdata);

	func poison_blob(blob: Blob, amount: int, userdata: Dictionary) -> void:
		if blob == null:
			return;
		
		await _resolver.poison_blob(blob, amount, userdata);
	
	func heal_blob(blob: Blob, amount: float, userdata: Dictionary) -> void:
		if blob == null:
			return;
		
		await _resolver.heal_blob(blob, amount, userdata);
	
	func swap_limbs(a: Limb, b: Limb, userdata: Dictionary) -> void:
		if a == null || b == null:
			return;
		
		await _resolver.swap_limbs(a, b, userdata);
	
	func confirm_choice(userdata: Dictionary) -> bool:
		return await _resolver.confirm_choice(userdata);
	
	func damage_limb_owner(limb: Limb, amount: float, userdata: Dictionary):
		var found: Blob = null;
		for search_blob in (me.blobs + them.blobs):
			for search_limb in search_blob.limbs:
				if search_limb == limb:
					found = search_blob;
		
		if found == null:
			push_warning("Trying to damage null limb, probably due to a cancelled action.");
			return;
		
		await damage_blob(found, amount, userdata);


static func bodyslam(a: Amalgam) -> Dictionary:
	return {
		NAME : "Bodyslam",
		DESC : "Your body is your weapon!\nDeal 10 damage per blob (%s)." % (10 * len(a.blobs)),
		EFFECT : func(e: Effector): 
			var target: Blob = await e.blob_on(e.them);
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
			var enemy_limb: Limb = await e.limb_on(e.them);
			var player_limb: Limb = await e.limb_on(e.me);
			
			await e.swap_limbs(enemy_limb, player_limb, { });
	}


static func craft_ability(amalgam: Amalgam, tags: Dictionary) -> Dictionary:
	var crafter := Crafter.new(amalgam, tags);
	_upgrade_crafter(crafter);
	
	var final: Array[Dictionary] = crafter.finish();
	
	if len(final) == 0:
		return { };
	
	final[0].merge(tags);
	return final[0];

static func upgarde_only_accumulate(amalgam: Amalgam, previous: Dictionary, new_tags: Dictionary) -> Dictionary:
	var merge_result: MergeResult = _merge_tags(previous, new_tags, true);
	
	# nothing merged, so this may just transform random bullshit
	# if len is zero, then we're adding an ability
	if len(previous) > 0 && !merge_result.anything_upgraded:
		return previous;
	
	var merged := merge_result.merged;
	
	var crafter := Crafter.new(amalgam, merge_result.merged);
	_upgrade_crafter(crafter);
	
	var final: Array[Dictionary] = crafter.finish();
	
	if len(final) == 0:
		return previous;
	
	final[0].merge(merged);
	return final[0];


static func upgrade(amalgam: Amalgam, previous: Dictionary, new_tags: Dictionary) -> Dictionary:
	var merge_result: MergeResult = _merge_tags(previous, new_tags, false);
	
	# nothing merged, so this may just transform random bullshit
	# if len is zero, then we're adding an ability
	if len(previous) > 0 && !merge_result.anything_upgraded:
		return previous;
	
	var merged := merge_result.merged;
	
	var crafter := Crafter.new(amalgam, merge_result.merged);
	_upgrade_crafter(crafter);
	
	var final: Array[Dictionary] = crafter.finish();
	
	if len(final) == 0:
		return previous;
	
	final[0].merge(merged);
	return final[0];

class Crafter:
	var _amalgam: Amalgam;
	var _ingredients: Dictionary;
	var _crafted_abilities: Array[Dictionary];
	
	func _init(amal: Amalgam, ingr: Dictionary):
		_amalgam = amal; _ingredients = ingr;
	
	func tags() -> Dictionary:
		return _ingredients;
	
	func has_reached(rq: Array) -> bool:
		for i in range(0, len(rq), 2):
			var key = rq[i + 0];
			var value = rq[i + 1];
			
			var is_enough_now: bool = _ingredients.get(key, 0) >= value;
			if !is_enough_now:
				return false;
			
			# This allows us to update card data every time, so no fucking around with callables
			# and descriptions.
			#var was_enough_before = previous.get(key, 0) >= value;
			#if was_enough_before:
				#return false;
		
		return true;
		
	func ability(dict: Dictionary) -> void:
		_crafted_abilities.append(dict);
	
	func amalgam() -> Amalgam:
		return _amalgam;
	
	func finish() -> Array[Dictionary]:
		_crafted_abilities.make_read_only();
		return _crafted_abilities;

# delete this to get compiler errors wherever TODO was used
const TODO = "todo";

static func _upgrade_crafter(c: Crafter) -> void:
	# EXCHANGE SPECIALIZATION
	if EXCHANGE in c.tags():
		if c.has_reached([GRABBY, 1]):
			c.ability({
				NAME : "Shakedown",
				DESC : TODO,
				EFFECT : func(e: Effector):
					var enemy_limb: Limb = await e.limb_on(e.them);
					var player_limb: Limb = await e.limb_on(e.me);
					
					await e.damage_limb_owner(enemy_limb, e.tags[GRABBY] * 20, { });
					await e.swap_limbs(enemy_limb, player_limb, { });
			})
		
		return;
	
	# BODYSLAM SPECIALIZATION
	if BODYSLAM in c.tags():
		if c.has_reached([WINGS, 1]):
			c.ability({
				NAME : "Flying Bodyslam",
				DESC : TODO,
				EFFECT : func(e: Effector):
					await e.damage_blob(await e.blob_on(e.them), len(e.me.blobs) * 20 + e.tags[WINGS] * 10);
			});
		
		return;
	
	if c.has_reached([CYBER, 3]):
		c.ability({
			NAME : "Overcharge",
			DESC : TODO,
			EFFECT : func(e: Effector):
				for enemy_blob in e.them.blobs:
					await e.stun_blob(enemy_blob, 1, { });
		})
	
	if c.has_reached([GRABBY, 1]):
		c.ability({
			NAME : "Tentacle slap",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var target_blob: Blob = await e.blob_on(e.them);
				if target_blob == null:
					return;
				
				var malfunction: bool = !(await e.d20(0, 8 + e.tags[GRABBY], { }));
				if malfunction:
					var target_idx: int = await e.dice_roll(len(e.me.blobs), { });
					target_blob = e.me.blobs[target_idx];
				
				await e.damage_blob(target_blob, e.tags[GRABBY] * 10);
		})
	
	if c.has_reached([POISON, 5, MOUTH, 1]):
		c.ability({
			NAME : "Poison Spit",
			DESC : TODO,
			EFFECT : func(e: Effector):
				await e.poison_blob(await e.blob_on(e.them), e.tags[POISON] * 10, { });
		})
	
	if c.has_reached([EYES, 1, ELDRITCH, 4]):
		c.ability({
			NAME : "The Gaze",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var target_blob: Blob = await e.blob_on(e.them);
				if target_blob == null:
					return;
				
				if !await e.d20(e.tags[ELDRITCH], 10, { }):
					return;
				
				await e.stun_blob(target_blob, e.tags[ELDRITCH], { });
		})
	
	if c.has_reached([ANGELIC, 3]):
		c.ability({
			NAME : "Light of God",
			DESC : TODO,
			EFFECT : func(e: Effector):
				if !await e.confirm_choice({ }):
					return;
				
				for blob in e.them.blobs:
					await e.stun_blob(blob, e.tags[ANGELIC] - 2, { });
		})
	
	if c.has_reached([ARM, 8]):
		c.ability({
			NAME : "Platinum Punches",
			DESC : TODO,
			EFFECT : func(e: Effector):
				for arm in range(e.tags[ARM]):
					await e.damage_blob(await e.blob_on(e.them), 15, { });
		})
	
	if c.has_reached([ARM, 2, CUTE, 1]):
		c.ability({
			NAME : "Cute Hug",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var hug_target: Blob = await e.blob_on(e.them);
				
				var can_hug: bool = await e.d20(e.tags[ARM] + e.tags[CUTE], 8, { });
				if !can_hug:
					return;
				
				await e.stun_blob(hug_target, 1, { });
		})
	
	if c.has_reached([WINGS, 3, LEG, 3]):
		c.ability({
			NAME : "Triple Frontflip Kick",
			DESC : TODO,
			EFFECT : func(e: Effector):
				pass;
		})
	
	if c.has_reached([MOUTH, 1, CONSUMING, 1]):
		pass
	
	if c.has_reached([CUTE, 1, MOUTH, 1]):
		pass
	
	if c.has_reached([CUTE, 4, WINGS, 2]):
		pass
	
	if c.has_reached([WEAPON, 1, ARM, 1]):
		c.ability({
			NAME : "%s Handed Swing" % c.tags()[ARM],
			DESC : "Swing",
			EFFECT : func(e: Effector):
				pass
		})
	
	if c.has_reached([ARM, 3, STUN, 1]):
		c.ability({
			NAME : "Sucker Punch",
			DESC : "Sucker",
			EFFECT : func(e: Effector):
				pass
		})
	
	if c.has_reached([ARM, 3]):
		c.ability({
			NAME : "Consecutive Punch",
			DESC : "Punch",
			EFFECT : func(e: Effector):
				pass
		})
	
	
	if c.has_reached([LEG, 3]):
		c.ability({
			NAME : "Consecutive Kick",
			DESC : "Kick your opponent with all your legs!\nDeal 10 damage per legs (%s)." % (c.tags().get(LEG) * 10),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[LEG] * 10);
		});
	
	# fallbacks
	if c.has_reached([MOUTH, 1]):
		c.ability({
			NAME : "Insult",
			DESC : "ya mom",
			EFFECT : func(e: Effector):
				pass
		})
	
	if c.has_reached([EYES, 1]):
		c.ability({
			NAME : "Hard stare",
			DESC : "grr",
			EFFECT : func(e: Effector):
				pass
		})
	
	if c.has_reached([WINGS, 1]):
		pass
	
	if c.has_reached([ARM, 1]):
		c.ability({
			NAME : "Punch",
			DESC : "Punch",
			EFFECT : func(e: Effector):
				pass
		})
	
	if c.has_reached([LEG, 1]):
		c.ability({
			NAME : "Kick",
			DESC : "Kick your opponent!\nDeal 5 damage per legs (%s)." % (c.tags().get(LEG) * 5),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[LEG] * 5);
		});

class MergeResult:
	var merged: Dictionary;
	var anything_upgraded: bool;
static func _merge_tags(previous: Dictionary, new_tags: Dictionary, add_keys: bool) -> MergeResult:
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
		
		if add_keys && !has_added_tag:
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
