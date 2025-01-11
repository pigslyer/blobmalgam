class_name Blob
extends RefCounted

var health: int = 100;
var limbs: Array[PositionedLimb];

class PositionedLimb:
	var position: Vector2;
	var limb: Limb;

func add_limb(limb: Limb):
	var pos_limb := PositionedLimb.new();
	pos_limb.position = Vector2.ZERO;
	pos_limb.limb = limb;
	
	limbs.append(pos_limb);
