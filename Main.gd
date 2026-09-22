extends Node

# Entry point game — hanya tugasnya adalah panggil SceneManager untuk load MainMenu
# Tidak ada logic di sini

func _ready():
	SceneManager.goto_menu("res://menus/main_menu/MainMenu.tscn")
