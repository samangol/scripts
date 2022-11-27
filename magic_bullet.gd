extends Area2D

signal remove_from_array(object)

var level = 1
var hp = 1
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
	
	match_weapon_level()
	
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	
	AudioPlayerOverlapping.play_audio("res://assets/sfx/MagicBulletSfx.wav")
	

func match_weapon_level():
	match level:
		1:
			hp = 1
			speed = 1500
			damage = 5
			knockback_amount = 100
			attack_size = 1.0
	var tween :Tween= create_tween()
	tween.tween_property(self,'scale', Vector2(1,1) * attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
			

func _physics_process(delta):
	position += angle * speed * delta


func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free() 


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()




