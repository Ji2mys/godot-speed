extends Node
class_name BackgroundDeck

var _deck_cards : Array setget set_deck_cards

func set_deck_cards(_value) -> void:
	push_error("Can't set variable")

func add_card(card:GameCard) -> void:
	_deck_cards.append(card)

func get_top_card() -> GameCard:
	return _deck_cards.pop_front()
