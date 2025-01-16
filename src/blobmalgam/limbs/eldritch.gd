class_name Eldritch
extends Limb

static func tentacle() -> Limb:
	return Limb.new({
		Ability.NAME : "Tentacle",
		Ability.DESC : "Appendage",
		Ability.ELDRITCH : 1,
		Ability.STUN : 6,
		Ability.THROW : 6,
		Ability.ARM : 4,
		Ability.LEG : 4,
		Ability.GRABBY : 2,
	});

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Hole in the World",
		Ability.DESC : "Gaze not into the abyss.",
		Ability.ELDRITCH : 2,
		Ability.EYES : 4,
		Ability.STUN : 6,
	})

static func wings() -> Limb:
	return Limb.new({
		Ability.NAME : "Great One's Wings",
		Ability.DESC : "Their beating can be heard from miles off.",
		Ability.ELDRITCH : 1,
		Ability.WINGS : 8,
	});

static func mouth() -> Limb:
	return Limb.new({
		Ability.NAME : "Consuming Mouth",
		Ability.DESC : "Consumes all.",
		Ability.ELDRITCH : 1,
		Ability.CONSUMING : 1,
		Ability.MOUTH : 4,
	})
