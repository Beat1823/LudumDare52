extends RigidBody2D

# Energy Params
export(float) var MaxEnergy = 100
var energy:float
export var ImpactEnergyModifier = 0.004
export var EnergyConsuptimtionPerSec =1

# Impact vars
var collision_force : Vector2 = Vector2.ZERO
var collision_bounce = 0.2


var previous_linear_velocity : Vector2 = Vector2.ZERO

# Movement params
var thrust = Vector2(0, -500)
var reverse_thrust = Vector2(0, 250)

var torque = 6000
var stabilize_torqueForce = 3000
var shouldStabilize = false
export (Curve) var stabilize_curve
export(float) var StabilizeDelaySeconds



func _ready():
	SetTractorBeam (false)
	energy = MaxEnergy
	InitializeEnergyBar()
	
func SetTractorBeam (IsON):
	$TracktorBeamArea/TrackBeamCollision.disabled = !IsON
	$HarvestArea/CollisionShape2D.disabled = !IsON
	$TracktorBeamArea/AnimatedSprite.visible = IsON


func _integrate_forces(state):
	var finalforce = Vector2()
	#calculate impact if any
	collision_force = Vector2.ZERO
	if state.get_contact_count() > 0:
		var dv : Vector2 = state.linear_velocity - previous_linear_velocity
		collision_force = dv / (state.inverse_mass * state.step)
		print(collision_force)
		if (!$CollisionShape2D/HitParticles.emitting):
			$CollisionShape2D/HitParticles.restart()
		ReduceEnergy(collision_force.length()*ImpactEnergyModifier)
	previous_linear_velocity = state.linear_velocity
	
	if collision_force != Vector2.ZERO:
		finalforce = collision_force*collision_bounce
	if Input.is_action_pressed("Up"):
		finalforce  += thrust.rotated(rotation)
	elif Input.is_action_pressed("Down"): 
		finalforce += reverse_thrust.rotated(rotation)
	else:
		finalforce += Vector2()
	set_applied_force(finalforce)
	
	
	var rotation_dir = 0
	if Input.is_action_pressed("Right"):
		rotation_dir += 1
		shouldStabilize = false
	if Input.is_action_pressed("Left"):
		rotation_dir -= 1
		shouldStabilize = false
	
	if rotation_dir == 0:
		if $StabilizationTimer.is_stopped():
			$StabilizationTimer.start(StabilizeDelaySeconds)
		StabilizeUFO(shouldStabilize)
	else:
		set_applied_torque(rotation_dir * torque)

func StabilizeUFO(isStab):
	if (!isStab):
		return
	
	var t = abs(rotation_degrees/180)
	var modifier  = stabilize_curve.interpolate(t)
	var stabilize_torque = -1*sign(rotation_degrees) * stabilize_torqueForce * modifier
	set_applied_torque (stabilize_torque)

func _process(delta):
	if Input.is_action_pressed("TractorBeam"):
		SetTractorBeam (true)
	else:
		SetTractorBeam (false)
	ReduceEnergy (delta*EnergyConsuptimtionPerSec)

func ReduceEnergy(amount):
	energy -= amount
	if (energy <=0 ):
		queue_free()
		print ("GAME OVER")

func _on_HarvestArea_body_entered(body):
	pass
	


func _on_StabilizationTimer_timeout():
	shouldStabilize = true

func InitializeEnergyBar():
	UpdateEnergyBar()
	#$ProgressBar.max_value = MaxEnergy

func UpdateEnergyBar():
	$ProgressBar.text = String (energy)

func _on_EnergyUpdateTimer_timeout():
	UpdateEnergyBar()
