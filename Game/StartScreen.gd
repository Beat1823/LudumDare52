extends MarginContainer

var timepassed = 0.0

func _ready():
	pass


func _process(delta):
	timepassed += delta
	if (timepassed <= 14.0):
		$VBoxContainer/RichTextLabel.percent_visible = timepassed/12.0
	else:
		$VBoxContainer.hide()
		$StartScreen.show()
	

func _on_StartButton_pressed():
	get_tree().change_scene("res://Game/MainScene.tscn")
