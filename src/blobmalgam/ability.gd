class_name Ability
extends Object

const NAME = "display_name";
const DESC_SHORT = "desc_short";
const DESC = "desc";
const IMAGE = "blob_images";
const EFFECT = "card_effect";

const DAMAGE_PREVIEW = "damage_preview";
const STUN_PREVIEW = "stun_preview";
const POISON_PREVIEW = "poison_preview";

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
const ARMOR = "armored";


const BODYSLAM = "bodyslam_ability";
const EXCHANGE = "exchange_ability";
const WEAPON = "weapon_ability";

const ANIM_SLASH = "animation_slash";
const ANIM_HEAL = "animation_heal";

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
		
		await _resolver.damage_blob(blob, amount, userdata);
	
	
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
	
	func confirm_player(_userdata: Dictionary) -> bool:
		return len(await blobs_on(me, 1)) > 0;
	
	func confirm_enemy(_userdata: Dictionary) -> bool:
		return len(await blobs_on(them, 1)) > 0;
	
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

class DescBuilder:
	var me: Amalgam;
	var them: Amalgam;
	var tags: Dictionary;

static func bodyslam() -> Dictionary:
	const BODYSLAM_DAMAGE: int = 10;
	
	return {
		NAME : "Bodyslam",
		DESC : "Your body is your weapon! Deal %d damage per blob." % BODYSLAM_DAMAGE,
		DAMAGE_PREVIEW: func(d: DescBuilder):
			return str(BODYSLAM_DAMAGE * len(d.me.blobs)),
		BODYSLAM : "1",
		WINGS : 0,
		EFFECT : func(e: Effector):
			await e.damage_blob(await e.blob_on(e.them), len(e.me.blobs) * BODYSLAM_DAMAGE);
	}

static func exchange() -> Dictionary:
	const EXCHANGE_DESC_SHORT = "Swap parts with opponent.";
	
	return {
		NAME : "Exchange",
		DESC_SHORT: EXCHANGE_DESC_SHORT,
		DESC : EXCHANGE_DESC_SHORT,
		EXCHANGE : "1",
		GRABBY : 0,
		EFFECT: func(e: Effector):
			var enemy_limb: Limb = await e.limb_on(e.them);
			var player_limb: Limb = await e.limb_on(e.me);
			
			await e.swap_limbs(enemy_limb, player_limb, { });
	}

static func non_dup_from(tag_aggregations: Array[Dictionary]) -> Array[Dictionary]:
	var crafter := Crafter.new();
	_upgrade_crafter(crafter);
	
	var per_tag_valids: Array[Array];
	for agg in tag_aggregations:
		per_tag_valids.append(crafter.crafted_indecies(agg));
	
	var flattened_ids: Array[int];
	flattened_ids.assign(_merge_deduped(per_tag_valids));
	flattened_ids.sort();
	
	var used: Array[bool] = [];
	used.resize(len(tag_aggregations));
	
	var chosen_ability: Array[Dictionary];
	chosen_ability.resize(len(used));
	chosen_ability.fill({ });
	
	for id in flattened_ids:
		for i in len(used):
			# this has already had a higher priority ability chosen
			if used[i]:
				continue;
			
			# this tag aggregation cannot become this ability
			if per_tag_valids[i].find(id) == -1:
				continue;
			
			used[i] = true;
			chosen_ability[i] = crafter.defined()[id].duplicate(true);
			chosen_ability[i].merge(tag_aggregations[i]);
			break;
	
	return chosen_ability;

static func _merge_deduped(arr: Array[Array]) -> Array:
	var existing: Dictionary;
	var ret: Array;
	
	for subarr in arr:
		for el in subarr:
			if el in existing:
				continue;
			
			existing[el] = true;
			ret.append(el);
	
	return ret;

class Crafter:
	var _ability_requirements: Array[Array];
	var _defined_abilities: Array[Dictionary];
	
	func ability(condition: Array, dict: Dictionary) -> void:
		_ability_requirements.append(condition);
		_defined_abilities.append(dict);
	
	func crafted_indecies(ingredients: Dictionary) -> Array[int]:
		var ret: Array[int] = [];
		for i in len(_defined_abilities):
			if _has_reached(ingredients, _ability_requirements[i]):
				ret.append(i);
		
		return ret;
	
	func defined() -> Array[Dictionary]:
		return _defined_abilities;
	
	
	func _has_reached(ingredients: Dictionary, rq: Array) -> bool:
		for i in range(0, len(rq), 2):
			var key = rq[i + 0];
			var value = rq[i + 1];
			
			var present_ingredient = ingredients.get(key, null);
			
			var is_acc: bool = present_ingredient is int || present_ingredient is float;
			if !is_acc:
				if value == null && key in ingredients:
					continue;
				else:
					return false;
			
			var is_enough_now: bool = present_ingredient >= value;
			if !is_enough_now:
				return false;
		
		return true;

# delete this to get compiler errors wherever TODO was used
const TODO = "todo";

static func _upgrade_crafter(c: Crafter) -> void:
	# EXCHANGE SPECIALIZATION
	if true:
		c.ability(
			[
				EXCHANGE, null,
				GRABBY, 1,
			],
			{
				NAME : "Shakedown",
				DESC : TODO,
				DESC_SHORT: "Swap limbs and damage blob!",
				DAMAGE_PREVIEW: func(d: DescBuilder):
					return "%d" % (d.tags[GRABBY] * 20),
				EFFECT : func(e: Effector):
					var enemy_limb: Limb = await e.limb_on(e.them);
					var player_limb: Limb = await e.limb_on(e.me);
					
					await e.damage_limb_owner(enemy_limb, e.tags[GRABBY] * 20, { });
					await e.swap_limbs(enemy_limb, player_limb, { });
		})
		
		c.ability([EXCHANGE, null], exchange());
	
	# BODYSLAM SPECIALIZATION
	if true:
		c.ability(
			[
				BODYSLAM, null,
				WINGS, 1
			],
			{
			NAME : "Flying Bodyslam",
			DESC : TODO,
			DAMAGE_PREVIEW: func(d: DescBuilder):
				return str(len(d.me.blobs) * 20 + d.tags[WINGS] * 10),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), len(e.me.blobs) * 20 + e.tags[WINGS] * 10);
		});
		
		c.ability([BODYSLAM, null], bodyslam());
	
	c.ability(
		[CYBER, 3],
		{
			NAME : "Overcharge",
			DESC : TODO,
			STUN_PREVIEW: func(_d: DescBuilder):
				return "All",
			EFFECT : func(e: Effector):
				if !await e.confirm_enemy({ }):
					return;
				
				for enemy_blob in e.them.blobs:
					await e.stun_blob(enemy_blob, 1, { }),
		}
	)
	
	c.ability(
		[GRABBY, 1],
		{
			NAME : "Tentacle slap",
			DESC : TODO,
			DESC_SHORT: "May damage self",
			DAMAGE_PREVIEW: func(d: DescBuilder):
				return str(d.tags[GRABBY] * 10),
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
	
	c.ability(
		[
			POISON, 5, 
			MOUTH, 1
		],
		{
			NAME : "Poison Spit",
			DESC : TODO,
			POISON_PREVIEW: func(d: DescBuilder):
				return str(d.tags[POISON] * 10),
			EFFECT : func(e: Effector):
				await e.poison_blob(await e.blob_on(e.them), e.tags[POISON] * 10, { });
	})
	
	c.ability(
		[
			EYES, 1,
			ELDRITCH, 4
		],
		{
			NAME : "The Gaze",
			DESC : TODO,
			STUN_PREVIEW: func(d: DescBuilder):
				return str(d.tags[ELDRITCH]),
			EFFECT : func(e: Effector):
				await e.stun_blob(await e.blob_on(e.them), e.tags[ELDRITCH], { });
	})
	
	c.ability(
		[
			ANGELIC, 3
		],
		{
			NAME : "Light of God",
			DESC : TODO,
			STUN_PREVIEW: func(d: DescBuilder):
				return str(d.tags[ANGELIC] - 2),
			EFFECT : func(e: Effector):
				if !await e.confirm_enemy({ }):
					return;
				
				for blob in e.them.blobs:
					await e.stun_blob(blob, e.tags[ANGELIC] - 2, { }),
		}
	)
	c.ability(
		[
			ARM, 8
		],
		{
			NAME : "Platinum Punches",
			DESC : TODO,
			DAMAGE_PREVIEW : func(d: DescBuilder):
				return "%dx%d" % [d.tags[ARM], 15],
			EFFECT : func(e: Effector):
				var first_target: Blob = await e.blob_on(e.them)
				if first_target == null:
					return;
				
				await e.damage_blob(first_target, 15, { });
				
				for arm in range(e.tags[ARM] - 1):
					await e.damage_blob(await e.blob_on(e.them), 15, { }),
		}
	)
	
	c.ability(
		[
			ARM, 2, 
			CUTE, 1
		],
		{
			NAME : "Cute Hug",
			DESC : TODO,
			STUN_PREVIEW: func(d: DescBuilder):
				return str(d.tags[CUTE]),
			EFFECT : func(e: Effector):
				await e.stun_blob(await e.blob_on(e.them), e.tags[CUTE], { }),
		}
	)
	
	c.ability(
		[
			WINGS, 3, 
			LEG, 3
		],
		{
			NAME : "Triple Frontflip Kick",
			DESC : TODO,
			DAMAGE_PREVIEW: func(d: DescBuilder):
				return "3x%d" % (d.tags[LEG] * 12),
			EFFECT : func(e: Effector):
				var target: Blob = await e.blob(e.them);
				
				for i in 3:
					await e.damage_blob(target, e.tags[LEG] * 12, { }),
		}
	)
	
	c.ability(
		[
			MOUTH, 1, 
			CONSUMING, 1
		],
		{
			NAME : "Consume",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var damage: float = e.tags[CONSUMING] * 6;
				var target: Blob = await e.blob_on(e.them);
				if target == null:
					return;
				
				await e.damage_blob(target, damage);
				
				for mouth in range(e.tags[MOUTH] - 1):
					await e.damage_blob(await e.blob_on(e.them), damage),
		}
	)
	
	c.ability(
		[
			CUTE, 1, 
			MOUTH, 1
		],
		{
		NAME : "Healing Kiss",
		DESC : TODO,
		EFFECT : func(e: Effector):
			var damage: float = e.tags[CUTE] * 6;
			var target: Blob = await e.blob_on(e.me);
			if target == null:
				return;
			
			await e.heal_blob(target, damage, { });
			
			for mouth in range(e.tags[MOUTH] - 1):
				await e.heal_blob(await e.blob_on(e.them), damage, { }),
		}
	)
	
	c.ability(
		[
			CUTE, 4, 
			WINGS, 2,
		],
		{
			NAME : "Adorable Flying Backflip",
			DESC : TODO,
			EFFECT : func(e: Effector):
				if !await e.confirm_enemy({ }):
					return;
				
				for blob in e.me.blobs:
					await e.heal_blob(blob, e.tags[CUTE] * 4, { });
				for blob in e.them.blobs:
					await e.stun_blob(blob, 1, { });
	})
	
	c.ability(
		[
			WEAPON, 1, 
			ARM, 1
		],
		{
			NAME : func(d: DescBuilder):
				return "%s Handed Swing" % d.tags[ARM],
			DESC : TODO,
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[WEAPON] * 4 * e.tags[ARM]),
		}
	)
	
	c.ability(
		[
			ARM, 3, 
			STUN, 1
		],
		{
			NAME : "Sucker Punch",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var target: Blob = await e.blob_on(e.them);
				if target == null:
					return;
				
				await e.damage_blob(target, e.tags[ARM] * 4, { });
				
				var stunned: bool = await e.d20(e.tags[STUN], 14, { });
				if stunned:
					await e.stun_blob(target, 1, { }),
		}
	)
	
	c.ability(
		[
			ARM, 3
		],
		{
			NAME : "Consecutive Punch",
			DESC : TODO,
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[ARM] * 5, { }),
		}
	)
	
	
	c.ability(
		[
			LEG, 3
		],
		{
			NAME : "Consecutive Kick",
			DESC : "Kick your opponent with all your legs!\nDeal 10 damage per legs",
			DAMAGE_PREVIEW: func(d: DescBuilder):
				return str(d.tags[LEG] * 10),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[LEG] * 10),
		}
	);
	
	# fallbacks
	c.ability(
		[
			MOUTH, 1
		],
		{
			NAME : "Insult",
			DESC : TODO,
			EFFECT : func(e: Effector):
				var target: Blob = await e.blob_on(e.them);
				if target == null:
					return;
				
				var stuns: bool = await e.d20(e.tags[MOUTH], 16, { });
				if !stuns:
					return;
				
				await e.stun_blob(target, 1, { });
	})
	
	c.ability(
		[
			EYES, 1
		],
		{
			NAME : "Hard stare",
			DESC : "grr",
			EFFECT : func(e: Effector):
				var target: Blob = await e.blob_on(e.them);
				if target == null:
					return;
				
				var stuns: bool = await e.d20(e.tags[EYES] / 2, 18, { });
				if !stuns:
					return;
				
				await e.stun_blob(target, 1, { });
	})
	
	# i still don't know what to do here
	c.ability(
		[
			WINGS, 1
		],
		{
			NAME : "Harmless Backflip",
			DESC : "I don't know what to put here",
			EFFECT : func(e: Effector):
				var may_backflip: bool = await e.confirm_enemy({ });
				if !may_backflip:
					return;
				
				await e.heal_blob(e.me.blobs[0], 1, { }),
	})
	
	c.ability(
		[
			ARM, 1,
		],
		{
			NAME : "Punch",
			DESC : TODO,
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[ARM] * 5),
		}
	)
	
	c.ability(
		[
			LEG, 1
		],
		{
			NAME : "Kick",
			DESC : "Deal 5 damage per leg.",
			DAMAGE_PREVIEW: func(d: DescBuilder):
				return str(d.tags[LEG] * 5),
			EFFECT : func(e: Effector):
				await e.damage_blob(await e.blob_on(e.them), e.tags[LEG] * 5),
		}
	);

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
