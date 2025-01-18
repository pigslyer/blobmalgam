extends Node2D

@onready var _player: AmalgamDisplay = %PlayerAmalgam;
@onready var _enemy: AmalgamDisplay = %EnemyAmalgam;

func _generate_player_amalgam() -> Amalgam:
	var amalgam := Amalgam.new();
	var blob := Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.leg());
	blob.add_limb(Normal.mouth());
	blob.add_limb(Normal.eyes());
	return amalgam;

func _generate_enemy_amalgam() -> Amalgam:
	var amalgam := Amalgam.new();
	var blob := Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	
	blob = Blob.new();
	amalgam.blobs.append(blob);
	blob.add_limb(Cyber.arm());
	blob.add_limb(Cute.arm());
	blob.add_limb(Normal.leg());
	blob.add_limb(Pixel.leg());
	blob.add_limb(Eldritch.mouth());
	blob.add_limb(Angelic.eyes());
	return amalgam;


func _ready():
	# _player.connect("blob_pressed", self, "_on_blob_pressed");
	# _player.connect("blob_hovered", self, "_on_blob_hovered");

	# Simulating initial data
	print_debug("ragdoll_test: Generating default player and enemy data");
	var _default_player_data: Amalgam = _generate_player_amalgam();
	_player.display_amalgam(_default_player_data);
	var _default_enemy_data: Amalgam = _generate_enemy_amalgam();
	_enemy.display_amalgam(_default_enemy_data);
