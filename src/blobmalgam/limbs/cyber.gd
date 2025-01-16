extends Limb
class_name Cyber

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Cyberleg",
		Ability.DESC : "Will depend on art",
		Ability.CYBER : 1,
		Ability.LEG : 5,
	})

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Cyberarm",
		Ability.DESC : "Will depend on arm",
		Ability.CYBER : 1,
		Ability.ARM : 5,
		Ability.STUN : 2,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Kiroshi Cybereyes",
		Ability.DESC : 
			"\"Sometimes late at night, I'll pass a window with posters of simstim stars, all those beautiful, identical eyes staring back at me out of faces that are nearly identical. Sometimes, the eyes are hers, but none of the faces are, none of them ever are.\"\nBurning Chrome by William Gibson",
		Ability.CYBER : 1,
		Ability.EYES : 6,
	})

static func jetpack() -> Limb:
	return Limb.new({
		Ability.NAME : "Jetpack",
		Ability.DESC : "\"The only way to fly... is with a jetpack.\"-Isabella Bennett",
		Ability.CYBER : 1,
		Ability.WINGS : 5,
	})

static func reflex_booster() -> Limb:
	return Limb.new({
		Ability.NAME : "Reflex Booster",
		Ability.DESC : "No more doubts, you can make it.",
		Ability.CYBER : 1,
		Ability.REFLEX : 1,
	})
