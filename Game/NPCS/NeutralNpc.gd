extends RigidBody2D

signal absorbed

func _ready():
	$AnimatedSprite.playing = true
	

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()

func _on_enemy_body_entered(body_rid, body, body_shape_index, local_shape_index):
	emit_signal("absorbed") # Should check if the body is the player/thing we want to use to absorb.
