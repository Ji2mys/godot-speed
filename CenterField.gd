extends Area2D
class_name CardField

signal clicked(field)

var _bottom_cards : Array
var _card_in_field : GameCard setget set_card_in_field

func set_card_in_field(card:GameCard) -> void:
	_bottom_cards.append(_card_in_field)
	_card_in_field = card
	$Sprite.texture = _card_in_field._card_front_texture

func _on_CardField_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			emit_signal("clicked", self)
