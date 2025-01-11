class_name Limb;
extends RefCounted

func debug_name() -> String:
	Utils.not_implemented(self);
	
	return "<none>";

class CombatActionData:
	pass

func combat_actions(data: CombatActionData) -> Array[CombatAction]:
	Utils.not_implemented(self);
	
	return [];
