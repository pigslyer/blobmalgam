class_name Limb;
extends RefCounted

const NAME = "display_name";
const DESC = "desc";

const ARM = "arm";
const LEG = "leg";
const EYES = "eyes";
const WINGS = "wings";
const TAIL = "tail";

const NORMAL = "normal";
const PIXEL = "pixel";

const BODYSLAM = "bodyslam_ability";


func tags() -> Dictionary:
	Utils.not_implemented(self);
	return { };

func debug_name() -> String:
	Utils.not_implemented(self);
	
	return "<none>";

static func bodyslam_ability() -> Dictionary:
	return {
		NAME : "Bodyslam",
		DESC : "Your body is your weapon!",
		BODYSLAM : 1,
	}

static func upgrade_ability(previous: Dictionary, new_tags: Dictionary) -> Dictionary:
	var merge_result: MergeResult = _merge_tags(previous, new_tags);
	
	if len(previous) > 0 && !merge_result.anything_upgraded:
		return previous;
	
	var merged := merge_result.merged;
	
	var newly_reached = func(key, value):
		var is_enough_now: bool = merged.get(key, 0) >= value;
		
		if !is_enough_now:
			return false;
		
		var was_enough_before = previous.get(key, 0) >= value;
		
		if was_enough_before:
			return;
		
		return true;
	
	var ability = func(ability_def: Dictionary) -> Dictionary:
		ability_def.merge(merged);
		
		return ability_def;
	
	
	if BODYSLAM in merged:
		if newly_reached.call(WINGS, 1):
			return ability.call({
				NAME : "Flying Bodyslam",
				DESC : "BECOME BULLET.",
			});
		
		return previous;
	
	if newly_reached.call(LEG, 3):
		return ability.call({
			NAME : "Consecutive normal kick",
			DESC : "Kick your opponent with all your legs!",
		});
	
	if newly_reached.call(LEG, 1):
		return ability.call({
			NAME : "Kick",
			DESC : "Kick your opponent!",
		});
	
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
