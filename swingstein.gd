extends Area2D

signal remove_from_array(object)

var level = 1
var hp = 999
var speed = 1000
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

var player


func _ready():
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group('player')
	
	rotation = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized().angle()
	AudioPlayerOverlapping.play_audio('res://assets/sfx/SwingsteinSfx.wav')
	match level:
		1:
			hp = 1
			speed = 1500
			damage = 10
			knockback_amount = 100
			attack_size = 1.0


func _on_timer_timeout():
	emit_signal('remove_from_array')
	queue_free()
