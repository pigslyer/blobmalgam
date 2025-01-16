class_name ExportedAmalgam
extends Node2D

func display_amalgam(amalgam: Amalgam) -> void:
	if len(amalgam.blobs) == 0:
		push_warning("Nope");
		return;
	
	spawn_blob(amalgam.blobs[0], Vector2.ZERO, Vector2.UP);
	

func spawn_blob(blob: Blob, pos: Vector2, dir: Vector2):
	
	pass
