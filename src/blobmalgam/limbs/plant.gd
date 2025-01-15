class_name Plant
extends Limb

static func tentacle() -> Limb:
	return Limb.new({
		Ability.NAME : "Organic Tentacle",
		Ability.DESC : "Plant",
		Ability.PLANT : 1,
		Ability.ARM : 3,
		Ability.LEG : 3,
		Ability.STUN : 4,
		Ability.POISON : 3,
		Ability.GRABBY : 2,
	})

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Organic Mouth",
		Ability.DESC : "Plant",
		Ability.PLANT : 1,
		Ability.MOUTH : 4,
		Ability.POISON : 6,
	})

static func flower() -> Limb:
	return Limb.new({
		Ability.NAME : "Organic Flower",
		Ability.DESC : "Plant",
		Ability.PLANT : 4,
		Ability.POISON : 8,
	})
