class_name Amalgam;
extends RefCounted

var blobs: Array[Blob] = [];

class CombatActionFrame:
	var abilities: Array[Ability];

func get_combat_display_actions(
	rng: RandomNumberGenerator, 
	base_draw_count: int,
) -> Array[CombatActionFrame]:
	var limbs: Array[Limb] = _get_limbs_flat();
	
	var active_limbs: Array[Limb];
	for i in base_draw_count:
		var idx: int = rng.randi() % len(active_limbs);
		
		active_limbs.append(limbs[idx]);
		limbs.remove_at(idx);
	
	
	var frames: Array[CombatActionFrame] = [CombatActionFrame.new()];
	for active_limb in active_limbs:
		var last_frame: CombatActionFrame = frames[-1];
		var next_frame := CombatActionFrame.new();
		
		var any_upgraded := false;
		for ability in last_frame.abilities:
			var upgraded_ability := ability.upgrade(active_limb);
			any_upgraded = any_upgraded || (ability != upgraded_ability);
			
			next_frame.abilities.append(ability);
		
		if !any_upgraded && "Ability" in active_limb.tags():
			pass
		
		frames.append(next_frame);
	
	return frames;

func _get_limbs_flat() -> Array[Limb]:
	var arr: Array[Limb] = [];
	
	for blob in blobs:
		for pos_limb in blob.limbs:
			arr.append(pos_limb.limb);
	
	return arr;
