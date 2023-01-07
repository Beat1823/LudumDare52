extends RigidBody2D

var thrust = Vector2(0, -500)
var reverse_thrust = Vector2(0, 250)
var torque = 6000
var stabilize_torqueForce = 3000
export (Curve) var stabilize_curve
func _ready():
	SetTractorBeam (false)
	
func SetTractorBeam (IsON):
	$TracktorBeamArea/TrackBeamCollision.disabled = !IsON
	$HarvestArea/CollisionShape2D.disabled = !IsON
	$TracktorBeamArea/AnimatedSprite.visible = IsON
func _integrate_forces(state):
	if Input.is_action_pressed("Up"):
		set_applied_force(thrust.rotated(rotation))
	elif Input.is_action_pressed("Down"): 
		set_applied_force(reverse_thrust.rotated(rotation))
	else:
		set_applied_force(Vector2())
	var rotation_dir = 0
	if Input.is_action_pressed("Right"):
		rotation_dir += 1
	if Input.is_action_pressed("Left"):
		rotation_dir -= 1
	print (rotation_dir)
	if rotation_dir == 0:
		StabilizeUFO()
	else:
		set_applied_torque(rotation_dir * torque)
	
func _process(delta):
	if Input.is_action_pressed("TractorBeam"):
		SetTractorBeam (true)
	else:
		SetTractorBeam (false)
		

func StabilizeUFO():
	var t = abs(rotation_degrees/180)

	var modifier  = stabilize_curve.interpolate(t)
	var stabilize_torque = -1*sign(rotation_degrees) * stabilize_torqueForce * modifier
	set_applied_torque (stabilize_torque)
	print (stabilize_torque)
func _on_HarvestArea_body_entered(body):
	pass
	
