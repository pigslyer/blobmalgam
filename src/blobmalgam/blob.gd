class_name Blob
extends RefCounted

const MAX_HEALTH: float = 100;

var _health: float = MAX_HEALTH;
var _stun: int = 0;
var _poision: int = 0;
var limbs: Array[PositionedLimb];

func add_limb(limb: Limb):
	var pos_limb := PositionedLimb.new();
	pos_limb.position = Vector2.ZERO;
	pos_limb.limb = limb;
	
	limbs.append(pos_limb);

func health() -> float:
	return _health;

func stun() -> int:
	return _stun;

func poison() -> int:
	return _poision;
