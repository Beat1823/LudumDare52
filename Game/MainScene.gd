extends Node2D
export var SpawnLocations = []
export var Npcs = [preload("res://Game/NPCS/Cow/Cow.tscn"), preload("res://Game/NPCS/Chicken/Chicken.tscn")]

var score = 0

func _ready():
	randomize()
	newgame()
	
func gameover():
	$ScoreTimer.stop()
	$SpawnTimer.stop()

func newgame():
	score = 0
	$PlayerUFO.position = $StartPos.position
	$StartWaitTimer.start()
	
func addscore(points):
	score += points
	
func _on_StartWaitTimer_timeout():
	$ScoreTimer.start()
	$SpawnTimer.start()

func _on_ScoreTimer_timeout():
	score += 1

func _on_SpawnTimer_timeout():
	var mob = Npcs[randi() % Npcs.size()].instance()
	mob.position = SpawnLocations[randi() % SpawnLocations.size()]


	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	
	mob.linear_velocity = velocity
	mob.get_node("AnimatedSprite").flip_h = mob.linear_velocity.x < 0

	add_child(mob)
