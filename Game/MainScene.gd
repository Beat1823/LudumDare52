extends Node2D
export var SpawnLocations = []
export var Npcs = [preload("res://Game/NPCS/Cow/Cow.tscn"), preload("res://Game/NPCS/Chicken/Chicken.tscn")]

var score = 0

func _ready():
	randomize()
	$RigidBody2D.hide()
	newgame()
	
func gameover():
	$ScoreTimer.stop()
	$SpawnTimer.stop()

func newgame():
	score = 0
	$StartWaitTimer.start()

func _process(delta):
	$ScoreLabel.text = String(score)

func addscore(points):
	score += points

func _on_StartWaitTimer_timeout():
	$PlayerUFO.start($StartPos.position)
	$RigidBody2D.show()
	$ScoreTimer.start()
	$SpawnTimer.start()

func _on_ScoreTimer_timeout():
	score += 1

func _on_SpawnTimer_timeout():
	var mob = Npcs[randi() % Npcs.size()].instance()
	mob.position = SpawnLocations[randi() % SpawnLocations.size()]

	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	
	mob.linear_velocity = velocity
	mob.get_node("AnimatedSprite").flip_h = mob.linear_velocity.x > 0

	add_child(mob)

func _on_PlayerUFO_NpcAbsorbed():
	addscore(5)

func _on_PlayerUFO_PlayerDestroyed():
	gameover()
