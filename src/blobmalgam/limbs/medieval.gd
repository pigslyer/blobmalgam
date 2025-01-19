class_name Medieval
extends Limb

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Medieval Leg",
		Ability.DESC : "A leg clad in fine armor. Kicking someone has never hurt this much.",
		Ability.IMAGE : preload("res://assets/medieval_leg.png"),
		
		Ability.MEDIEVAL : 1,
		Ability.LEG : 2,
		Ability.ARMOR : 10,
		Ability.STUN : 1,
	})

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Medieval Sword Arm",
		Ability.DESC : "The sharpest blade to have been forged in all the land!",
		Ability.IMAGE : preload("res://assets/medieval_arm.png"),
		
		Ability.MEDIEVAL : 1,
		Ability.ARM : 2,
		Ability.ARMOR : 10,
		Ability.WEAPON : 1, # maybe store string?
	})

static func cape() -> Limb:
	return Limb.new({
		Ability.NAME : "Medival Cape",
		Ability.DESC : "Is not practical in the least, but looks DAMN fabulous.",
		Ability.IMAGE : preload("res://assets/medieval_misc1.png"),
		
		Ability.MEDIEVAL : 2,
		Ability.SCORE_MULT : 1.1,
	})

static func crown() -> Limb:
	return Limb.new({
		Ability.NAME : "Medieval King's Head",
		Ability.DESC : "Looks damn fabulous, not much else though.",
		Ability.IMAGE : preload("res://assets/medieval_misc2.png"),
		
		Ability.ARMOR : 10,
		Ability.MEDIEVAL : 1,
		Ability.EYES : 2,
		Ability.SCORE_MULT : 1.1,
	})
	
static func helmet() -> Limb:
	return Limb.new({
		Ability.NAME : "Medival Helmet",
		Ability.DESC : "Grants excellent protection for your head, at the cost of making it harder to see.",
		Ability.IMAGE : preload("res://assets/medieval_helmet.png"),
		
		Ability.ARMOR : 20,
		Ability.MEDIEVAL : 1,
		Ability.EYES : -2,
		Ability.SCORE_MULT : 1.1,
	})
