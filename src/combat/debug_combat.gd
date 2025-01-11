extends Control

var player_amalgam: Amalgam;

@export var player_view: DebugAmalgamView;

func _ready() -> void:
	reset_amalgams();

func draw_player_abilities():
	var rng := RandomNumberGenerator.new();
	var actions = player_amalgam.get_combat_display_actions(rng, 5);
	
	player_view.display_actions(actions);

func reset_amalgams():
	player_amalgam = Amalgam.new();
	
	var blob1 := Blob.new();
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	player_amalgam.blobs.append(blob1);
	
	blob1 = Blob.new();
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	blob1.add_limb(NormalLeg.new());
	player_amalgam.blobs.append(blob1);
	
	player_view.display_amalgam(player_amalgam);
