extends Area2D
class_name GameCard

signal selected(card)

const GAME_DATA : GameDataResource = preload("res://Game_data_resource.tres")

enum figure {
	CLUBS,
	DIAMONDS,
	HEARTS,
	SPADES
}

export var displacement_offset : float = 0.0

onready var _card_sprite : Sprite = $CardSprite

var _value : int = 0
var _figure : int = figure.CLUBS
var _card_front_texture : Texture

func initialize(new_value, new_figure):
	_value = new_value
	_figure = new_figure
	_card_front_texture = GAME_DATA.cards_sprites[_value + _figure*13]

func show_card_front() -> void:
	_card_sprite.set_texture(_card_front_texture) 

func _on_Card_input_event(_viewport, event:InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			emit_signal("selected", self)

func play_selection_animation() -> void:
	position.y = 0
	var move_tween = create_tween()
	move_tween = move_tween.tween_property(self, "position:y", position.y - displacement_offset, 0.2)

func play_unselection_animation() -> void:
	position.y = -displacement_offset
	var move_tween = create_tween()
	move_tween.tween_property(self, "position:y", position.y + displacement_offset, 0.2)

func is_continuous_to(card:GameCard) -> bool:
	if card._value == posmod(_value - 1, 13) or card._value == posmod(_value + 1, 13):
		return true
	return false
