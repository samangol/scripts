extends CharacterBody2D
class_name Player

@onready var camera_remote_transform_2d = %CameraRemoteTransform2D

# GUI
@onready var level_label = %LevelLabel
@onready var level_up_panel = %LevelUpPanel
@onready var exp_bar = %ExpBar
@onready var enemy_detection_area = %EnemyDetectionArea
@onready var upgrade_options = %UpgradeOptions
@onready var snd_level_up = %SndLevelUp
@onready var item_options = preload("res://scenes/Utilities/item_option.tscn")


# MOVEMENT
@export var speed = 150
@export var acceleration = 800
@export var hp = 100

var last_movement = Vector2.UP

# Attacks
var MagicBulletScene = preload("res://scenes/Atttack/magic_bullet.tscn")
var SlashScene = preload("res://scenes/Atttack/slash.tscn")
var SwingsteinScene = preload("res://scenes/Atttack/swingstein.tscn")
var JavelinScene = preload("res://scenes/Atttack/javelin.tscn")

# Attack Nodes
@onready var magic_bullet_timer = $Attack/MagicBulletTimer
@onready var magic_bullet_attack_timer = $Attack/MagicBulletTimer/MagicBulletAttackTimer

@onready var slash_timer = $Attack/SlashTimer
@onready var slash_attack_timer = $Attack/SlashTimer/SlashAttackTimer

@onready var swingstein_timer = $Attack/SwingsteinTimer
@onready var swingstein_attack_timer = $Attack/SwingsteinTimer/SwingsteinAttackTimer

@onready var javelin_base = $Attack/JavelinBase

# Magic Bullet
var magic_bullet_ammo = 0
@export var magic_bullet_baseammo = 1
@export var magic_bullet_attack_speed = 1
@export var magic_bullet_level = 1

# Slash
var slash_ammo = 0
@export var slash_baseammo = 1
@export var slash_attack_speed = 5
@export var slash_level = 1

# Swingstein
var swingstein_ammo = 0
@export var swingstein_baseammo = 1
@export var swingstein_attack_speed = 3
@export var swingstein_level = 1

# javelin
@export var javelin_ammo = 1
@export var javelin_level = 1

# Enemy Related
var enemy_close = []
var enemy_close_distance = []


# Exp related
var exp = 0
var exp_level = 1
var collected_exp = 0

var camera : Camera2D

var input = Vector2()
var knockback = Vector2()



func initialize(c:Camera2D):
	camera = c
	camera_remote_transform_2d.remote_path = camera.get_path()

func _ready():
	await get_tree().process_frame

	level_up_panel.modulate = Color(1,1,1,0)
	level_up_panel.hide()

	set_exp_bar(exp,calculate_exp_cap())

	attack()


func _physics_process(delta):

	enemy_detection_area.global_position = global_position

	movement(delta)
	pass

func movement(delta):
	get_movement_input()

	if input:
		last_movement = input

		velocity = velocity.move_toward((input) * speed, acceleration * delta)
		print((input + knockback))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)

	velocity += knockback

	knockback = Vector2.ZERO

	move_and_slide()


func get_movement_input():
	var x = Input.get_axis("left","right")
	var y = Input.get_axis("up","down" )
	input = Vector2(x,y).normalized()


func attack():
	toggle_weapon(magic_bullet_level, magic_bullet_timer, magic_bullet_attack_speed)
	toggle_weapon(slash_level,slash_timer,slash_attack_speed)
	toggle_weapon(swingstein_level,swingstein_timer,swingstein_attack_speed)

	if javelin_level > 0:
		spawn_javelin()

func toggle_weapon(weapon_level, weapon_timer, weapon_attack_speed):
	if weapon_level > 0:
		weapon_timer.wait_time = weapon_attack_speed
		if weapon_timer.is_stopped():
			weapon_timer.start()
		pass

func spawn_javelin():
	var get_javelin_total = javelin_base.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = JavelinScene.instantiate()
		javelin_spawn.global_position = global_position
		javelin_base.add_child(javelin_spawn)
		calc_spawns -= 1
	pass

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random()

func get_nearest_target():
	if enemy_close.size() > 0:
		# this will contain every item in ranges distance from player
		var i_dist = []

		for enemy in enemy_close:
			var dist = (global_position - enemy.global_position).length()
			i_dist.append(dist)
		# this will contain the min distance of the item in range in i_dist
		var idx_min = 0

		for i in range(1,len(i_dist)):
			if i_dist[i] < i_dist[idx_min]:
				idx_min = i

		# with idx_min we choose the min dist item to pickup
		var e = enemy_close[idx_min]
		return e.global_position
	else:
		return Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()



func calculate_exp(gem_exp):
	var exp_required = calculate_exp_cap()
	collected_exp += gem_exp

	if exp + collected_exp >= exp_required:
		collected_exp -= exp_required - exp
		exp_level += 1
		exp = 0
		exp_required = calculate_exp_cap()
		level_up()
		calculate_exp(0)
	else:
		exp += collected_exp
		collected_exp = 0

	set_exp_bar(exp, exp_required)
	pass

func calculate_exp_cap():
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level * 5
	elif exp_level < 40:
		exp_cap += 95 * (exp_level - 19) * 8
	else:
		exp_cap = 255 + (exp_level - 39) * 12
	return exp_cap
	pass


func set_exp_bar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

	pass


func level_up():
	snd_level_up.play()
	level_label.text = str('Level: ',exp_level)
	var tween = level_up_panel.create_tween()
	tween.tween_property(level_up_panel,'visible', true, .1)
	tween.tween_property(level_up_panel, 'modulate:a', 1, .5)
	tween.play()

	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = item_options.instantiate()
		upgrade_options.add_child(option_choice)
		options += 1

	get_tree().paused = true


	pass


func upgrade_character(upgrade):
	var option_children = upgrade_options.get_children()
	for i in option_children:
		i.queue_free()

	level_up_panel.modulate = Color(1,1,1,0)
	level_up_panel.hide()

	get_tree().paused = false

	pass


func _on_hurtbox_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = knockback_amount * angle
	if hp <= 0:
		get_tree().reload_current_scene()


func _on_magic_bullet_timer_timeout():
	magic_bullet_ammo += magic_bullet_baseammo
	magic_bullet_attack_timer.start()


func _on_magic_bullet_attack_timer_timeout():
	if magic_bullet_ammo > 0:
		var magic_attack = MagicBulletScene.instantiate()
		magic_attack.position = position
		magic_attack.target = get_nearest_target()
		magic_attack.level = magic_bullet_level
		add_child(magic_attack)
		magic_bullet_ammo -= 1
		if magic_bullet_ammo > 0:
			magic_bullet_attack_timer.start()
		else:
			magic_bullet_attack_timer.stop()

func _on_slash_timer_timeout():
	slash_ammo += slash_baseammo
	slash_attack_timer.start()


func _on_slash_attack_timer_timeout():
	if slash_ammo > 0:
		var slash_attack = SlashScene.instantiate()
		slash_attack.position = position
		slash_attack.target = get_nearest_target()
		slash_attack.level = slash_level
		add_child(slash_attack)
		slash_ammo -= 1
		if slash_ammo > 0:
			slash_attack_timer.start()
		else:
			slash_attack_timer.stop()

func _on_swingstein_timer_timeout():
	swingstein_ammo += swingstein_baseammo
	swingstein_attack_timer.start()


func _on_swingstein_attack_timer_timeout():
	if swingstein_ammo > 0:
		var swingstein_attack = SwingsteinScene.instantiate()
		swingstein_attack.position = position
		add_child(swingstein_attack)
		swingstein_level = swingstein_attack.level
		swingstein_ammo -= 1
		if swingstein_ammo > 0:
			swingstein_attack_timer.start()
		else:
			swingstein_attack_timer.stop()





func _on_enemy_detection_area_area_entered(area):
	if not enemy_close.has(area):
		enemy_close.append(area)


func _on_enemy_detection_area_area_exited(area):
	if enemy_close.has(area):
		enemy_close.erase(area)




func _on_grab_area_area_entered(area):
	if area.is_in_group('loot'):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group('loot'):
		var gem_exp = area.collected()
#		print(gem_exp)
		calculate_exp(gem_exp)
