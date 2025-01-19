class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];
var links: Array[Link] = [];

class Link:
	var from_idx: int;
	var from_local_pos: Vector2;
	
	var to_idx: int;
	var to_local_pos: Vector2;

func combat_display_actions_simult_flattened(
	rng: RandomNumberGenerator,
	draw_count: int,
	include_base: bool,
) -> Array[Dictionary]:
	var limbs: Array[Limb] = alive_limbs_flat();
	
	var original_tags: Array[Dictionary];
	if include_base:
		original_tags.append(Ability.exchange());
		original_tags.append(Ability.bodyslam());
	
	for i in min(len(limbs), draw_count):
		var removed_limb_idx := rng.randi() % len(limbs);
		var removed_limb: Limb = limbs[removed_limb_idx];
		limbs.remove_at(removed_limb_idx);
		
		var is_stunned: bool = false;
		for blob in blobs:
			if is_stunned:
				break;
			
			if blob.stun() == 0:
				continue;
			
			for limb in blob.limbs:
				if removed_limb == limb.limb:
					is_stunned = true;
					blob._stun -= 1;
		
		if !is_stunned:
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

func full_heal() -> void:
	for blob in blobs:
		if blob._health > 0:
			blob._health = Blob.MAX_HEALTH;
		blob._stun = 0;
		blob._poision = 0;

func total_global_health() -> float:
	if len(blobs) <= 2:
		return len(blobs) * Blob.MAX_HEALTH;
	else:
		return len(blobs) * Blob.MAX_HEALTH * 0.6667;

func current_global_health() -> float:
	var total: float = 0;
	for blob in blobs:
		total += blob.health();
	
	return total / (len(blobs) * Blob.MAX_HEALTH) * total_global_health();

func alive_limbs_flat() -> Array[Limb]:
	var arr: Array[Limb] = [];
	
	for blob in blobs:
		if blob.health() <= 0:
			continue;
		
		for pos_limb in blob.limbs:
			arr.append(pos_limb.limb);
	
	return arr;

func linked_blobs(linked_to: Blob) -> Array[Blob]:
	var ret: Array[Blob] = [];
	
	for link in links:
		if blobs[link.from_idx] == linked_to:
			ret.append(blobs[link.to_idx]);
		if blobs[link.to_idx] == linked_to:
			ret.append(blobs[link.from_idx]);
	
	return ret;
	
