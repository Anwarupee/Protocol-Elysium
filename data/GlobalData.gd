extends Node

var is_first_time: bool = true

func _ready():
	_load()

func mark_played():
	is_first_time = false
	_save()

func _save():
	var f = FileAccess.open("user://savedata.cfg", FileAccess.WRITE)
	f.store_string("played")
	f.close()

func _load():
	print("Save path: ", ProjectSettings.globalize_path("user://savedata.cfg"))
	if FileAccess.file_exists("user://savedata.cfg"):
		is_first_time = false
		print("Save found — bukan first time")
	else:
		print("No save — first time!")
