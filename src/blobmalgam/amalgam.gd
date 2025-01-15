class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];

class CombatActionFrame:
	var abilities: Array[Dictionary];

class SimultResult:
	var original_limbs: Array[Limb];
	var original_cards: Array[Dictionary];
	var combined: Array[Dictionary];
func get_combat_display_actions_simult(
	rng: RandomNumberGenerator,
	base_draw_count: int
) -> SimultResult:
	var res := SimultResult.new();
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var cards: Array[Dictionary] = [Ability.exchange(self), Ability.bodyslam(self)];
	var chosen_limbs: Array[Limb] = [Limb.new({}), Limb.new({})];
	
	var count: int = 0;
	var draw_count := base_draw_count;
	while count < draw_count && 0 < len(limbs): 
		var removed_limb_idx: int = rng.randi() % len(limbs);
		var removed_limb: Limb = limbs[removed_limb_idx];
		limbs.remove_at(removed_limb_idx);
		
		var ability: Dictionary = Ability.craft_ability(self, removed_limb.tags);
		
		if ability == null:
			push_warning("Did not generate initial card from %s" % removed_limb.tags);
			continue;
		
		cards.append(ability);
		chosen_limbs.append(removed_limb);
		count += 1;
	
	res.original_limbs = chosen_limbs;
	res.original_cards = cards.duplicate(true);
	
	for i in len(cards):
		var cur_card: Dictionary = cards[i];
		for j in len(cards):
			if i == j:
				continue;
			
			var may_merge := false;
			for tag in cards[j].keys():
				if !tag in cur_card:
					continue;
				
				var prev_val = res.original_cards[j][tag];
				var is_accumable: bool = prev_val is int || prev_val is float;
				if !is_accumable:
					continue;
				
				may_merge = true;
			
			if !may_merge:
				continue;
			
			for tag in cards[j].keys():
				var prev_val = res.original_cards[j][tag];
				
				var is_accumable: bool = prev_val is int || prev_val is float;
				if !is_accumable:
					continue;
				
				cur_card[tag] += res.original_cards[j][tag];
	
	for i in len(cards):
		cards[i] = Ability.craft_ability(self, cards[i]);
	
	res.combined = cards;
	
	return res;

func get_combat_display_actions(
	rng: RandomNumberGenerator, 
	base_draw_count: int,
) -> Array[CombatActionFrame]:
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var active_limbs: Array[Limb];
	for i in base_draw_count:
		var idx: int = rng.randi() % len(limbs);
		
		active_limbs.append(limbs[idx]);
		limbs.remove_at(idx);
	
	var first_frame := CombatActionFrame.new();
	first_frame.abilities.append(Ability.exchange(self));
	first_frame.abilities.append(Ability.bodyslam(self));
	var frames: Array[CombatActionFrame] = [first_frame];
	for active_limb in active_limbs:
		var last_frame: CombatActionFrame = frames[-1];
		var next_frame := CombatActionFrame.new();
		
		var active_tags = active_limb.tags;
		
		var any_upgraded := false;
		for ability in last_frame.abilities:
			var upgraded_ability := Ability.upgrade(self, ability, active_tags);
			any_upgraded = any_upgraded || (ability != upgraded_ability);
			
			next_frame.abilities.append(upgraded_ability);
		
		if !any_upgraded:
			var new_ability := Ability.upgrade(self, {}, active_tags);
			
			if len(new_ability) > 0:
				next_frame.abilities.append(new_ability);
		
		frames.append(next_frame);
	
	return frames;

func _get_limbs_flat() -> Array[Limb]:
	var arr: Array[Limb] = [];
	
	for blob in blobs:
		for pos_limb in blob.limbs:
			arr.append(pos_limb.limb);
	
	return arr;
