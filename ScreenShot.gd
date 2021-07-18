extends Node

onready var output_path = get_node("/root/MainScene/UI/MapOptions/LineEdit_Path").get_text()

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("capture_image"):
		make_screenshot()

func _on_ButtonSave_pressed():
	make_screenshot()

func make_screenshot():
	var image = get_viewport().get_texture().get_data()
	image.flip_y()

	image.save_png("%sDawnOfWorldsMap.png" % [output_path])

func _check_path(path):
	if OS.is_debug_build():
		var message = 'WARNING: No directory "%s"'
		var dir = Directory.new()
		dir.open(path)
		if not dir.dir_exists(path):
			print(message % path)
			#breakpoint

func set_output_path(path):
	_check_path(path)
	output_path = path


