extends CanvasLayer

class_name GuessUI

signal guess_button_pressed(guess: String)
signal guess_text_focus_changed(focused: bool)
signal help_ui_visibility_changed(visible: bool)

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
	tween.parallel().tween_property(%GuessPanel, "modulate", Color(1,1,1,0), 0.5)

	await tween.finished
	%GuessPanel.visible = false
	%GuessCorrectContainer.visible = false

func hide_objective():
	var tween = create_tween()
	tween.parallel().tween_property(%ObjectivePanel, "modulate", Color(1,1,1,0), 0.5)

	await tween.finished
	%ObjectivePanel.visible = false

func show_win():
	%PanelWin.visible = true

func _unhandled_key_input(event):
	if %GuessPanel.visible and event.is_action_pressed("ui_accept"):
		if not %GuessText.has_focus():
			%GuessText.grab_focus()


func _on_guess_text_text_submitted(_new_text):
	%GuessButton.pressed.emit()
	%GuessText.release_focus()


func handle_target_reached():
	show_win()
	hide_objective()
	hide_guess_container()


func set_help_ui_visibility(help_ui_visible: bool):
	%HelpContainer.visible = help_ui_visible
	%SpacerInsteadOfHelp.visible = not help_ui_visible

	%GuessPanel.visible = not help_ui_visible
	%SpacerInsteadOfGuessPanel.visible = help_ui_visible

	%ObjectivePanel.visible = not help_ui_visible

	help_ui_visibility_changed.emit(help_ui_visible)

func _on_help_button_pressed():
	var help_ui_visible: bool = not %HelpContainer.visible
	set_help_ui_visibility(help_ui_visible)
