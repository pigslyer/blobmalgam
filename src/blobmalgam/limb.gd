class_name Limb
extends RefCounted

var tags: Dictionary;

@warning_ignore("shadowed_variable")
func _init(tags: Dictionary):
	self.tags = tags;
	tags.make_read_only();
