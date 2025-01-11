class_name Ability
extends RefCounted

var _tags: Dictionary = { };

func debug_name() -> String:
	Utils.not_implemented(self);
	
	return "";

func upgrade(limb: Limb) -> Ability:
	Utils.not_implemented(self);
	
	return self;

func clone() -> Ability:
	var clone = ClassDB.instantiate(get_class());
	clone._tags = _tags.duplicate();
	return clone;
