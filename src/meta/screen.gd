extends Control

const FIGHTS_UNTIL_BOSS = 7;

var player: Amalgam;
var boss: Amalgam;
var fight_progression: int;
var rng := RandomNumberGenerator.new();

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

var show_anims: bool = true;

func _on_start_pressed() -> void:
	fight_progression = 0;
	player = Utils.default_amalgam();
	boss = Utils.generate_enemy(Utils.EnemyStrength.Boss, rng);
	
	if show_anims:
		main_menu.hide();
		await _opening_animation();
		await _shift_backgrounds(preload("res://assets/ozadje3.png"));
		
		#fade.show();
		#fade_text.text = "";
		#
		#const FADE_OUT_TIME = 0.2;
		#var tween := create_tween();
		#tween.tween_property(fade, "modulate", Color.WHITE, FADE_OUT_TIME);
		#await tween.finished;
		
	main_menu.hide();
	fight.show();
	
	if show_anims:
		fight.modulate = Color.TRANSPARENT;
		
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
		const MOVE_IN_TIME = 0.6;
		tween.tween_property(fight, "anchor_top", 0.0, MOVE_IN_TIME).from(1.0);
		tween.tween_property(fight, "anchor_bottom", 1.0, MOVE_IN_TIME).from(2.0);
		tween.tween_property(fight, "modulate", Color.WHITE, MOVE_IN_TIME).from(Color.TRANSPARENT);
		
		#const FADE_IN_TIME = 0.2;
		#tween.tween_property(fade, "modulate", Color.TRANSPARENT, FADE_IN_TIME);
		#await tween.finished;
		#fade.hide();
	
	var current_fight: Amalgam;
	if fight_progression < FIGHTS_UNTIL_BOSS:
		current_fight = Utils.generate_enemy(_enemy_strength(fight_progression, rng), rng);
	else:
		current_fight = boss;
	
	fight.player_won.connect(_player_won);
	fight.player_lost.connect(_player_lost);
	fight.begin_fight(player, current_fight);

func _player_won() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	player.full_heal();
	fight_progression += 1;
	print("you won!");

func _player_lost() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	print("you lost!");

func _next_fight() -> void:
	pass

func _game_over() -> void:
	pass

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
	
	var player_ragdoll: AmalgamDisplay = $Opening/Player;
	var boss_ragdoll: AmalgamDisplay = $Opening/Boss;
	var player_start: Vector2 = player_ragdoll.position;
	var boss_start: Vector2 = boss_ragdoll.position;
	var player_end: Vector2 = $Opening/PlayerEnd.position;
	var boss_end: Vector2 = $Opening/BossEnd.position;
	
	var player_text: RichTextLabel = $Opening/PlayerText;
	var boss_text: RichTextLabel = $Opening/BossText;
	
	player_ragdoll.display_amalgam(player);
	boss_ragdoll.display_amalgam(boss);
	player_ragdoll.idle(AmalgamDisplay.IdleKinds.None);
	boss_ragdoll.idle(AmalgamDisplay.IdleKinds.None);
	
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

static func _enemy_strength(won_count: int, _rng: RandomNumberGenerator) -> Utils.EnemyStrength:
	if won_count < 1:
		return Utils.EnemyStrength.Weak;
	if won_count < 3:
		return Utils.EnemyStrength.Average;
	if won_count < 6:
		return Utils.EnemyStrength.Strong;
	
	return Utils.EnemyStrength.Boss;
