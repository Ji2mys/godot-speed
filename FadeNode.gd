extends Control
 
signal fade_out_finished()

func play_fadeout_animation() -> void:
	$AnimationPlayer.play("FadeOut")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("fade_out_finished")
