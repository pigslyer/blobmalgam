class_name Pixel
extends Limb

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Pixel Leg",
		Ability.DESC : "Dunno how to sound cute about this without being disingenious.",
		Ability.IMAGE : preload("res://assets/pixel_leg.png"),
		
		Ability.PIXEL : 1,
		Ability.LEG : 2,
	});

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Pixel Arm",
		Ability.DESC : "Dunno how to sound cute about this without being disingenious.",
		Ability.IMAGE : preload("res://assets/pixel_arm.png"),
		
		Ability.PIXEL : 1,
		Ability.ARM : 2,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Pixel Eyes",
		Ability.DESC : "A pair of pixelated eyes. Half as effective as Normal Eyes, because of the lower resolution these can see.",
		Ability.IMAGE : preload("res://assets/pixel_eyes.png"),
		
		Ability.PIXEL : 1,
		Ability.EYES : 1,
	});

static func wings() -> Limb:
	return Limb.new({
		Ability.NAME : "Pixel Wings",
		Ability.DESC : "The least effective wings, due to their weight and lack of aerodynamics.",
		Ability.IMAGE : preload("res://assets/pixel_wing.png"),
		
		Ability.PIXEL : 1,
		Ability.WINGS : 1,
	})

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Pixel Mouth",
		Ability.DESC : "The teeth are FAR sharper than normal ones.",
		Ability.IMAGE : preload("res://assets/pixel_mouth.png"),
		
		Ability.PIXEL : 1,
		Ability.MOUTH : 2,
	})
