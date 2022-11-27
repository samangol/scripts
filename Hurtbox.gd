extends Area2D

signal hurt(damage, angle, knockback)

@export_enum(Cooldown,HitOnce,DisableHitbox) var HurtBoxType = 0

@onready var collision_shape_2d = $CollisionShape2D
@onready var disable_timer = $DisableTimer

var hit_once_array = []

var damage
var angle
var knockback

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('attack'):
		if not area.get('damage') == null:
			
			match_hurtbox_type(area)
			
			get_area_hitbox_info(area)
			
			emit_signal("hurt", damage, angle, knockback)
			
			if area.has_method('enemy_hit'):
				area.enemy_hit(1)

func match_hurtbox_type(area):
	match HurtBoxType:
		0: # cooldown
			disable_collision_for_cooldown_time()
		1: # hitonce
			if hit_once_array.has(area) == false:
				hit_once_array.append(area)
				if area.has_signal('remove_from_array'):
					if not area.is_connected('remove_from_array',Callable(self,'remove_from_list')):
						area.connect('remove_from_array', Callable(self,'remove_from_list'))
			else:
				return
		2: # disabled hit box
			if area.has_method('temp_disable'):
				area.temp_disable()


func disable_collision_for_cooldown_time():
	collision_shape_2d.set_deferred('disabled', true)
	disable_timer.start()

func get_area_hitbox_info(area):
	damage = area.damage
	angle = Vector2.ZERO
	knockback = 1
	if not area.get('angle') == null:
		angle = area.angle
	if not area.get('knockback_amount') == null:
		knockback = area.knockback_amount
	

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)


func _on_DisableTimer_timeout():
	collision_shape_2d.set_deferred('disabled', false)
