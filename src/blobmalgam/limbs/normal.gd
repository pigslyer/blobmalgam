class_name Normal
extends Limb

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Normal Leg",
		Ability.DESC : "A perfectly normal leg. Capable of kicking and jumping.",
		Ability.IMAGE : preload("res://assets/normal_leg.png"),
		
		Ability.NORMAL : 1,
		Ability.LEG : 1,
	});

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Normal Arm",
		Ability.DESC : "An absolutely average arm. Can punch someone's lights out.",
		Ability.IMAGE : preload("res://assets/normal_arm.png"),
		
		
		Ability.NORMAL : 1,
		Ability.ARM : 1,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Normal Eyes",
		Ability.DESC : "A working pair of eyes. You can see. Helps for spotting weakness.",
		Ability.IMAGE : preload("res://assets/normal_eyes.png"),
		
		Ability.NORMAL : 1,
		Ability.EYES : 2,
	})

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Normal Mouth",
		Ability.DESC : "A capable mouth powered by a functional jaw. You can bite, and you can talk.",
		Ability.IMAGE : preload("res://assets/normal_mouth.png"),
		
		Ability.NORMAL : 1,
		Ability.MOUTH : 1,
	})
