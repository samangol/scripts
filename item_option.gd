extends MarginContainer

signal selected_upgrade(upgrade)

@onready var bg = get_node('%Bg')

var mouse_over = false
var item = null

var player

func _ready():
	check_bg_color()
	if !player:
		player = get_tree().get_first_node_in_group('player')
	
	connect('selected_upgrade',Callable(player,'upgrade_character'))
	

func _input(event):
	if event.is_action("click"):
		if mouse_over:
			emit_signal('selected_upgrade',item)

func check_bg_color():
	if mouse_over:
		bg.modulate = Color('6a6a6a')
	else:
		bg.modulate = Color('424242')

func _on_mouse_entered():
	mouse_over = true
	check_bg_color()

func _on_mouse_exited():
	mouse_over = false
	check_bg_color()
