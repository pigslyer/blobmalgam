class_name Utils;
extends Object

static func not_implemented(on: Object) -> void:
	var frame = get_stack();
	
	var last = frame[len(frame) - 1 - 1];
	var caller_func: String = last["function"];
	
	var script: Script = on.get_script();
	var script_name: String = script.resource_name;
	
	push_warning("%s has not implemented %s!" % [script_name, caller_func]);
