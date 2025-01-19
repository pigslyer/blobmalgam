class_name FightHealthbar
extends ProgressBar

@onready var health_text: Label = $Health;

@onready var stun: Control = $Statuses/Stun;
@onready var stun_count: Control = $Statuses/Stun/Count;

@onready var poison: Control = $Statuses/Poison;
@onready var poison_count: Label = $Statuses/Poison/Count;

var prev_health: float;
var prev_stun: int;
var prev_poison: int;

func _ready():
	assert(fill_mode == FillMode.FILL_BEGIN_TO_END || fill_mode == FillMode.FILL_END_TO_BEGIN);
	
	if fill_mode == FillMode.FILL_END_TO_BEGIN:
		pass
		health_text = $HealthReversed;
		stun = $StatusesReversed/Stun;
		stun_count = $StatusesReversed/Stun/Count;
		poison = $StatusesReversed/Poison;
		poison_count = $StatusesReversed/Poison/Count;

func update_instant(new_health: float, max_health: float, new_stun: int, new_poison: int):
	value = new_health / max_health;
	health_text.text = str(new_health);
	
	stun.visible = new_stun > 0;
	stun_count.text = str(new_stun);
	poison.visible = new_poison > 0;
	poison_count.text = str(new_poison);
	
	prev_health = new_health;
	prev_stun = new_stun;
	prev_poison = new_poison;

func update_slow(new_health: float, max_health: float, new_stun: int, new_poison: int):
	if !stun.visible:
		stun_count.text = "0";
	if !poison.visible:
		poison_count.text = "0";
	
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
	stun.visible = new_stun > 0 || prev_stun > 0;
	poison.visible = new_poison > 0 || prev_poison > 0;
	
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
	
	prev_health = new_health;
	prev_stun = new_stun;
	prev_poison = new_poison;
