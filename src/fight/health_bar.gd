class_name FightHealthbar
extends ProgressBar

@onready var health_text: Label = $Health;

@onready var stun: Control = $Statuses/Stun;
@onready var stun_count: Control = $Statuses/Stun/Count;

@onready var poison: Control = $Statuses/Poison;
@onready var poison_count: Label = $Statuses/Poison/Count;

@onready var armor: Control = $Statuses/Armor;
@onready var armor_count: Label = $Statuses/Armor/Count;

var prev_health: float;
var prev_stun: int;
var prev_poison: int;
var prev_armor: int;

func _ready():
	assert(fill_mode == FillMode.FILL_BEGIN_TO_END || fill_mode == FillMode.FILL_END_TO_BEGIN);
	
	if fill_mode == FillMode.FILL_END_TO_BEGIN:
		pass
		health_text = $HealthReversed;
		stun = $StatusesReversed/Stun;
		stun_count = $StatusesReversed/Stun/Count;
		poison = $StatusesReversed/Poison;
		poison_count = $StatusesReversed/Poison/Count;
		armor = $StatusesReversed/Armor;
		armor_count = $StatusesReversed/Armor/Count;

const STUN_UPDATE = "Every time an amalgam would choose a limb from this blob, they get nothing instead.";
const POISON_UPDATE = "Blob takes this much damage every turn. When blob dies, it spreads to directly connected blobs.";
const ARMOR_UPDATE = "This much direct damage, up to 1, is blocked.";

func update_instant(new_health: float, max_health: float, new_stun: int, new_poison: int, new_armor: int):
	value = new_health / max_health;
	health_text.text = str(new_health);
	
	stun.visible = new_stun > 0;
	stun_count.text = str(new_stun);
	poison.visible = new_poison > 0;
	poison_count.text = str(new_poison);
	armor_count.text = str(new_armor);
	
	prev_health = new_health;
	prev_stun = new_stun;
	prev_poison = new_poison;
	prev_armor = new_armor;

func update_slow(new_health: float, max_health: float, new_stun: int, new_poison: int, new_armor: int):
	if !stun.visible:
		stun_count.text = "0";
	if !poison.visible:
		poison_count.text = "0";
	if !armor.visible:
		armor_count.text = "0";
	
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	stun.visible = new_stun > 0 || prev_stun > 0;
	poison.visible = new_poison > 0 || prev_poison > 0;
	armor.visible = new_armor > 0 || prev_armor > 0;
	
	const INTERP_TIME = 0.3;
	tween.tween_method(
		func(e): 
			value = e / max_health;
			health_text.text = "%.0f" % e,
		prev_health,
		new_health,
		INTERP_TIME
	);
	tween.tween_method(
		func(e): 
			poison.visible = e > 0;
			poison_count.text = str(e),
		prev_poison,
		new_poison,
		INTERP_TIME
	);
	tween.tween_method(
		func(e): 
			stun.visible = e > 0;
			stun_count.text = str(e),
		prev_stun,
		new_stun,
		INTERP_TIME
	);
	tween.tween_method(
		func(e): 
			armor.visible = e > 0;
			armor_count.text = str(e),
		prev_armor,
		new_armor,
		INTERP_TIME
	);
	
	prev_health = new_health;
	prev_stun = new_stun;
	prev_poison = new_poison;
	prev_armor = new_armor;

func _make_tooltip():
	var text = "";
	if stun.visible:
		text += STUN_UPDATE + "\n";
	if poison.visible:
		text += POISON_UPDATE + "\n";
	if armor.visible:
		text += ARMOR_UPDATE + "\n";
	
	tooltip_text = text;
