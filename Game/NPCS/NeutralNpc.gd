extends RigidBody2D
export var  is_moving = false
var direction_moving = 1
export var speedX = 10

func _ready():
	$AnimatedSprite.playing = true
	add_to_group("enemies")
	mode =RigidBody2D.MODE_RIGID
	direction_moving = sign (rand_range(-1,1))
func _integrate_forces(state):
	if (is_moving):
		set_applied_force( Vector2(speedX*direction_moving,0))
	
	
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


func _on_SpawnImpulseTimer_timeout():
	is_moving = true
