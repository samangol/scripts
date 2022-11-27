extends Node2D
class_name ASPOverlapping

@onready var StreamPlayers = get_children()
@onready var index = 0

func play_audio(resource_path):
	var node = StreamPlayers[index]
	
	node.stream = load(resource_path)
	node.play()
	
	index += 1
	if index > StreamPlayers.size() -1:
		index = 0

