class_name Cute
extends Object

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Cute Leg",
		Ability.DESC : "Dunno how to sound cute about this without being disingenious.",
		
		Ability.CUTE : 2,
		Ability.LEG : 1,
	});

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Cute Arm",
		Ability.DESC : "Dunno how to sound cute about this without being disingenious.",
		Ability.CUTE : 1,
		Ability.ARM : 1,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Cute Eyes",
		Ability.DESC : "Dunno how to sound cute about these without being disingenious.",
		Ability.IMAGE: preload("res://assets/cute_eyes.png"),
		
		Ability.CUTE : 3,
		Ability.EYES : 2,
		Ability.STUN : 2,
	});

static func wings() -> Limb:
	return Limb.new({
		Ability.NAME : "Cute Wings",
		Ability.DESC : "Dunno how to sound cute about these without being disingenious.",
		Ability.CUTE : 1,
		Ability.WINGS : 2,
	})

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Cute Mouth",
		Ability.DESC : "Dunno how to sound cute about these without being disingenious.",
		Ability.IMAGE: preload("res://assets/cute_mouth.png"),
		
		Ability.CUTE : 2,
		Ability.MOUTH : 4,
		Ability.STUN : 5,
	})

static func cat_ears() -> Limb:
	return Limb.new({
		Ability.NAME : "Cat Ears",
		Ability.DESC : "Dunno how to sound cute about these without being disingenious.",
		Ability.CUTE : 5,
	});
