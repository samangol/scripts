extends Node2D


@export var spawns: Array[SpawnInfo] = []

var player:Player 

var time = 0

func _ready():
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group('player')



func random_enemy_spawn_location():
	var random_direction = generate_random_vector() + player.global_position
	return random_direction


func generate_random_vector():
	var rand_vec = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randi_range(1000, 1500)
	return rand_vec


func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					spawn_enemy(new_enemy)
					counter += 1
					


func spawn_enemy(new_enemy):
	var enemy_spawn = new_enemy.instantiate()
	enemy_spawn.global_position = random_enemy_spawn_location()
	add_child(enemy_spawn)
