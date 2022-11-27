extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var change_dir_timer = $ChangeDirTimer
@onready var reset_pos_timer = $ResetPosTimer
@onready var animation_player = $AnimationPlayer


signal remove_from_array(object)

var level = 1
var hp = 999
var speed = 1000
var damage = 15
var knockback_amount = 100
var paths = 1
var attack_size = 1.0
var attack_speed = 4.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var player


func _ready():
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group('player')
	
	update_javelin()
	
	_on_reset_pos_timer_timeout()

func update_javelin():
	level = player.javelin_level
	
	match_weapon_level()
	
	scale = Vector2(1.0,1.0) * attack_size
	
	attack_timer.wait_time = attack_speed


func match_weapon_level():
	match level:
		1:
			hp = 999
			speed = 1000
			damage = 10
			knockback_amount = 100
			paths = 1
			attack_size = 1.0
			attack_speed = 4.0
			

func _physics_process(delta):
	
	move_weapon(delta)


func move_weapon(delta):
	if target_array.size() > 0:
		position += angle * speed * delta
	elif target_array.size() <= 0:
		if player:
			move_weapon_near_player(delta)


func move_weapon_near_player(delta):
	
	var player_angle = global_position.direction_to(reset_pos)
	var distance_dif = global_position - player.global_position
	var return_speed = 100
	
	if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
		return_speed = 180
	position += player_angle * return_speed * delta
	rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)



func add_paths():
	AudioPlayerOverlapping.play_audio("res://assets/sfx/JavelinSfx.wav")
	
	emit_signal('remove_from_array', self)
	
	target_array.clear()
	
	var counter = 0
	
	check_if_can_add_new_path(counter)
	
	
	
	process_path()
	


func check_if_can_add_new_path(counter):
	while counter < paths:
		var new_path = player.get_random_target()
		print(new_path)
		if new_path == null:
			return
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]

func process_path():
	if target:
		angle = global_position.direction_to(target.global_position)
		change_dir_timer.start()
	

func _on_attack_timer_timeout():
	add_paths()

func enable_attack(atk = true):
	if atk:
		toggle_collision_disabled(false, 'attack')
	else:
		toggle_collision_disabled(true, 'idle')


func toggle_collision_disabled(atk, anim):
	collision_shape_2d.disabled = atk
	animation_player.play(anim)


func _on_change_dir_timer_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			if is_instance_valid(target):
				process_path()
				AudioPlayerOverlapping.play_audio("res://assets/sfx/JavelinSfx.wav")
				emit_signal("remove_from_array",self)
			else:
				enable_attack(false)
		else:
			enable_attack(false)
	else:
		change_dir_timer.stop()
		attack_timer.start()
		enable_attack(false)


func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
