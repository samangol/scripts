extends Node2D

var PlayerScene = preload("res://scenes/player.tscn")
var player:Player
@onready var enemies = get_tree().get_nodes_in_group('enemy')
@onready var camera = $Camera2D

func _ready():
#	await get_tree().process_frame
	
	player = PlayerScene.instantiate()
	add_child(player)
	player.global_position = Vector2.ZERO
	
	player.initialize(camera)
	
#	for enemy in enemies:
#		enemy.initialize(player)
	
	pass

