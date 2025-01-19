extends Control

const FIGHTS_UNTIL_BOSS = 2;

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

@onready var music_intro: AudioStreamPlayer = $Music/TrackIntro;
@onready var music_loop: AudioStreamPlayer = $Music/TrackLoop;
@onready var record_scratch: AudioStreamPlayer = $Music/RecordScratch;

class Background:
	var texture: Texture;
	var music_start: AudioStream;
	var music_loop: AudioStream;
	
	static func looping(tex: Texture, music: AudioStream) -> Background:
		var ret := Background.new();
		ret.texture = tex;
		ret.music_loop = music;
		return ret;
	
	static func begin_and_loop(tex: Texture, begin: AudioStream, loop: AudioStream) ->Background:
		var ret := Background.new();
		ret.texture = tex;
		ret.music_start = begin;
		ret.music_loop = loop;
		return ret;


func _ready():
	_apply_volume_to_bus("Master", 0.5);
	_apply_volume_to_bus("Effects", 0.5);
	_apply_volume_to_bus("Music", 0.5);
	
	var bckg := menu_background();
	current_background.texture = bckg.texture;
	_play_background_music(bckg);

var show_anims: bool = true || !OS.has_feature("editor");

func _on_start_pressed() -> void:
	fight_progression = 0;
	player = Utils.default_amalgam();
	boss = Utils.generate_enemy(Utils.EnemyStrength.Boss, rng);
	
	var current_fight: Amalgam = Utils.generate_enemy(_enemy_strength(fight_progression, rng), rng);
	var background: Background = background_fitting(current_fight);
	
	_fade_out_music();
	
	if show_anims:
		main_menu.hide();
		await _opening_animation();
		Utils.play_sfx(preload("res://assets/sfx/death scratch.mp3"));
		await _shift_backgrounds(background.texture);
	
	main_menu.hide();
	fight.show();
	_play_background_music(background);
	
	if show_anims:
		fight.modulate = Color.TRANSPARENT;
		
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
		const MOVE_IN_TIME = 0.6;
		tween.tween_property(fight, "anchor_left", 0.0, MOVE_IN_TIME).from(0.3);
		tween.tween_property(fight, "anchor_right", 1.0, MOVE_IN_TIME).from(0.7);
		tween.tween_property(fight, "anchor_top", 0.0, MOVE_IN_TIME).from(1.0);
		tween.tween_property(fight, "anchor_bottom", 1.0, MOVE_IN_TIME).from(2.0);
		tween.tween_property(fight, "modulate", Color.WHITE, MOVE_IN_TIME).from(Color.TRANSPARENT);
	
	fight.player_won.connect(_player_won);
	fight.player_lost.connect(_player_lost);
	fight.begin_fight(player, current_fight);

func _player_won() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	player.full_heal();
	fight_progression += 1;
	
	if fight_progression <= FIGHTS_UNTIL_BOSS:
		_next_fight();
	else:
		_return_to_main_menu();

func _next_fight() -> void:
	var enemy: Amalgam;
	if fight_progression == FIGHTS_UNTIL_BOSS:
		enemy = boss;
	else:
		enemy = Utils.generate_enemy(_enemy_strength(fight_progression, rng), rng);
	
	var bckg := background_fitting(enemy);
	next_background.texture = bckg.texture;
	
	const TRANS_TIME = 1.2;
	
	_fade_out_music();
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(fight, "anchor_left", -1.0, TRANS_TIME);
	tween.tween_property(fight, "anchor_right", 0.0, TRANS_TIME);
	
	tween.tween_property(current_background, "anchor_left", -1.0, TRANS_TIME);
	tween.tween_property(current_background, "anchor_right", 0.0, TRANS_TIME);
	
	tween.tween_property(next_background, "anchor_left", 0.0, TRANS_TIME);
	tween.tween_property(next_background, "anchor_right", 1.0, TRANS_TIME);
	await tween.finished;
	
	var temp = current_background;
	current_background = next_background;
	next_background = temp;
	next_background.anchor_left = 1.0;
	next_background.anchor_right = 2.0;
	
	_play_background_music(bckg);
	
	fight.modulate = Color.TRANSPARENT;
	
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	const MOVE_IN_TIME = 0.6;
	tween.tween_property(fight, "anchor_left", 0.0, MOVE_IN_TIME).from(0.3);
	tween.tween_property(fight, "anchor_right", 1.0, MOVE_IN_TIME).from(0.7);
	tween.tween_property(fight, "anchor_top", 0.0, MOVE_IN_TIME).from(1.0);
	tween.tween_property(fight, "anchor_bottom", 1.0, MOVE_IN_TIME).from(2.0);
	tween.tween_property(fight, "modulate", Color.WHITE, MOVE_IN_TIME).from(Color.TRANSPARENT);
	
	fight.player_won.connect(_player_won);
	fight.player_lost.connect(_player_lost);
	fight.begin_fight(player, enemy);

func _return_to_main_menu() -> void:
	var bckg := menu_background();
	
	const FADE_OUT_TIME = 0.4;
	
	_fade_out_music();
	
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(fight, "anchor_left", -1.2, FADE_OUT_TIME);
	tween.tween_property(fight, "anchor_top", -1.2, FADE_OUT_TIME);
	tween.tween_property(fight, "anchor_right", 2.2, FADE_OUT_TIME);
	tween.tween_property(fight, "anchor_bottom", 2.2, FADE_OUT_TIME);
	tween.tween_property(fight, "modulate", Color.TRANSPARENT, FADE_OUT_TIME);
	
	_shift_backgrounds(bckg.texture);
	await tween.finished;
	fight.hide();
	main_menu.show();
	_play_background_music(bckg);

func _player_lost() -> void:
	fight.player_won.disconnect(_player_won);
	fight.player_lost.disconnect(_player_lost);
	
	_game_over();


func _game_over() -> void:
	const SHRINK_TIME = 0.3;
	const FADE_TIME = 0.8;
	
	record_scratch.play();
	
	_fade_out_music();
	var tween := create_tween().set_parallel();
	
	tween.tween_property(fight, "anchor_top", -1, SHRINK_TIME);
	tween.tween_property(fight, "anchor_bottom", -0.3, SHRINK_TIME);
	
	fade.show();
	tween.tween_property(fade, "modulate", Color.WHITE, FADE_TIME);
	fade_text.text = "You have died.";
	
	await tween.finished;
	
	fight.hide();
	main_menu.show();
	var bckg := menu_background();
	current_background.texture = bckg.texture;
	
	await get_tree().create_timer(1).timeout;
	
	_play_background_music(bckg);
	tween = create_tween().set_parallel();
	
	tween.tween_property(fade, "modulate", Color.TRANSPARENT, FADE_TIME);
	await tween.finished;
	fade.hide();

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

var fading_tween: Tween;
func _fade_out_music() -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_EXPO);
	tween.tween_property(music_intro, "volume_db", -60, 0.6);
	tween.tween_property(music_intro, "volume_db", -60, 0.6);
	fading_tween = tween;
	
	await tween.finished;
	music_intro.stop();
	music_loop.stop();

func _play_background_music(bckg: Background) -> void:
	if fading_tween != null && fading_tween.is_running():
		fading_tween.stop();
	
	music_intro.volume_db = 0;
	music_loop.volume_db = 0;
	
	music_intro.stream = bckg.music_start;
	music_loop.stream = bckg.music_loop;
	
	if music_intro.stream != null:
		music_intro.play();
		# this is mildly stupid
		await music_intro.finished;
	
	if music_loop.stream == bckg.music_loop && music_loop.stream != null:
		music_loop.play();

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
	
	player_ragdoll.show();
	boss_ragdoll.show();
	
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
	
	tween.parallel().tween_property(player_ragdoll, "scale", Vector2(0.1, 0.1), 0.4);
	tween.parallel().tween_property(player_ragdoll, "position", Vector2(-200, 0), 1);
	tween.parallel().tween_property(player_ragdoll, "rotation", TAU * 10, 1);
	
	tween.parallel().tween_property(boss_ragdoll, "scale", Vector2(0.1, 0.1), 0.4);
	tween.parallel().tween_property(boss_ragdoll, "position", Vector2(2000, 0), 1);
	tween.parallel().tween_property(boss_ragdoll, "rotation", TAU * 10, 1);
	
	tween.parallel().tween_property(player_text, "modulate", Color.TRANSPARENT, 0.3);
	tween.parallel().tween_property(boss_text, "modulate", Color.TRANSPARENT, 0.3);
	
	tween.tween_callback(func():
		player_ragdoll.hide();
		player_ragdoll.position = player_start;
		player_ragdoll.scale = Vector2.ONE;
		player_ragdoll.rotation = 0;
		
		boss_ragdoll.hide();
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

static func menu_background() -> Background:
	return Background.looping(preload("res://assets/ozadje2.png"), preload("res://assets/music/Titanic_Blues.mp3"));

static func upgrade_background() -> Background:
	return Background.looping(null, preload("res://assets/music/mushroom music.mp3"));

static func background_fitting(whom: Amalgam) -> Background:
	var backgrounds: Dictionary = battle_backgrounds();
	
	var final_sum := { };
	for limb in whom.alive_limbs_flat():
		for tag in limb.tags.keys():
			if !tag in backgrounds:
				continue;
			
			if tag in final_sum:
				final_sum[tag] += limb.tags[tag];
			else:
				final_sum[tag] = limb.tags[tag];
	
	var highest = final_sum.keys()[0];
	for summed in final_sum.keys():
		if final_sum[highest] < final_sum[summed]:
			highest = summed;
	
	return backgrounds[highest];

static func battle_backgrounds() -> Dictionary:
	return {
		Ability.ANGELIC : Background.begin_and_loop(preload("res://assets/angelicB.png"), preload("res://assets/music/eldritch despair - intro.mp3"), preload("res://assets/music/eldritch despair.mp3")),
		Ability.CUTE : Background.looping(preload("res://assets/cuteB.png"), preload("res://assets/music/cute and kawaii uwu.mp3")),
		Ability.CYBER : Background.begin_and_loop(preload("res://assets/cyberB.png"), preload("res://assets/music/cyber sunday - intro.mp3"), preload("res://assets/music/cyber sunday.mp3")),
		Ability.ELDRITCH : Background.begin_and_loop(preload("res://assets/eldritchB.png"), preload("res://assets/music/eldritch despair - intro.mp3"), preload("res://assets/music/eldritch despair.mp3")),
		Ability.MEDIEVAL : Background.looping(preload("res://assets/medievalB.png"), preload("res://assets/music/medieval bout.mp3")),
		Ability.MONSTER : Background.looping(preload("res://assets/monstrousB.png"), preload("res://assets/music/plant matter.mp3")),
		Ability.NORMAL : Background.looping(preload("res://assets/normalB.png"), preload("res://assets/music/normal people type music.mp3")),
		Ability.PIXEL : Background.looping(preload("res://assets/pixelB.png"), preload("res://assets/music/pixel encounter.mp3")),
		Ability.PLANT : Background.looping(preload("res://assets/plantB.png"), preload("res://assets/music/plant matter.mp3")),
	}
