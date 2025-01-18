class_name Angelic
extends Limb

static func eyes() -> Limb:
	return Limb.new({
		Ability.NAME : "Angelic Eyes",
		Ability.DESC : "They see All.",
		Ability.IMAGE : [ 
			preload("res://assets/angelic_eyes_1.png"), 
			preload("res://assets/angelic_eyes_2.png"),
		].pick_random(),
		
		Ability.ANGELIC : 1,
		Ability.EYES : 10,
		Ability.STUN : 10,
	});

static func wings() -> Limb:
	return Limb.new({
		Ability.NAME : "Angelic Wings",
		Ability.DESC : "God's Wrath is coming, fast.",
		Ability.IMAGE : preload("res://assets/angelic_wings.png"),
		
		Ability.ANGELIC : 1,
		Ability.WINGS : 10,
		Ability.STUN : 10,
	});
