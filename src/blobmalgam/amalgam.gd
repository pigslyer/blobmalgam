class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];

func get_combat_display_actions(
	rng: RandomNumberGenerator, 
	ability_count: int,
) -> Array[CombatAction]:
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var active_limbs: Array[Limb];
	
	for i in ability_count:
		var idx: int = rng.randi() % len(active_limbs);
		
		active_limbs.append(limbs[idx]);
		limbs.remove_at(idx);
	
	return [];

func _get_limbs_flat() -> Array[Limb]:
	var arr: Array[Limb] = [];
	
	for blob in blobs:
		for pos_limb in blob.limbs:
			arr.append(pos_limb.limb);
	
	return arr;
