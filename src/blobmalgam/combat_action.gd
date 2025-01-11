class_name CombatAction
extends RefCounted

static func draw_ability(ability: Ability) -> DrawAbility:
	var draw := DrawAbility.new();
	draw.ability = ability;
	return draw;

class DrawAbility extends CombatAction:
	var ability: Ability;
