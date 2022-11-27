extends Area2D

signal enemy_created 
signal remove_from_array(object)

@onready var body_polygon = $BodyPolygon
@onready var shadow_polygon = $ShadowPolygon
@onready var hitbox = %Hitbox
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D

var ExplodeAnimScene = preload("res://scenes/VFX/explode.tscn")
var BloodParticlesScene = preload("res://scenes/VFX/BloodParticles.tscn")
var GemScene = preload('res://scenes/Objects/gem.tscn')


@export var speed = 75
@export var hp = 10
@export var knockback_recovery = 3.5

var knockback = Vector2.ZERO

var player :Player 
var loot_base

var areas_close = []
var areas_close_dist = []

func initialize(p:Player):
	player = p

func _ready():
	await get_tree().process_frame
	
	
	connect_visibility_notifier()
	
	if !player:
		player = get_tree().get_first_node_in_group('player')
		
		loot_base = get_tree().get_first_node_in_group('loot')
		
		hitbox.player = player
		
func _physics_process(delta):
	
	if player:
		move_enemy(delta)


func move_enemy(delta):
	set_knockback_to_zero()
	
	position += (get_direction_of_player().normalized() + knockback/75) * speed * delta
	
	apply_fake_collision_to_areas_close(delta)


func set_knockback_to_zero():
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)

func get_direction_of_player():
	var direction_to_player = global_position.direction_to(player.global_position)
	return direction_to_player

func apply_fake_collision_to_areas_close(delta):
	if areas_close.size() > 0:
		for area in areas_close:
			area.position += (area.global_position - global_position).normalized() * delta * speed * 2


func connect_visibility_notifier():
	connect_visibility_on_screen_enter_exit(body_polygon,'show')
	connect_visibility_on_screen_enter_exit(shadow_polygon,'show')
	connect_visibility_on_screen_enter_exit(body_polygon,'hide')
	connect_visibility_on_screen_enter_exit(shadow_polygon,'hide')
	

func connect_visibility_on_screen_enter_exit(body,function):
	if function == 'show':
		visible_on_screen_notifier_2d.screen_entered.connect(Callable(body, function))
	else:
		visible_on_screen_notifier_2d.screen_exited.connect(Callable(body, function))



func on_death():
	AudioPlayerOverlapping.play_audio("res://assets/sfx/EnemyDeathSfx.wav")
	
	spawn_blood_particle()
	
	spawn_explosion_animation()
	
	spawn_gem()
	
	emit_signal("remove_from_array", self)
	queue_free()


func spawn_blood_particle():
	var blood_particle = BloodParticlesScene.instantiate()
	get_parent().call_deferred('add_child', blood_particle)
	blood_particle.global_position = global_position


func spawn_explosion_animation():
	var explode_animation = ExplodeAnimScene.instantiate()
	get_parent().call_deferred('add_child', explode_animation)
	explode_animation.global_position = global_position


func spawn_gem():
	var exp_gem = GemScene.instantiate()
	get_parent().call_deferred('add_child', exp_gem)
	exp_gem.global_position = global_position
	exp_gem.exp = randi_range(1,4)


func _on_hurtbox_hurt(damage, angle, knockback_amount):
	AudioPlayerOverlapping.play_audio("res://assets/sfx/EnemyHurtSfx.wav")
	hp -= damage
	knockback = knockback_amount * angle
	if hp <= 0:
		on_death()


func _on_area_entered(area):
	if not areas_close.has(area):
		areas_close.append(area)


func _on_area_exited(area):
	if areas_close.has(area):
		areas_close.erase(area)
