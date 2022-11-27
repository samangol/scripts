extends Area2D

@onready var shadow_2d = $Shadow2D
@onready var polygon_2d = $Polygon2D
@onready var collision_shape_2d = $CollisionShape2D

@export var exp = 1

var gem_low = Color.DEEP_SKY_BLUE
var gem_med = Color.WEB_PURPLE
var gem_high = Color.RED

var is_collected = false

var target = null
var speed = -2

func _ready():
	set_gem_exp_value()


func _physics_process(delta):
	
	move_gem_towards_player_if_in_range(delta)


func set_gem_exp_value():
	if exp < 5:
		polygon_2d.modulate = gem_low
	elif exp < 25:
		polygon_2d.modulate = gem_med
	else:
		polygon_2d.modulate = gem_high


func move_gem_towards_player_if_in_range(delta):
	if target:
		global_position = global_position.move_toward(target.global_position,speed)
		speed += 10 * delta

func collected():
	AudioPlayerOverlapping.play_audio("res://assets/sfx/LootCollectedSfx.wav")
	queue_free()
	return exp



func _on_visible_on_screen_notifier_2d_screen_entered():
	polygon_2d.show()
	shadow_2d.show()


func _on_visible_on_screen_notifier_2d_screen_exited():
	polygon_2d.hide()
	shadow_2d.hide()
