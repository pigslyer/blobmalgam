class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];

func combat_display_actions_simult_flattened(
	rng: RandomNumberGenerator,
	draw_count: int
) -> Array[Dictionary]:
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var original_tags: Array[Dictionary] = [Ability.exchange(), Ability.bodyslam()];
	
	for i in draw_count:
		var removed_limb_idx := rng.randi() % len(limbs);
		var removed_limb: Limb = limbs[removed_limb_idx];
		limbs.remove_at(removed_limb_idx);
		
		original_tags.append(removed_limb.tags);
	
	var combined_tags: Array[Dictionary];
	for i in len(original_tags):
		var acc: Dictionary = original_tags[i].duplicate(true);
		
		for j in len(original_tags):
			if i == j:
				continue;
			
			var may_merge := false;
			for tag in original_tags[i].keys():
				if !tag in original_tags[j]:
					continue;
				
				var prev_val = original_tags[j][tag];
				var is_accumable: bool = prev_val is int || prev_val is float;
				if !is_accumable:
					continue;
				
				may_merge = true;
			
			if !may_merge:
				continue;
			
			for tag in original_tags[j].keys():
				var prev_val = original_tags[j][tag];
				var is_accumable: bool = prev_val is int || prev_val is float;
				if !is_accumable:
					continue;
				
				if tag in acc:
					acc[tag] += prev_val;
				else:
					acc[tag] = prev_val;
		
		combined_tags.append(acc);
	
	return Ability.non_dup_from(combined_tags);


func _get_limbs_flat() -> Array[Limb]:
	var arr: Array[Limb] = [];
	
	for blob in blobs:
		for pos_limb in blob.limbs:
			arr.append(pos_limb.limb);
	
	return arr;
