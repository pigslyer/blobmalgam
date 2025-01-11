class_name NormalLeg
extends Limb

func debug_name() -> String:
	return "Normal Leg";

func combat_abilities(data: Limb.CombatActionData) -> Array[Ability]:
	return [
		NormalKick.new(),
	];

class NormalKick extends Ability:
	func debug_name():
		return "normal_kick";
