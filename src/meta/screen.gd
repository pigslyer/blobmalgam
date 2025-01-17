extends Control

var player: Amalgam;
var boss: Amalgam;

@onready var main_menu: Control = $MainMenu;
@onready var fight: BattleScreen = $Fight;

@onready var fade: ColorRect = $FadeOut;
@onready var fade_text: Label = $FadeOut/Label;

@onready var current_background: TextureRect = $ShiftingBackgrounds/CurrentBackground;
@onready var next_background: TextureRect = $ShiftingBackgrounds/NextBackground;

func _ready():
	_apply_volume_to_bus("Master", 1);
	_apply_volume_to_bus("Effects", 1);
	_apply_volume_to_bus("Music", 1);

func _on_start_pressed() -> void:
	player = Utils.default_amalgam();
	boss = Utils.default_amalgam();
	
	if false:
		main_menu.hide();
		await _opening_animation();
		await _shift_backgrounds(preload("res://assets/ozadje3.png"));
		
		fade.show();
		fade_text.text = "";
		
		const FADE_OUT_TIME = 0.2;
		var tween := create_tween();
		tween.tween_property(fade, "modulate", Color.WHITE, FADE_OUT_TIME);
		await tween.finished;
		
	main_menu.hide();
	fight.show();
	
	if false:
		var tween := create_tween();
		
		const FADE_IN_TIME = 0.2;
		tween.tween_property(fade, "modulate", Color.TRANSPARENT, FADE_IN_TIME);
		await tween.finished;
		fade.hide();
	
	fight.player_won.connect(_player_won);
	fight.player_lost.connect(_player_lost);
	fight.begin_fight(player, boss);

func _player_won() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	print("you won!");

func _player_lost() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	print("you lost!");

func _on_master_slider_value_changed(value: float) -> void:
	_apply_volume_to_bus("Master", value);

func _on_sfx_slider_value_changed(value: float) -> void:
	_apply_volume_to_bus("Effects", value);

func _on_music_slider_value_changed(value: float) -> void:
	_apply_volume_to_bus("Music", value);

func _apply_volume_to_bus(bus: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(value));

func _shift_backgrounds(to: Texture) -> void:
	next_background.texture = to;
	
	const SHIFT_SPEED = 0.6;
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(current_background, "anchor_left", -1.0, SHIFT_SPEED);
	tween.tween_property(current_background, "anchor_right", 0.0, SHIFT_SPEED);
	tween.tween_property(next_background, "anchor_left", 0.0, SHIFT_SPEED);
	tween.tween_property(next_background, "anchor_right", 1.0, SHIFT_SPEED);
	
	await tween.finished;
	
	current_background.anchor_left = 1.0;
	current_background.anchor_right = 2.0;
	
	var temp = current_background;
	current_background = next_background;
	next_background = temp;


func _opening_animation() -> void:
	const PLAYER_RAISE_TIME = 0.5;
	const BOSS_RAISE_TIME = 1.4;
	
	var player_ragdoll: PlayerAmalgam = $Opening/Player;
	var boss_ragdoll: PlayerAmalgam = $Opening/Boss;
	var player_start: Vector2 = player_ragdoll.position;
	var boss_start: Vector2 = boss_ragdoll.position;
	var player_end: Vector2 = $Opening/PlayerEnd.position;
	var boss_end: Vector2 = $Opening/BossEnd.position;
	
	var player_text: RichTextLabel = $Opening/PlayerText;
	var boss_text: RichTextLabel = $Opening/BossText;
	
	player_ragdoll.display_amalgam(player);
	boss_ragdoll.display_amalgam(boss);
	player_ragdoll.idle(PlayerAmalgam.IdleKinds.None);
	boss_ragdoll.idle(PlayerAmalgam.IdleKinds.None);
	
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC);
	
	tween.tween_property(player_ragdoll, "position", player_end, PLAYER_RAISE_TIME);
	tween.parallel().tween_property(player_text, "modulate", Color.WHITE, PLAYER_RAISE_TIME);
	
	tween.tween_property(boss_ragdoll, "position", boss_end, BOSS_RAISE_TIME);
	tween.parallel().tween_property(boss_text, "modulate", Color.WHITE, BOSS_RAISE_TIME);
	
	tween.tween_property(self, "modulate", Color.WHITE, 1);
	
	await tween.finished;
	tween = create_tween();
	
	tween.tween_property(player_ragdoll, "scale", Vector2(0.1, 0.1), 0.4);
	tween.parallel().tween_property(player_ragdoll, "position", Vector2(-200, 0), 1);
	tween.parallel().tween_property(player_ragdoll, "rotation", TAU * 10, 1);
	
	tween.parallel().tween_property(boss_ragdoll, "scale", Vector2(0.1, 0.1), 0.4);
	tween.parallel().tween_property(boss_ragdoll, "position", Vector2(2000, 0), 1);
	tween.parallel().tween_property(boss_ragdoll, "rotation", TAU * 10, 1);
	
	tween.parallel().tween_property(player_text, "modulate", Color.TRANSPARENT, 0.3);
	tween.parallel().tween_property(boss_text, "modulate", Color.TRANSPARENT, 0.3);
	
	tween.tween_callback(func():
		player_ragdoll.position = player_start;
		player_ragdoll.scale = Vector2.ONE;
		player_ragdoll.rotation = 0;
		
		boss_ragdoll.position = boss_start;
		boss_ragdoll.scale = Vector2.ONE;
		boss_ragdoll.rotation = 0;
	);
