extends Limb
class_name Cyber

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Cyberleg",
		Ability.DESC : "Motors kick into gear to better assist you in kicking ass.",
		Ability.IMAGE : preload("res://assets/cyber - leg.png"),
		
		Ability.CYBER : 1,
		Ability.LEG : 5,
	})

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Cyberarm",
		Ability.DESC : "Stainless steel, stained with blood, muscle and teeth.",
		Ability.IMAGE : preload("res://assets/cyber - arm.png"),
		
		Ability.CYBER : 1,
		Ability.ARM : 5,
		Ability.STUN : 2,
	})

static func gun() -> Limb:
	return Limb.new({
		Ability.NAME : "Cyber Arm-Gun",
		Ability.DESC : "You don't gotta open wide, choom. Head'll be vaporized either way.",
		Ability.IMAGE : preload("res://assets/cyber - arm gun.png"),
		
		Ability.CYBER : 1,
		Ability.ARM : 5,
		Ability.STUN : 2,
		Ability.GUN : 1,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Kiroshi Cybereyes",
		Ability.DESC : "Don't just got eyes on the back of my head, I can see in third person.",
		Ability.IMAGE : preload("res://assets/cyber - eyes.png"),
		
		Ability.CYBER : 1,
		Ability.EYES : 6,
	})

static func jetpack() -> Limb:
	return Limb.new({
		Ability.NAME : "Jetpack",
		Ability.DESC : "The only way to fly is with a jetpack.",
		Ability.IMAGE : preload("res://assets/cyber - jetpack.png"),
		
		Ability.CYBER : 1,
		Ability.WINGS : 5,
	})

#static func reflex_booster() -> Limb:
	#return Limb.new({
		#Ability.NAME : "Reflex Booster",
		#Ability.DESC : "No more doubts, you can make it.",
		#
		#Ability.CYBER : 1,
		#Ability.REFLEX : 1,
	#})
