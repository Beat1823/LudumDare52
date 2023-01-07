extends RigidBody2D

var thrust = Vector2(0, -500)
var reverse_thrust = Vector2(0, 250)
var torque = 60000
func _ready():
	pass

func _integrate_forces(state):
	if Input.is_action_pressed("Up"):
		set_applied_force(thrust.rotated(rotation))
	elif Input.is_action_pressed("Down"): 
		set_applied_force(reverse_thrust.rotated(rotation))
	else:
		set_applied_force(Vector2())
	var rotation_dir = 0
	if Input.is_action_pressed("Right"):
		rotation_dir += .1
	if Input.is_action_pressed("Left"):
		rotation_dir -= .1
	set_applied_torque(rotation_dir * torque)
