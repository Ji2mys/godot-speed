extends Control

var difficulty_shown := false

func _on_StartButton_button_down():
	if not difficulty_shown:
		$AnimationPlayer.play("Difficulty")
		difficulty_shown = true
	else:
		$AnimationPlayer.play_backwards("Difficulty")
		difficulty_shown = false

func _on_EasyModeButton_button_down():
	GameEnvironment.set_difficulty(1)
	$FadeNode.play_fadeout_animation()
	yield($FadeNode, "fade_out_finished")
	var error = get_tree().change_scene("res://Main.tscn")
	if error == OK: print("Loaded EasyMode.")
	else: push_error("Error %d loading EasyMode." % error)

func _on_NormalModeButton_button_down():
	GameEnvironment.set_difficulty(2)
	$FadeNode.play_fadeout_animation()
	yield($FadeNode, "fade_out_finished")
	var error = get_tree().change_scene("res://Main.tscn")
	if error == OK: print("NormalMode loaded.")
	else: push_error("Error %d loading NormalMode." % error)

func _on_InfernoModeButton_button_down():
	GameEnvironment.set_difficulty(3)
	$FadeNode.play_fadeout_animation()
	yield($FadeNode, "fade_out_finished")
	var error = get_tree().change_scene("res://Main.tscn")
	if error == OK: print("InfernoMode loaded.")
	else: push_error("Error %d loading InfernoMode." % error)

func _on_TutorialButton_button_down():
	$FadeNode.play_fadeout_animation()
	yield($FadeNode, "fade_out_finished")
	var error = get_tree().change_scene("res://Tutorial.tscn")
	if error == OK: print("Tutorial loaded.")
	else: push_error("Error %d loading Tutorial." % error)
