class_name ExportedCard
extends Control

signal selected(ability: Dictionary);

@export var title: Label;
@export var short_desc: Label;
@export var effects_parent: Control;
@export var art: TextureRect;

@export var damage_icon: Control;
@export var damage_label: Label;

@export var stun_icon: Control;
@export var stun_label: Label;

@export var poison_icon: Control;
@export var poison_label: Label;

var _content: Dictionary;

func display_card(def: Dictionary, caster: Amalgam, enemy: Amalgam) -> void:
	set_selected(false);
	
	_content = def.duplicate();
	_content.make_read_only();
	
	title.text = def.get(Ability.NAME, "<missing name>");
	short_desc.text = def.get(Ability.DESC_SHORT, "");
	tooltip_text = def.get(Ability.DESC, "");
	art.texture = def.get(Ability.ABILITY_IMAGE, preload("res://assets/card - card.png"));
	
	var desc := Ability.DescBuilder.new();
	desc.tags = def;
	desc.me = caster;
	desc.them = enemy;
	
	var no_op = func(d: Ability.DescBuilder): return "";
	
	damage_icon.visible = Ability.DAMAGE_PREVIEW in def; # these are callables
	damage_label.text = str(def.get(Ability.DAMAGE_PREVIEW, no_op).call(desc));

	stun_icon.visible = Ability.STUN_PREVIEW in def;
	stun_label.text = str(def.get(Ability.STUN_PREVIEW, no_op).call(desc));
	
	poison_icon.visible = Ability.POISON_PREVIEW in def;
	poison_label.text = str(def.get(Ability.POISON_PREVIEW, no_op).call(desc));

func set_selected(state: bool):
	var target_color: Color;
	if state:
		target_color = Color.DARK_GRAY;
	else:
		target_color = Color.WHITE;
	
	const SELECT_TIME = 0.1;
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR);
	tween.tween_property(self, "modulate", target_color, SELECT_TIME);

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit(_content);
		
