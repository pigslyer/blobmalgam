extends Control

var player: Amalgam;
var enemy: Amalgam;

@onready var player_health: ExportedAmalgamHealth = $PlayerHealth;
@onready var enemy_health: ExportedAmalgamHealth = $EnemyHealth;

@onready var exchange: ExportedCard = $ExchangeCard/Card;
@onready var bodyslam: ExportedCard = $BodySlamCard/Card;

@onready var player_cards: VBoxContainer = $Cards/Player;
@onready var skip: Button = $SkipTurn;

func _ready():
	for i in player_cards.get_children():
		var player_card: ExportedCard = i;
		
		player_card.selected.connect(_on_player_card_selected);
	

@warning_ignore("shadowed_variable")
func begin_fight(player: Amalgam, enemy: Amalgam) -> void:
	self.player = player;
	self.enemy = enemy;
	
	player.full_heal();
	enemy.full_heal();
	
	player_health.update_health(player);
	enemy_health.update_health(enemy);
	
	player_turn();

func player_turn():
	skip.show();
	var rng := RandomNumberGenerator.new();
	var abilities: Array[Dictionary] = player.combat_display_actions_simult_flattened(rng, 5);
	
	exchange.display_card(abilities[0]);
	bodyslam.display_card(abilities[1]);
	
	for i in range(2, len(abilities)):
		var card: ExportedCard = player_cards.get_child(i - 2);
		card.display_card(abilities[i]);
		card.show();

func _on_player_card_selected(card: Dictionary):
	
	pass

func _on_skip_turn_pressed() -> void:
	_hide_interactable_elements();
	
	enemy_turn();

func _hide_interactable_elements() -> void:
	skip.hide();
	exchange.hide();
	bodyslam.hide();
	
	for card in player_cards.get_children():
		card.hide();


func enemy_turn():
	pass
