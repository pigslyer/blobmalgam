class_name NormalLeg
extends Limb

func debug_name() -> String:
	return "Normal Leg";

func tags() -> Dictionary:
	return {
		Ability.NORMAL : 1,
		Ability.LEG : 1,
	}
