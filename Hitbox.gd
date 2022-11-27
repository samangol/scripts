extends Area2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var disable_timer = $DisableTimer

@export var damage = 1
@export var knockback_amount = 300
var angle = Vector2()

var player



func _process(delta):
	if player:
		angle = global_position.direction_to(player.global_position)


func temp_disable():
	collision_shape_2d.set_deferred('disabled',true)
	pass


func _on_disable_timer_timeout():
	collision_shape_2d.set_deferred('disabled',false)
	
	pass # Replace with function body.
