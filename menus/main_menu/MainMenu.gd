extends Node2D

func _ready():
	build_ui()

func build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Grid lines
	for i in range(0, 1152, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)
	for i in range(0, 648, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1152, 1)
		line.position = Vector2(0, i)
		add_child(line)

	# Glow center
	var glow = ColorRect.new()
	glow.color = Color(0.1, 0.2, 0.4, 0.3)
	glow.size = Vector2(600, 600)
	glow.position = Vector2(276, 24)
	add_child(glow)

	# Logo placeholder (kotak berwarna sebagai icon)
	var logo_bg = ColorRect.new()
	logo_bg.color = Color(0.1, 0.1, 0.3)
	logo_bg.size = Vector2(120, 120)
	logo_bg.position = Vector2(516, 80)
	add_child(logo_bg)

	var logo_icon = ColorRect.new()
	logo_icon.color = Color(0.4, 0.9, 1)
	logo_icon.size = Vector2(80, 80)
	logo_icon.position = Vector2(536, 100)
	add_child(logo_icon)

	var logo_shine = ColorRect.new()
	logo_shine.color = Color(1, 1, 1, 0.2)
	logo_shine.size = Vector2(25, 12)
	logo_shine.position = Vector2(541, 105)
	add_child(logo_shine)

	# Title
	var title = create_label("Protocol: Elysium", Vector2(0, 218), 52, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 65)
	add_child(title)

	var subtitle = create_label("Cybersecurity Battle Simulator", Vector2(0, 278), 16, Color(0.5, 0.6, 0.8))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1152, 25)
	add_child(subtitle)

	# Divider
	var div = ColorRect.new()
	div.color = Color(0.3, 0.3, 0.6, 0.5)
	div.size = Vector2(300, 1)
	div.position = Vector2(426, 312)
	add_child(div)

	# Buttons
	var play_btn = create_menu_button("▶   PLAY", Vector2(426, 335), Color(0.15, 0.5, 0.2))
	play_btn.pressed.connect(go_to_selection)
	add_child(play_btn)

	var dex_btn = create_menu_button("◈   Protocol-Link", Vector2(426, 405), Color(0.15, 0.35, 0.65))
	dex_btn.pressed.connect(go_to_cyberdex)
	add_child(dex_btn)

	var quit_btn = create_menu_button("✕   QUIT", Vector2(426, 475), Color(0.4, 0.1, 0.1))
	quit_btn.pressed.connect(quit_game)
	add_child(quit_btn)

	# Version + credit
	var version = create_label("v0.1 PROTOTYPE  —  Made by Anwarupee", Vector2(0, 620), 11, Color(0.3, 0.3, 0.5))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.custom_minimum_size = Vector2(1152, 20)
	add_child(version)

func create_menu_button(text: String, pos: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(300, 58)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.border_color = Color(1, 1, 1, 0.1)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.25)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func go_to_selection():
	var scene = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func go_to_cyberdex():
	var scene = load("res://menus/cyberdex/CyberDex.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func quit_game():
	get_tree().quit()
