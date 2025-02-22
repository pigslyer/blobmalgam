class_name Monster
extends Limb

static func leg() -> Limb:
	return Limb.new({
		Ability.NAME : "Monsterous Leg",
		Ability.DESC : "This'll have to be based on the art",
		Ability.IMAGE : preload("res://assets/monstrous_leg.png"),
		
		Ability.MONSTER : 1,
		Ability.LEG : 3,
		Ability.STUN : 2,
	})

static func arm() -> Limb:
	return Limb.new({
		Ability.NAME : "Monster Arm",
		Ability.DESC : "This'll have to be based on the art",
		Ability.IMAGE : preload("res://assets/monstrous_arm.png"),
		
		Ability.MONSTER : 1,
		Ability.ARM : 3,
		Ability.BLEED : 4,
	})

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Monster Eyes",
		Ability.DESC : "They glow in the dark.",
		Ability.IMAGE : preload("res://assets/monstrous_eyes.png"),
		
		Ability.MONSTER : 1,
		Ability.EYES : 4,
		Ability.STUN : 5,
	})

static func wings() -> Limb:
	return Limb.new({
		Ability.NAME : "Monsterous Wings",
		Ability.DESC : "This'll have to be based on the art",
		Ability.IMAGE : preload("res://assets/monstrous_wings.png"),
		
		Ability.MONSTER : 1,
		Ability.WINGS : 4,
	})

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Monster Mouth",
		Ability.DESC : "This'll have to be based on the art",
		Ability.IMAGE : preload("res://assets/monstrous_mouth.png"),
		
		Ability.MONSTER : 1,
		Ability.MOUTH : 2,
		Ability.CONSUMING : 3,
	})

static func tail() -> Limb:
	return Limb.new({
		Ability.NAME : "Monster Tail",
		Ability.DESC : "This'll have to be based on the art",
		Ability.IMAGE : preload("res://assets/monstrous_tail.png"),
		
		Ability.MONSTER : 1,
		Ability.POISON : 5,
	})
