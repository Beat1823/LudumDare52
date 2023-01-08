extends RigidBody2D

# Energy Params
export(float) var MaxEnergy = 100
var energy:float
export var ImpactEnergyModifier = 0.004
export var EnergyConsuptimtionPerSec =1
export var EnergyGain = 15
export var EnergyLoseTeleportCenter = 20

# Impact vars
var collision_force : Vector2 = Vector2.ZERO
var collision_bounce = 0.2


var previous_linear_velocity : Vector2 = Vector2.ZERO
var should_teleport = false
# Movement params
export var thrustForwardForce= 500.0
export var thrustReverseForce = 250
var thrust = Vector2(0, -1*thrustForwardForce)
var reverse_thrust = Vector2(0,thrustReverseForce)

var forward_input_level = 0
export var forward_input_rate_up = 1.0
export var forward_input_rate_down = 3.0
export (Curve) var ForwardInputCurve

var reverse_input_level = 0
export var reverse_input_rate_up = 0.5
export var reverse_input_rate_down = 3.0
export (Curve) var ReverseInputCurve

var turn_input_level = 0
var turn_input_rate_up = 100
var turn_input_rate_down = 100

export (Curve) var TurnInputCurve

export var torque = 6000.0
export var stabilize_torqueForce = 3000.0
var shouldStabilize = false
export var StabilizeDownAngleThershold = 90.0
export (Curve) var stabilize_curve
export(float) var StabilizeDelaySeconds

signal NpcAbsorbed
signal PlayerDestroyed

func _ready():
	hide()
	SetTractorBeam (false)
	energy = MaxEnergy
	InitializeEnergyBar()
	
func start(pos):
	position = pos
	show() 

func SetTractorBeam (IsON):
	$TracktorBeamArea/TrackBeamCollision.disabled = !IsON
	$HarvestArea/CollisionShape2D.disabled = !IsON
	$TracktorBeamArea/AnimatedSprite.visible = IsON
	if IsON and not $SoundBeam.playing:
		$SoundBeam.play()
	elif !IsON:
		$SoundBeam.stop()


func _integrate_forces(state):
	#Process Collision
	var collision_force = Vector2()
	#calculate impact if any
	var collision_impact = Vector2.ZERO
	if state.get_contact_count() > 0:
		var dv : Vector2 = state.linear_velocity - previous_linear_velocity
		collision_impact= dv / (state.inverse_mass * state.step)
		print(collision_impact)
		tryEmitColisionParticles(state.get_contact_collider_position(0))
		ReduceEnergy(collision_impact.length()*ImpactEnergyModifier)
	previous_linear_velocity = state.linear_velocity
	
	if collision_impact != Vector2.ZERO:
		collision_force = collision_impact*collision_bounce
	var input_force = ProcessInputForce(state.step)
	var input_torque= ProcessInputRotation(state)
	
	
	if (should_teleport):
		should_teleport = false
		var bodyPos = state.transform.origin
		var screenCenter =get_viewport_center()
		var vieportScale = get_viewport_transform().get_scale()
		var margin = 10
		print(bodyPos.y-screenCenter.y)
		if (abs(bodyPos.y-screenCenter.y) > (get_viewport_rect().size.y/2 + margin)):
			TeleportCenterNotify()
			state.transform.origin = screenCenter
		else:
			state.transform.origin = Vector2(screenCenter.x + (screenCenter.x - bodyPos.x)*vieportScale.x*0.9, bodyPos.y)
		
	
	set_applied_force(collision_force+input_force)
	set_applied_torque(input_torque)
	
	
func TeleportCenterNotify():
	tryEmitColisionParticles(Vector2(0 , 0))
	ReduceEnergy(EnergyLoseTeleportCenter)

func StabilizeUFO(isStab):
	if (!isStab):
		return 0
	
	var t = abs(rotation_degrees/180)
	var modifier  = stabilize_curve.interpolate(t)
	var stabDirection = -1*sign(rotation_degrees) if abs(rotation_degrees)<= StabilizeDownAngleThershold else sign(rotation_degrees)
	var stabilize_torque = stabDirection * stabilize_torqueForce * modifier
	return stabilize_torque

func ProcessInputForce (delta):
	
	var thrustforce = Vector2.ZERO
	if Input.is_action_pressed("Up"):
		forward_input_level += forward_input_rate_up*delta
		forward_input_level = min(forward_input_level,1)
		reverse_input_level = 0
		thrustforce  += thrust.rotated(rotation) * ForwardInputCurve.interpolate(forward_input_level)
	elif Input.is_action_pressed("Down"): 
		reverse_input_level += reverse_input_rate_up*delta
		reverse_input_level = min(reverse_input_level,1)
		forward_input_level = 0
		thrustforce += reverse_thrust.rotated(rotation) * ReverseInputCurve.interpolate (reverse_input_level)
	else :
		forward_input_level -= forward_input_rate_down*delta
		forward_input_level = max (forward_input_level,0)
		reverse_input_level -= reverse_input_rate_down*delta
		reverse_input_level = max (reverse_input_level,0)
	
	return thrustforce
	
	
func ProcessInputRotation (state): 
	var rotation_dir = 0
	var is_rotating_right = (state.angular_velocity > 0)
	if Input.is_action_pressed("Right"):
		rotation_dir += 1
		shouldStabilize = false
	if Input.is_action_pressed("Left"):
		rotation_dir -= 1
		shouldStabilize = false
	if rotation_dir == 0:
		if $StabilizationTimer.is_stopped():
			$StabilizationTimer.start(StabilizeDelaySeconds)
		return (StabilizeUFO(shouldStabilize))
	else:
		return (rotation_dir * torque)
	
	
	


func _process(delta):
	if Input.is_action_pressed("TractorBeam"):
		SetTractorBeam (true)
	else:
		SetTractorBeam (false)
	ReduceEnergy (delta*EnergyConsuptimtionPerSec)

func ReduceEnergy(amount):
	energy -= amount
	if (energy <=0 ):
		emit_signal("PlayerDestroyed")
		queue_free()
		print ("GAME OVER")

func _on_HarvestArea_body_entered(body): 
	if body.is_in_group("enemies"):
		body.queue_free()
		emit_signal("NpcAbsorbed")
	

func _on_StabilizationTimer_timeout():
	shouldStabilize = true

func InitializeEnergyBar():
	UpdateEnergyBar()
	#$ProgressBar.max_value = MaxEnergy

func UpdateEnergyBar():
	$ProgressBar.text = String (energy)

func _on_EnergyUpdateTimer_timeout():
	UpdateEnergyBar()

func _on_PlayerUFO_NpcAbsorbed():
	$SoundPickup.play()
	energy +=EnergyGain
	energy = min(MaxEnergy,energy)
	
func tryEmitColisionParticles (impactPoin):
	if (!$CollisionShape2D/HitParticles.emitting):
		$CollisionShape2D/HitParticles.restart()


func _on_TracktorBeamArea_body_entered(body):
	if (body.is_in_group("enemies")):
		body.mode = RigidBody2D.MODE_RIGID
		body.is_moving = false
		body.linear_damp = -1


func _on_VisibilityNotifier2D_viewport_exited(viewport):
		should_teleport=true

func get_viewport_center() -> Vector2:
	var transform : Transform2D = get_viewport_transform()
	var scale : Vector2 = transform.get_scale()
	return -transform.origin / scale + get_viewport_rect().size / scale / 2
