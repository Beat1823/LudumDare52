extends RigidBody2D

func _ready():
	$AnimatedSprite.playing = true
	add_to_group("enemies")

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
