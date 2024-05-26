extends Node2D

onready var dialog_box : Control = get_node("%DialogBox")
onready var text_label : Label = get_node("%DialogBox/Label")

export(Array, String, MULTILINE) var dialog_texts : Array = []

var actual_text : int = 0
var actual_anim : int = 1
var text_ended : bool = false
var dialog_box_shown : bool = false

func _ready():
	$TutorialAnimator.play("Tutorial01")
	show_dialog_bottom()
	tween_text(dialog_texts[actual_text])

func _input(event):
	if text_ended:
		var clicked = event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()
		if event.is_action_pressed("ui_accept") or clicked:
			next_dialog(false)

func show_dialog_bottom() -> void:
	dialog_box_shown = true
	dialog_box.anchor_top = 1
	dialog_box.anchor_bottom = 1
	dialog_box.rect_position = Vector2(113, 450)

func show_dialog_top() -> void:
	dialog_box_shown = true
	dialog_box.anchor_top = 0
	dialog_box.anchor_bottom = 0
	dialog_box.rect_position = Vector2(113, 20)

func tween_text(text:String) -> void:
	text_ended = false
	var tween = text_label.create_tween()
	tween.tween_callback(text_label, "set_visible_characters", [0])
	tween.tween_callback(text_label, "set_text", [text])
	tween.tween_property(text_label, "percent_visible", 1.0, len(text)*0.05)
	tween.tween_callback(self, "set", ["text_ended", true])

func next_dialog(triggered:bool) -> void:
	var can_continue = actual_text < len(dialog_texts) - 1
	
	if can_continue:
		if (is_next_text_trigger() and not triggered) or (triggered and not is_next_text_trigger()):
			return
		actual_text += 1
		
		var text_to_show : String = dialog_texts[actual_text]
		text_to_show = text_to_show.replace("[t]", "")
		if is_animation_text(text_to_show):
			actual_anim += 1
			$TutorialAnimator.play("Tutorial%02d" % actual_anim)
		text_to_show = text_to_show.replace("[n]", "")
		tween_text(text_to_show)
	else:
		$CanvasLayer/FadeNode.play_fadeout_animation()
		yield($CanvasLayer/FadeNode, "fade_out_finished")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Menu.tscn")

func is_next_text_trigger() -> bool:
	return dialog_texts[actual_text + 1].begins_with("[t]")

func is_animation_text(text:String) -> bool:
	return text.begins_with("[n]") and actual_anim < len($TutorialAnimator.get_animation_list())

func _on_ActionArea_input_event(_viewport, event:InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			next_dialog(true)
