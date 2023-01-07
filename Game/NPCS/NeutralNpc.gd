extends RigidBody2D

func _ready():
	$AnimatedSprite.playing = true
	$AnimatedSprite.animation = "Cow"
	

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
