extends Control

func _ready() -> void:
	pass




func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_Menu.tscn")
