extends MarginContainer

func _ready():
	pass


func _on_StartButton_pressed():
	get_tree().change_scene("res://Game/MainScene.tscn")
