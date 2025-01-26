extends Control

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.process_mode = Node.PROCESS_MODE_PAUSABLE

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not visible:
			pause()
		else:
			unpause()

func pause():
	show()
	get_tree().paused = true

func unpause():
	get_tree().paused = false
	hide()

func _on_resume_pressed():
	unpause()

func _on_quit_pressed():
	get_tree().quit()
