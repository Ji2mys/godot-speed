extends Control

export var screen_color : Color

func play_winning_animation() -> void:
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color", screen_color, 0.5)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($WinLabel, "rect_position", Vector2(250, 200), 1)
	$AnimationPlayer.play("Speed")

func play_losing_animation() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ColorRect, "color", screen_color, 0.5)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	$AnimationPlayer.play("Lose_anim")

func set_player_label_count(value:int) -> void:
	$PlayerCount.text = str(value)

func set_rival_label_count(value:int) -> void:
	$RivalCount.text = str(value)

func _input(event):
	if get_node("../..").game_ended and event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		get_node("../FadeNode").play_fadeout_animation()
		yield(get_node("../FadeNode"), "fade_out_finished")
		var error = get_tree().change_scene("res://Menu.tscn")
		if error == OK: print("Succesfully loaded Menu.")
		else: push_error("Error %d loading Menu." % error)
