extends Node2D
class_name GameMainNode

const CARD_SCENE = preload("res://Card.tscn")

onready var player_hand : PlayerHand = $PlayerHand
onready var rival_hand : PlayerHand = $RivalHand
onready var player_deck : PlayerDeck = $PlayerDeck
onready var rival_deck : PlayerDeck = PlayerDeck.new()
onready var left_card_field : CardField = $LeftCardField
onready var right_card_field : CardField = $RightCardField

var game_deck : Array = []
var selected_card : GameCard
var game_ended : bool = false
var support_decks : Array = [BackgroundDeck.new(), BackgroundDeck.new()]

func _ready():
	randomize()
	set_difficulty(GameEnvironment.difficulty)
	var left_card_field_error = left_card_field.connect("clicked", self, "on_CardField_clicked")
	var right_card_field_error = right_card_field.connect("clicked", self, "on_CardField_clicked")
	if left_card_field_error == OK and right_card_field_error == OK: print("Succesful connect in Main.")
	else: push_error("Error codes %d and %d in Main." % [left_card_field, right_card_field_error])
	_create_deck()
	_distribute_cards()
	$RivalTimer.start()
	$SupportDeckTimer.start()

func _create_deck():
	for figure in GameCard.figure.values():
		for i in 13:
			var new_card = CARD_SCENE.instance()
			new_card.initialize(i, figure)
			game_deck.append(new_card)
	game_deck.shuffle()

func set_difficulty(difficulty:int):
	match difficulty:
		1:
			$RivalTimer.set_wait_time(2)
			$SupportDeckTimer.set_wait_time(2.5)
			$Background.material.set_shader_param("fog_color", Color.lightgreen)
		2:
			$RivalTimer.set_wait_time(1.5)
			$SupportDeckTimer.set_wait_time(2)
			$Background.material.set_shader_param("fog_color", Color.yellow)
		3:
			$RivalTimer.set_wait_time(1)
			$SupportDeckTimer.set_wait_time(1.5)
			$Background.material.set_shader_param("fog_color", Color.red)

func _distribute_cards() -> void:
	left_card_field.set_card_in_field(get_top_card())
	right_card_field.set_card_in_field(get_top_card())
		
	for i in 20:
		var card = get_top_card()
		player_deck.cards_in_deck.append(card)
		var card2 = get_top_card()
		rival_deck.cards_in_deck.append(card2)
	
	for i in 5:
		add_card_to_player_hand(true)
		add_card_to_rival_hand(true)
		support_decks[0].add_card(get_top_card())
		support_decks[1].add_card(get_top_card())
	
	player_hand.rearrange_cards()

func get_top_card() -> GameCard:
	return game_deck.pop_front()

func add_card_to_player_hand(initial_adding:bool):
	if player_hand.cards_in_hand.size() < 5 and len(player_deck.cards_in_deck) > 0:
		var card : GameCard = player_deck.get_top_card()
		player_hand.add_card(card, not initial_adding)
		var error = card.connect("selected", self, "on_Card_selected")
		if error == OK: print("Succesful connected Card in Main.")
		else: push_error("Error %d connecting 'selected' from Card." % error)
		$CanvasLayer/EndScreen.set_player_label_count(len(player_deck.cards_in_deck))

func add_card_to_rival_hand(initial_adding:bool):
	if len(rival_hand.cards_in_hand) < 5 and len(rival_deck.cards_in_deck) > 0:
		var card : GameCard = rival_deck.get_top_card()
		rival_hand.add_card(card, not initial_adding)
		$CanvasLayer/EndScreen.set_rival_label_count(len(rival_deck.cards_in_deck))
	else:
		$RivalTimer.stop()

func remove_card_from_player_hand(card:GameCard) -> void:
	player_hand.remove_card(card)

func on_Card_selected(card:GameCard):
	if card != selected_card:
		if selected_card != null:
			selected_card.play_unselection_animation()
		selected_card = card
		selected_card.play_selection_animation()
	else:
		selected_card.play_unselection_animation()
		selected_card = null

func on_CardField_clicked(field:CardField):
	var card_in_field : GameCard = field._card_in_field
	if selected_card != null and selected_card.is_continuous_to(card_in_field):
		$RivalTimer.start()
		selected_card.z_index = 1
		selected_card.input_pickable = false
		var tween = create_tween()
		tween.tween_property(selected_card, "global_position", field.global_position, 0.2)
		tween.tween_callback(field, "set_card_in_field", [selected_card])
		tween.tween_callback(self, "remove_card_from_player_hand", [selected_card])
		selected_card = null

func _on_RivalTimer_timeout():
	var card_in_left_field = left_card_field._card_in_field
	var card_in_right_field = right_card_field._card_in_field
	for card in rival_hand.cards_in_hand:
		if card.is_continuous_to(card_in_left_field):
			left_card_field.set_card_in_field(card)
			rival_hand.remove_card(card)
			return
		elif card.is_continuous_to(card_in_right_field):
			right_card_field.set_card_in_field(card)
			rival_hand.remove_card(card)
			return
	add_card_to_rival_hand(false)

func check_if_game_ended() -> void:
	if len(player_hand.cards_in_hand) == 0 and len(player_deck.cards_in_deck) == 0:
		print("Player One Won!")
		game_ended = true
		$CanvasLayer/EndScreen.play_winning_animation()
		get_tree().paused = true
	elif len(rival_hand.cards_in_hand) == 0 and len(rival_deck.cards_in_deck) == 0:
		print("Rival Won...")
		game_ended = true
		$CanvasLayer/EndScreen.play_losing_animation()
		get_tree().paused = true

func _on_SupportDeckTimer_timeout():
	if not are_there_possible_moves():
		prints("\nPlayer has", len(player_hand.cards_in_hand), "cards")
		prints("Rival has", len(rival_hand.cards_in_hand), "cards\n")
		var left_card : GameCard = support_decks[0].get_top_card()
		var right_card : GameCard = support_decks[1].get_top_card()
		if left_card and right_card:
			left_card_field.set_card_in_field(left_card)
			right_card_field.set_card_in_field(right_card)
			$RivalTimer.start()
		
		if len(support_decks[0]._deck_cards) == 0:
			var new_support_deck = []
			var left_deck = left_card_field._bottom_cards
			var right_deck = right_card_field._bottom_cards
			left_card_field._bottom_cards = []
			right_card_field._bottom_cards = []
			new_support_deck.append_array(left_deck)
			new_support_deck.append_array(right_deck)
			new_support_deck.shuffle()
			print("\nSupport Deck activated")
			print(len(new_support_deck))
			left_deck = new_support_deck.slice(0, ceil(new_support_deck.size()/2) - 1)
			right_deck = new_support_deck.slice(ceil(new_support_deck.size()/2), new_support_deck.size() - 1)
			support_decks[0]._deck_cards.append_array(left_deck)
			support_decks[1]._deck_cards.append_array(right_deck)
	check_if_game_ended()

func are_there_possible_moves() -> bool:
	var can_player_play = false
	var can_rival_play = false
	var card_in_left_field = left_card_field._card_in_field
	var card_in_right_field = right_card_field._card_in_field
	var player_cannot_take_cards = len(player_hand.cards_in_hand) == 5 or len(player_deck.cards_in_deck) == 0
	var rival_cannot_take_cards = len(rival_hand.cards_in_hand) == 5 or len(rival_deck.cards_in_deck) == 0
	
	if player_cannot_take_cards and rival_cannot_take_cards:
		for card in player_hand.cards_in_hand:
			if card.is_continuous_to(card_in_left_field) or card.is_continuous_to(card_in_right_field):
				can_player_play = true
				break
		for card in rival_hand.cards_in_hand:
			if card.is_continuous_to(card_in_left_field) or card.is_continuous_to(card_in_right_field):
				can_rival_play = true
				break
		return can_player_play or can_rival_play
	else:
		return true
