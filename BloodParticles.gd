extends CPUParticles2D

var fadeTime = false


func _on_timer_timeout():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)


func _physics_process(delta: float) -> void:
	if fadeTime:
		modulate.a -= .01
		if modulate.a < .1:
			queue_free()

func _on_kill_timer_timeout():
	set_physics_process(true)
	fadeTime = true
	print(fadeTime)
