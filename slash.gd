extends Area2D

signal remove_from_array(object)

var level = 1
var hp = 999
var speed = 800
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

var player

func _ready():
	await get_tree().process_frame
	
	AudioPlayerOverlapping.play_audio("res://assets/sfx/SlashSfx.wav")
	
	player = get_tree().get_first_node_in_group('player')
	
	angle = global_position.direction_to(target)
	
	match level:
		1:
			hp = 999
			speed = 300
			damage = 5
			knockback_amount = 100
			attack_size = 1.0

	var tween = create_tween()
	tween.tween_property(self,'scale', Vector2(1,1), 2)


func _physics_process(delta):
	position += angle * speed * delta


func enemy_hit(charge = 1):
	pass


func _on_timer_timeout():
	emit_signal('remove_from_array')
	queue_free()
