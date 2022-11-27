extends Camera2D


signal camera_path_is(path)


func _ready():
	emit_signal("camera_path_is",self)
