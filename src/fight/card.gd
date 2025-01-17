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

func display_card(def: Dictionary) -> void:
	_content = def.duplicate();
	_content.make_read_only();
	
	title.text = def.get(Ability.NAME, "<missing name>");
	short_desc.text = def.get(Ability.DESC_SHORT, "");
	tooltip_text = def.get(Ability.DESC, "");
	art.texture = def.get(Ability.IMAGE, null);
	
	damage_icon.visible = Ability.DAMAGE_PREVIEW in def; # these are callables
	damage_label.text = def.get(Ability.DAMAGE_PREVIEW);

	stun_icon.visible = Ability.STUN_PREVIEW in def;
	stun_label.text = def.get(Ability.STUN_PREVIEW, "");
	
	poison_icon.visible = Ability.POISON_PREVIEW in def;
	poison_label.text = def.get(Ability.POISON_PREVIEW, "");


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit(_content);
		
