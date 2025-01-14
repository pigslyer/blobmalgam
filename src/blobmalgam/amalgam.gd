class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];

class CombatActionFrame:
	var abilities: Array[Dictionary];

func get_combat_display_actions_simult(
	rng: RandomNumberGenerator,
	base_draw_count: int
) -> Array[Dictionary]:
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var cards: Array[Dictionary] = [Ability.exchange(self), Ability.bodyslam(self)];
	for limb in limbs:
		var ability: Dictionary = Ability.craft_ability(limb.tags);
		
		if ability == null:
			push_warning("Did not generate initial card from %s" % limb.tags);
			continue;
		
		cards.append(ability);
	
	print("Initial cards:\n%s" % cards);
	
	for i in len(cards):
		var accumulated_tags := { };
		
		var cur_card: Dictionary = cards[i];
		for j in len(cards):
			if i == j:
				continue;
			
			for tag in cards[j].keys():
				if !tag in cur_card:
					continue;
				
				var prev_val = cur_card[tag];
				
				var is_accumable: bool = prev_val is int || prev_val is float;
				if !is_accumable:
					continue;
				
				cur_card[tag] += cards[j][tag];
	
	print("Accumulated cards:\n%s" % cards);
	
	for i in len(cards):
		cards[i] = Ability.craft_ability(cards[i]);
	
	return cards;

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
			var upgraded_ability := Ability.upgrade(ability, active_tags);
			any_upgraded = any_upgraded || (ability != upgraded_ability);
			
			next_frame.abilities.append(upgraded_ability);
		
		if !any_upgraded:
			var new_ability := Ability.upgrade({}, active_tags);
			
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
