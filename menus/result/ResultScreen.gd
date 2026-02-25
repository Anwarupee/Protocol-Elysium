extends Node2D

var player_won: bool = false
var player_monster_name: String = ""
var enemy_monster_name: String = ""
var particles: Array = []
var time: float = 0.0

func _ready():
	if has_meta("player_won"):
		player_won = get_meta("player_won")
	if has_meta("player_monster_name"):
		player_monster_name = get_meta("player_monster_name")
	if has_meta("enemy_monster_name"):
		enemy_monster_name = get_meta("enemy_monster_name")
	build_ui()
	spawn_particles()
	animate_result()

func _process(delta):
	time += delta
	update_particles(delta)

func build_ui():
	var win_color = Color(0.2, 0.9, 0.4)
	var lose_color = Color(1, 0.25, 0.25)
	var accent = win_color if player_won else lose_color

	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Grid
	for i in range(0, 648, 60):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1152, 1)
		line.position = Vector2(0, i)
		add_child(line)
	for i in range(0, 1152, 60):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)

	# Scanlines
	for i in range(0, 648, 4):
		var scan = ColorRect.new()
		scan.color = Color(0, 0, 0, 0.025)
		scan.size = Vector2(1152, 2)
		scan.position = Vector2(0, i)
		add_child(scan)

	# Result glow overlay
	var glow_overlay = ColorRect.new()
	glow_overlay.color = Color(accent.r, accent.g, accent.b, 0.05)
	glow_overlay.size = Vector2(1152, 648)
	add_child(glow_overlay)

	# Center radial glow
	for i in range(6, 0, -1):
		var glow = ColorRect.new()
		var s = i * 120.0
		glow.color = Color(accent.r, accent.g, accent.b, 0.025 * i)
		glow.size = Vector2(s, s)
		glow.position = Vector2(576 - s/2, 280 - s/2)
		add_child(glow)

	# ── TOP BANNER ──
	var banner_bg = ColorRect.new()
	banner_bg.color = Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.12)
	banner_bg.size = Vector2(1152, 80)
	banner_bg.position = Vector2(0, 0)
	add_child(banner_bg)

	var banner_border = ColorRect.new()
	banner_border.color = accent
	banner_border.size = Vector2(1152, 3)
	banner_border.position = Vector2(0, 80)
	add_child(banner_border)

	var banner_label = create_label("— PROTOCOL: ELYSIUM —", Vector2(0, 28), 14, Color(accent.r, accent.g, accent.b, 0.6))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.custom_minimum_size = Vector2(1152, 20)
	add_child(banner_label)

	# ── RESULT ICON ──
	var icon_glow = ColorRect.new()
	icon_glow.color = Color(accent.r, accent.g, accent.b, 0.15)
	icon_glow.size = Vector2(160, 160)
	icon_glow.position = Vector2(496, 108)
	icon_glow.name = "icon_glow"
	add_child(icon_glow)

	var icon_mid = ColorRect.new()
	icon_mid.color = Color(accent.r, accent.g, accent.b, 0.25)
	icon_mid.size = Vector2(120, 120)
	icon_mid.position = Vector2(516, 128)
	add_child(icon_mid)

	var icon = ColorRect.new()
	icon.color = accent
	icon.size = Vector2(80, 80)
	icon.position = Vector2(536, 148)
	icon.name = "result_icon"
	add_child(icon)

	var icon_shine = ColorRect.new()
	icon_shine.color = Color(1, 1, 1, 0.2)
	icon_shine.size = Vector2(28, 12)
	icon_shine.position = Vector2(541, 153)
	add_child(icon_shine)

	var icon_symbol = create_label("✓" if player_won else "✗", Vector2(0, 153), 36, Color(0.05, 0.1, 0.05) if player_won else Color(0.1, 0.03, 0.03))
	icon_symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_symbol.custom_minimum_size = Vector2(1152, 50)
	add_child(icon_symbol)

	# ── RESULT TITLE ──
	var title_text = "SYSTEM SECURED!" if player_won else "SYSTEM COMPROMISED!"
	var title_shadow = create_label(title_text, Vector2(2, 252), 42, Color(accent.r * 0.3, accent.g * 0.3, accent.b * 0.3))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.custom_minimum_size = Vector2(1152, 55)
	add_child(title_shadow)

	var title = create_label(title_text, Vector2(0, 250), 42, accent)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 55)
	title.name = "result_title"
	add_child(title)

	# Accent lines
	var line_left = ColorRect.new()
	line_left.color = Color(accent.r, accent.g, accent.b, 0.5)
	line_left.size = Vector2(200, 2)
	line_left.position = Vector2(150, 278)
	add_child(line_left)

	var line_right = ColorRect.new()
	line_right.color = Color(accent.r, accent.g, accent.b, 0.5)
	line_right.size = Vector2(200, 2)
	line_right.position = Vector2(802, 278)
	add_child(line_right)

	# ── MATCHUP INFO ──
	var matchup_bg = ColorRect.new()
	matchup_bg.color = Color(0.07, 0.07, 0.2, 0.9)
	matchup_bg.size = Vector2(500, 42)
	matchup_bg.position = Vector2(326, 312)
	add_child(matchup_bg)

	var matchup_border = ColorRect.new()
	matchup_border.color = Color(accent.r, accent.g, accent.b, 0.4)
	matchup_border.size = Vector2(500, 2)
	matchup_border.position = Vector2(326, 312)
	add_child(matchup_border)

	var p_name = player_monster_name if player_monster_name != "" else "Your Sentinel"
	var e_name = enemy_monster_name if enemy_monster_name != "" else "Enemy Sentinel"
	var result_tag = "VICTORY" if player_won else "DEFEAT"

	var matchup_label = create_label(p_name + "  ⚔  " + e_name + "  —  " + result_tag, Vector2(326, 323), 13, Color(0.7, 0.7, 0.9))
	matchup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	matchup_label.custom_minimum_size = Vector2(500, 20)
	add_child(matchup_label)

	# ── EDU MESSAGE ──
	var edu_texts_win = [
		"Defense in Depth: Sistem yang kuat membutuhkan lapisan pertahanan berlapis, bukan hanya satu garis pertahanan.",
		"Principle of Least Privilege: Batasi akses hanya pada apa yang diperlukan untuk meminimalkan dampak serangan.",
		"Patch Management: Update rutin menutup celah keamanan sebelum dieksploitasi attacker."
	]
	var edu_texts_lose = [
		"Zero-Day Vulnerability: Celah yang belum diketahui vendor sangat berbahaya. Selalu monitor sistem secara aktif.",
		"Social Engineering: 90% serangan siber melibatkan faktor manusia. Edukasi adalah pertahanan terbaik.",
		"Incident Response: Ketika sistem dikompromis, kecepatan respons menentukan seberapa besar dampaknya."
	]
	var edu_list = edu_texts_win if player_won else edu_texts_lose
	var edu_text = edu_list[randi() % edu_list.size()]

	var edu_panel = ColorRect.new()
	edu_panel.color = Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.06, 0.95)
	edu_panel.size = Vector2(800, 75)
	edu_panel.position = Vector2(176, 375)
	add_child(edu_panel)

	var edu_border_top = ColorRect.new()
	edu_border_top.color = Color(accent.r, accent.g, accent.b, 0.5)
	edu_border_top.size = Vector2(800, 2)
	edu_border_top.position = Vector2(176, 375)
	add_child(edu_border_top)

	var edu_border_left = ColorRect.new()
	edu_border_left.color = Color(accent.r, accent.g, accent.b, 0.3)
	edu_border_left.size = Vector2(3, 75)
	edu_border_left.position = Vector2(176, 375)
	add_child(edu_border_left)

	var edu_tag = create_label("[ EDU-LOG ]", Vector2(190, 383), 11, Color(accent.r, accent.g, accent.b, 0.8))
	add_child(edu_tag)

	var edu_label = create_label(edu_text, Vector2(290, 383), 12, Color(0.75, 0.85, 0.75))
	edu_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	edu_label.custom_minimum_size = Vector2(670, 60)
	add_child(edu_label)

	# ── BUTTONS ──
	var btn_play = create_styled_button("⚔  MAIN LAGI", Vector2(256, 478), Vector2(260, 52), Color(0.08, 0.35, 0.12))
	btn_play.pressed.connect(go_to_selection)
	add_child(btn_play)

	var btn_menu = create_styled_button("⌂  MAIN MENU", Vector2(546, 478), Vector2(260, 52), Color(0.08, 0.2, 0.4))
	btn_menu.pressed.connect(go_to_main_menu)
	add_child(btn_menu)

	var btn_quit = create_styled_button("✕  QUIT", Vector2(836, 478), Vector2(140, 52), Color(0.35, 0.08, 0.08))
	btn_quit.pressed.connect(quit_game)
	add_child(btn_quit)

	# ── BOTTOM BAR ──
	var bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.06, 0.06, 0.18)
	bottom_bar.size = Vector2(1152, 30)
	bottom_bar.position = Vector2(0, 618)
	add_child(bottom_bar)

	var bottom_border = ColorRect.new()
	bottom_border.color = Color(accent.r, accent.g, accent.b, 0.3)
	bottom_border.size = Vector2(1152, 1)
	bottom_border.position = Vector2(0, 618)
	add_child(bottom_border)

	var bottom_label = create_label("Protocol: Elysium  —  Cybersecurity Battle Simulator", Vector2(0, 623), 11, Color(0.3, 0.3, 0.5))
	bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_label.custom_minimum_size = Vector2(1152, 20)
	add_child(bottom_label)

func spawn_particles():
	var accent = Color(0.2, 0.9, 0.4) if player_won else Color(1, 0.25, 0.25)
	for i in 50:
		var p = ColorRect.new()
		var sz = randf_range(2.0, 5.0)
		p.size = Vector2(sz, sz)
		p.position = Vector2(randf_range(0, 1152), randf_range(0, 648))
		p.color = Color(
			accent.r * randf_range(0.5, 1.0),
			accent.g * randf_range(0.5, 1.0),
			accent.b * randf_range(0.5, 1.0),
			randf_range(0.3, 0.7)
		)
		add_child(p)
		particles.append({
			"node": p,
			"vel": Vector2(randf_range(-20, 20), randf_range(-35, -10)),
			"base_alpha": randf_range(0.3, 0.7),
			"phase": randf_range(0, TAU)
		})

func update_particles(delta: float):
	for p in particles:
		p["node"].position += p["vel"] * delta
		if p["node"].position.y < -10:
			p["node"].position.y = 658
			p["node"].position.x = randf_range(0, 1152)
		if p["node"].position.x < -10:
			p["node"].position.x = 1162
		if p["node"].position.x > 1162:
			p["node"].position.x = -10
		var alpha = p["base_alpha"] + sin(time * 2.5 + p["phase"]) * 0.2
		p["node"].color.a = clamp(alpha, 0.05, 0.9)

	# Icon pulse
	var icon = get_node_or_null("result_icon")
	if icon:
		var pulse = 0.9 + sin(time * 2.0) * 0.08
		icon.scale = Vector2(pulse, pulse)
		icon.position = Vector2(536 + (1 - pulse) * 40, 148 + (1 - pulse) * 40)

func animate_result():
	var title = get_node_or_null("result_title")
	if title:
		title.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(title, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(title, "position:y", 250, 1.2).set_trans(Tween.TRANS_BACK).from(230)

	var icon = get_node_or_null("icon_glow")
	if icon:
		icon.modulate.a = 0.0
		var tween2 = create_tween()
		tween2.tween_property(icon, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

func go_to_selection():
	var scene = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func go_to_main_menu():
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
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = Color(1, 1, 1, 0.15)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.border_color = Color(1, 1, 1, 0.4)
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
