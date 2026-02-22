extends Node2D

var player_won: bool = false
var player_monster_name: String = ""
var enemy_monster_name: String = ""

func _ready():
	if has_meta("player_won"):
		player_won = get_meta("player_won")
	if has_meta("player_monster_name"):
		player_monster_name = get_meta("player_monster_name")
	if has_meta("enemy_monster_name"):
		enemy_monster_name = get_meta("enemy_monster_name")
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

	# Result glow background
	var glow_color = Color(0.1, 0.4, 0.1) if player_won else Color(0.4, 0.05, 0.05)
	var glow = ColorRect.new()
	glow.color = glow_color
	glow.size = Vector2(1152, 648)
	glow.modulate = Color(1, 1, 1, 0.15)
	add_child(glow)

	# Result icon (big square placeholder)
	var icon_color = Color(0.3, 1, 0.4) if player_won else Color(1, 0.3, 0.3)
	var icon = ColorRect.new()
	icon.color = icon_color
	icon.size = Vector2(100, 100)
	icon.position = Vector2(526, 120)
	add_child(icon)

	var icon_glow = ColorRect.new()
	icon_glow.color = Color(icon_color.r, icon_color.g, icon_color.b, 0.2)
	icon_glow.size = Vector2(140, 140)
	icon_glow.position = Vector2(506, 100)
	add_child(icon_glow)
	move_child(icon_glow, icon_glow.get_index() - 1)

	# Result title
	var title_text = "SYSTEM SECURED!" if player_won else "SYSTEM COMPROMISED!"
	var title_color = Color(0.3, 1, 0.5) if player_won else Color(1, 0.3, 0.3)
	var title = create_label(title_text, Vector2(576, 250), 36, title_color)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 50)
	title.position = Vector2(0, 250)
	add_child(title)

	# Subtitle
	var sub_text = ""
	if player_won:
		sub_text = player_monster_name + " berhasil mengalahkan " + enemy_monster_name + "!"
	else:
		sub_text = enemy_monster_name + " berhasil menembus pertahananmu!"
	var subtitle = create_label(sub_text, Vector2(0, 310), 18, Color(0.8, 0.8, 0.8))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1152, 30)
	add_child(subtitle)

	# Edu message
	var edu_text = ""
	if player_won:
		edu_text = "Sistem yang terlindungi dengan baik membutuhkan lapisan pertahanan berlapis (Defense in Depth)."
	else:
		edu_text = "Setiap sistem memiliki celah. Identifikasi kelemahan dan lakukan patching secara rutin!"
	
	var edu_bg = ColorRect.new()
	edu_bg.color = Color(0.03, 0.12, 0.07)
	edu_bg.size = Vector2(800, 60)
	edu_bg.position = Vector2(176, 370)
	add_child(edu_bg)

	var edu_border = ColorRect.new()
	edu_border.color = Color(0.2, 0.7, 0.3, 0.6)
	edu_border.size = Vector2(800, 2)
	edu_border.position = Vector2(176, 370)
	add_child(edu_border)

	add_child(create_label("[ EDU-LOG ]", Vector2(196, 378), 12, Color(0.3, 1, 0.4)))
	var edu_label = create_label(edu_text, Vector2(300, 378), 12, Color(0.7, 1, 0.7))
	edu_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	edu_label.custom_minimum_size = Vector2(650, 50)
	add_child(edu_label)

	# Buttons
	var play_again_btn = create_styled_button(
		"⚔️  PILIH MONSTER LAGI",
		Vector2(326, 470),
		Vector2(220, 55),
		Color(0.15, 0.45, 0.15)
	)
	play_again_btn.pressed.connect(go_to_selection)
	add_child(play_again_btn)

	var quit_btn = create_styled_button(
		"✕  KELUAR",
		Vector2(606, 470),
		Vector2(220, 55),
		Color(0.45, 0.1, 0.1)
	)
	quit_btn.pressed.connect(quit_game)
	add_child(quit_btn)

	# Stats panel
	var stats_bg = ColorRect.new()
	stats_bg.color = Color(0.08, 0.08, 0.2, 0.9)
	stats_bg.size = Vector2(400, 70)
	stats_bg.position = Vector2(376, 548)
	add_child(stats_bg)

	var stats_border = ColorRect.new()
	stats_border.color = Color(0.3, 0.3, 0.6)
	stats_border.size = Vector2(400, 2)
	stats_border.position = Vector2(376, 548)
	add_child(stats_border)

	var result_tag = "VICTORY" if player_won else "DEFEAT"
	var stats_label = create_label(
		player_monster_name + "  vs  " + enemy_monster_name + "  —  " + result_tag,
		Vector2(376, 568),
		13,
		Color(0.6, 0.6, 0.8)
	)
	stats_label.custom_minimum_size = Vector2(400, 30)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(stats_label)

func go_to_selection():
	var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func quit_game():
	get_tree().quit()

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func create_styled_button(text: String, pos: Vector2, size: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = size

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.3)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
