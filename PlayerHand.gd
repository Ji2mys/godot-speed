extends Position2D
class_name PlayerHand

const CARD_WIDTH = 100

export var is_rival : bool = false
var cards_in_hand : Array

func add_card(card:GameCard, tween_animation:bool = true) -> void:
	add_child(card)
	cards_in_hand.append(card)
	var new_card_position = Vector2()
	if is_rival:
		if tween_animation:
			card.global_position = get_node("../RivalDeck").global_position
		new_card_position = Vector2(-CARD_WIDTH * (len(cards_in_hand) - 1), 0)
		card.rotation_degrees = 180
	else:
		if tween_animation:
			card.global_position = get_parent().player_deck.global_position
		new_card_position = Vector2(CARD_WIDTH * (len(cards_in_hand) - 1), 0)
	card.show_card_front()
	if tween_animation:
		var new_card_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		new_card_tween.tween_property(card, "position", new_card_position, 0.5)
		yield(new_card_tween, "finished")
	else:
		card.position = new_card_position
	rearrange_cards()

func remove_card(card:GameCard) -> void:
	if card in cards_in_hand:
		cards_in_hand.erase(card)
		remove_child(card)
		rearrange_cards()

func rearrange_cards() -> void:
	for i in get_child_count():
		var card = get_child(i) as GameCard
		var card_collision = card.get_node("CollisionShape2D") as CollisionShape2D
		if is_rival:
			card.position = Vector2(-CARD_WIDTH * i, 0)
		else:
			card.position = Vector2(CARD_WIDTH * i, 0)
			if i == get_child_count() - 1:
				card_collision.position = Vector2.ZERO
				card_collision.scale.x = 1
			else:
				card_collision.scale.x = 0.6
				card_collision.position.x = -25
				
