class_name Medieval
extends Limb

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Medieval Leg",
		Ability.DESC : "A leg clad in fine armor. Kicking someone has never hurt this much.",
		Ability.IMAGE : preload("res://assets/medieval_leg_plate_temp.png"),
		
		Ability.MEDIEVAL : 1,
		Ability.LEG : 2,
		Ability.STUN : 1,
	})

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Medieval Sword Arm",
		Ability.DESC : "The sharpest blade to have been forged in all the land!",
		Ability.IMAGE : preload("res://assets/medieval_arm_plate_temp.png"),
		
		
		Ability.MEDIEVAL : 1,
		Ability.ARM : 2,
		Ability.WEAPON : 1, # maybe store string?
	})

static func cape() -> Limb:
	return Limb.new({
		Ability.NAME : "Medival Cape",
		Ability.DESC : "Is not practical in the least, but looks DAMN fabulous (increases end of fight score).",
		Ability.IMAGE : preload("res://assets/medieval_misc_temp.png"),
		
		Ability.MEDIEVAL : 1,
		Ability.SCORE_MULT : 1.1,
	})
