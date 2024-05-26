extends Area2D
class_name PlayerDeck

var cards_in_deck : Array

func _ready():
	var error = connect("input_event", self, "on_PlayerDeck_input_event")
	if error == OK: print("Succesful connect in PlayerDeckf.")
	else: push_error("Error %d in PlayerDeck." % error)

func on_PlayerDeck_input_event(_viewport, event:InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT and len(cards_in_deck) > 0:
			var main_node = get_tree().root.get_node("Main")
			main_node.add_card_to_player_hand(false)

func get_top_card() -> GameCard:
	return cards_in_deck.pop_front()
