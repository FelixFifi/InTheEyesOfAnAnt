extends Control

class_name GuessUI

signal guess_button_pressed(guess: String)
signal guess_text_focus_changed(focused: bool)

func _ready():
	%GuessCorrectContainer.visible = false

func _on_guess_button_pressed():
	guess_button_pressed.emit(%GuessText.text)


func _on_guess_text_focus_entered():
	guess_text_focus_changed.emit(true)


func _on_guess_text_focus_exited():
	guess_text_focus_changed.emit(false)


func guess_correct(solution, target_description):
	%GuessCorrectLabel.text = "You guessed correctly!
	This is a {0}

	Now, navigate to {1}".format([solution, target_description])
	%GuessCorrectContainer.visible = true

	%Objective.text = "Current Objective:
	Navigate to {0}".format([target_description])


	await get_tree().create_timer(5).timeout
	hide_guess_container()

func hide_guess_container():
	var tween = create_tween()
	tween.parallel().tween_property(%GuessCorrectContainer, "modulate", Color(1,1,1,0), 0.5)
	tween.parallel().tween_property(%GuessContainer, "modulate", Color(1,1,1,0), 0.5)

	await tween.finished
	%GuessContainer.visible = false
	%GuessCorrectContainer.visible = false

func hide_objective():
	var tween = create_tween()
	tween.parallel().tween_property(%ObjectivePanel, "modulate", Color(1,1,1,0), 0.5)

	await tween.finished
	%ObjectivePanel.visible = false

func show_win():
	%PanelWin.visible = true

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept"):
		if not %GuessText.has_focus():
			%GuessText.grab_focus()


func _on_guess_text_text_submitted(_new_text):
	%GuessButton.pressed.emit()
	%GuessText.release_focus()


func _on_game_master_target_reached():
	show_win()
	hide_objective()
	hide_guess_container()
