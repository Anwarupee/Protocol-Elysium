extends Node2D

var player_won: bool = false
var player_monster_name: String = ""
var enemy_monster_name: String = ""
var particles: Array = []
var time: float = 0.0
var moves_used: Array = []

func _ready():
	# Baca dari GlobalData.battle_result — tidak ada root meta lagi
	var r = GlobalData.battle_result
	player_won          = r.get("player_won", false)
	player_monster_name = r.get("player_name", "")
	enemy_monster_name  = r.get("enemy_name", "")
	moves_used          = r.get("moves_used", [])
	build_ui()
	spawn_particles()
	animate_result()

func _process(delta):
	time += delta
	update_particles(delta)

func build_ui():
	var win_color  = Color(0.2, 0.9, 0.4)
	var lose_color = Color(1, 0.25, 0.25)
	var accent     = win_color if player_won else lose_color

	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12)
	bg.size  = Vector2(1920, 1080)
	add_child(bg)

	for i in range(0, 1080, 100):
		var l = ColorRect.new(); l.color = Color(0.2, 0.3, 0.6, 0.04)
		l.size = Vector2(1920, 1); l.position = Vector2(0, i); add_child(l)
	for i in range(0, 1920, 100):
		var l = ColorRect.new(); l.color = Color(0.2, 0.3, 0.6, 0.04)
		l.size = Vector2(1, 1080); l.position = Vector2(i, 0); add_child(l)
	for i in range(0, 1080, 6):
		var s = ColorRect.new(); s.color = Color(0, 0, 0, 0.025)
		s.size = Vector2(1920, 3); s.position = Vector2(0, i); add_child(s)

	var glow_overlay = ColorRect.new()
	glow_overlay.color = Color(accent.r, accent.g, accent.b, 0.05)
	glow_overlay.size  = Vector2(1920, 1080)
	add_child(glow_overlay)

	for i in range(6, 0, -1):
		var glow = ColorRect.new()
		var s = i * 200.0
		glow.color    = Color(accent.r, accent.g, accent.b, 0.025 * i)
		glow.size     = Vector2(s, s)
		glow.position = Vector2(960 - s/2, 470 - s/2)
		add_child(glow)

	# ── TOP BANNER ──
	var banner_bg = ColorRect.new()
	banner_bg.color    = Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.12)
	banner_bg.size     = Vector2(1920, 100)
	add_child(banner_bg)
	var banner_border = ColorRect.new()
	banner_border.color    = accent
	banner_border.size     = Vector2(1920, 4)
	banner_border.position = Vector2(0, 100)
	add_child(banner_border)
	var banner_lbl = create_label("— PROTOCOL: ELYSIUM —", Vector2(0, 36), 22, Color(accent.r, accent.g, accent.b, 0.6))
	banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_lbl.custom_minimum_size  = Vector2(1920, 30)
	add_child(banner_lbl)

	# ── RESULT ICON ──
	var icon_glow = ColorRect.new()
	icon_glow.color    = Color(accent.r, accent.g, accent.b, 0.15)
	icon_glow.size     = Vector2(240, 240)
	icon_glow.position = Vector2(840, 155)
	icon_glow.name     = "icon_glow"
	add_child(icon_glow)
	var icon_mid = ColorRect.new()
	icon_mid.color    = Color(accent.r, accent.g, accent.b, 0.25)
	icon_mid.size     = Vector2(180, 180)
	icon_mid.position = Vector2(870, 185)
	add_child(icon_mid)
	var icon = ColorRect.new()
	icon.color    = accent
	icon.size     = Vector2(120, 120)
	icon.position = Vector2(900, 215)
	icon.name     = "result_icon"
	add_child(icon)
	var icon_shine = ColorRect.new()
	icon_shine.color    = Color(1, 1, 1, 0.2)
	icon_shine.size     = Vector2(42, 18)
	icon_shine.position = Vector2(908, 222)
	add_child(icon_shine)
	var icon_symbol = create_label("✓" if player_won else "✗", Vector2(0, 225), 55, Color(0.05, 0.1, 0.05) if player_won else Color(0.1, 0.03, 0.03))
	icon_symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_symbol.custom_minimum_size  = Vector2(1920, 80)
	add_child(icon_symbol)

	# ── RESULT TITLE ──
	var title_text   = "SYSTEM SECURED!" if player_won else "SYSTEM COMPROMISED!"
	var title_shadow = create_label(title_text, Vector2(3, 423), 65, Color(accent.r * 0.3, accent.g * 0.3, accent.b * 0.3))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.custom_minimum_size  = Vector2(1920, 80)
	add_child(title_shadow)
	var title = create_label(title_text, Vector2(0, 420), 65, accent)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size  = Vector2(1920, 80)
	title.name = "result_title"
	add_child(title)

	var line_left = ColorRect.new()
	line_left.color    = Color(accent.r, accent.g, accent.b, 0.5)
	line_left.size     = Vector2(280, 3)
	line_left.position = Vector2(200, 465)
	add_child(line_left)
	var line_right = ColorRect.new()
	line_right.color    = Color(accent.r, accent.g, accent.b, 0.5)
	line_right.size     = Vector2(280, 3)
	line_right.position = Vector2(1440, 465)
	add_child(line_right)

	# ── MATCHUP ──
	var matchup_bg = ColorRect.new()
	matchup_bg.color    = Color(0.07, 0.07, 0.2, 0.9)
	matchup_bg.size     = Vector2(700, 55)
	matchup_bg.position = Vector2(610, 488)
	add_child(matchup_bg)
	var matchup_border = ColorRect.new()
	matchup_border.color    = Color(accent.r, accent.g, accent.b, 0.4)
	matchup_border.size     = Vector2(700, 3)
	matchup_border.position = Vector2(610, 488)
	add_child(matchup_border)
	var p_name     = player_monster_name if player_monster_name != "" else "Your Sentinel"
	var e_name     = enemy_monster_name  if enemy_monster_name  != "" else "Enemy Sentinel"
	var result_tag = "VICTORY" if player_won else "DEFEAT"
	var matchup_lbl = create_label(p_name + "  ✕  " + e_name + "  —  " + result_tag, Vector2(610, 505), 20, Color(0.7, 0.7, 0.9))
	matchup_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	matchup_lbl.custom_minimum_size  = Vector2(700, 30)
	add_child(matchup_lbl)

	# ── EDU LOG ──
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
	edu_panel.color    = Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.06, 0.95)
	edu_panel.size     = Vector2(1100, 90)
	edu_panel.position = Vector2(410, 565)
	add_child(edu_panel)
	var edu_border_top = ColorRect.new()
	edu_border_top.color    = Color(accent.r, accent.g, accent.b, 0.5)
	edu_border_top.size     = Vector2(1100, 3)
	edu_border_top.position = Vector2(410, 565)
	add_child(edu_border_top)
	var edu_border_left = ColorRect.new()
	edu_border_left.color    = Color(accent.r, accent.g, accent.b, 0.3)
	edu_border_left.size     = Vector2(4, 90)
	edu_border_left.position = Vector2(410, 565)
	add_child(edu_border_left)
	var edu_tag = create_label("[ EDU-LOG ]", Vector2(425, 576), 16, Color(accent.r, accent.g, accent.b, 0.8))
	add_child(edu_tag)
	var edu_lbl = create_label(edu_text, Vector2(545, 576), 17, Color(0.75, 0.85, 0.75))
	edu_lbl.autowrap_mode     = TextServer.AUTOWRAP_WORD
	edu_lbl.custom_minimum_size = Vector2(940, 75)
	add_child(edu_lbl)

	call_deferred("show_quiz")

	# ── BUTTONS ──
	var btn_play = create_styled_button("⚔  MAIN LAGI", Vector2(360, 690), Vector2(380, 72), Color(0.08, 0.35, 0.12))
	btn_play.pressed.connect(go_to_selection)
	add_child(btn_play)
	var btn_menu = create_styled_button("⌂  MAIN MENU", Vector2(770, 690), Vector2(380, 72), Color(0.08, 0.2, 0.4))
	btn_menu.pressed.connect(go_to_main_menu)
	add_child(btn_menu)
	var btn_quit = create_styled_button("✕  QUIT", Vector2(1180, 690), Vector2(380, 72), Color(0.35, 0.08, 0.08))
	btn_quit.pressed.connect(quit_game)
	add_child(btn_quit)

	# ── BOTTOM BAR ──
	var bottom_bar = ColorRect.new()
	bottom_bar.color    = Color(0.06, 0.06, 0.18)
	bottom_bar.size     = Vector2(1920, 45)
	bottom_bar.position = Vector2(0, 1035)
	add_child(bottom_bar)
	var bottom_border = ColorRect.new()
	bottom_border.color    = Color(accent.r, accent.g, accent.b, 0.3)
	bottom_border.size     = Vector2(1920, 2)
	bottom_border.position = Vector2(0, 1035)
	add_child(bottom_border)
	var bottom_lbl = create_label("Protocol: Elysium  —  Cybersecurity Battle Simulator", Vector2(0, 1048), 17, Color(0.3, 0.3, 0.5))
	bottom_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_lbl.custom_minimum_size  = Vector2(1920, 30)
	add_child(bottom_lbl)

func show_quiz():
	if moves_used.is_empty(): return
	var move      = moves_used[randi() % moves_used.size()]
	var move_name = move["name"]
	var edu_text  = move.get("edu_popup", move.get("edu_log", ""))
	if edu_text == "": return

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.size  = Vector2(1920, 1080)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color    = Color(0.07, 0.08, 0.22)
	panel.size     = Vector2(1100, 480)
	panel.position = Vector2(410, 300)
	overlay.add_child(panel)

	var border = ColorRect.new()
	border.color = Color(0.4, 0.9, 1)
	border.size  = Vector2(1100, 4)
	panel.add_child(border)

	var tag = Label.new()
	tag.text     = "[ INTEL QUIZ ]  — Kamu tadi pakai " + move_name + "!"
	tag.position = Vector2(28, 18)
	tag.add_theme_font_size_override("font_size", 20)
	tag.add_theme_color_override("font_color", Color(0.4, 0.9, 1))
	panel.add_child(tag)

	var question_lbl = Label.new()
	question_lbl.text           = "Apa yang sebenarnya terjadi saat " + move_name + " digunakan di dunia nyata?"
	question_lbl.position       = Vector2(28, 54)
	question_lbl.size           = Vector2(1044, 70)
	question_lbl.autowrap_mode  = TextServer.AUTOWRAP_WORD
	question_lbl.add_theme_font_size_override("font_size", 26)
	question_lbl.add_theme_color_override("font_color", Color(1, 1, 0.9))
	panel.add_child(question_lbl)

	var correct_answer = edu_text.split(".")[0] + "."
	var wrong_answers  = _get_wrong_answers(move_name)
	var all_options    = wrong_answers.slice(0, 3)
	var correct_idx    = randi() % 4
	all_options.insert(correct_idx, correct_answer)

	var option_bgs  = []
	var option_btns = []
	for i in 4:
		var opt_bg = ColorRect.new()
		opt_bg.color    = Color(0.1, 0.12, 0.3)
		opt_bg.size     = Vector2(1044, 55)
		opt_bg.position = Vector2(28, 140 + i * 65)
		panel.add_child(opt_bg)
		option_bgs.append(opt_bg)

		var opt_btn = Button.new()
		opt_btn.text      = "  " + ["A", "B", "C", "D"][i] + ".  " + all_options[i]
		opt_btn.position  = Vector2(28, 140 + i * 65)
		opt_btn.size      = Vector2(1044, 55)
		opt_btn.flat      = true
		opt_btn.add_theme_font_size_override("font_size", 19)
		opt_btn.add_theme_color_override("font_color", Color(0.85, 0.9, 1))
		opt_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		panel.add_child(opt_btn)
		option_btns.append(opt_btn)

	var feedback_lbl = Label.new()
	feedback_lbl.position = Vector2(28, 415)
	feedback_lbl.size     = Vector2(750, 35)
	feedback_lbl.add_theme_font_size_override("font_size", 19)
	feedback_lbl.visible  = false
	panel.add_child(feedback_lbl)

	var next_btn = Button.new()
	next_btn.text     = "Lanjut  ▶"
	next_btn.position = Vector2(870, 408)
	next_btn.size     = Vector2(200, 50)
	next_btn.visible  = false
	var ns = StyleBoxFlat.new()
	ns.bg_color = Color(0.1, 0.4, 0.15)
	ns.set_corner_radius_all(8)
	next_btn.add_theme_stylebox_override("normal", ns)
	next_btn.add_theme_font_size_override("font_size", 20)
	next_btn.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(next_btn)

	overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.25)
	await tween.finished

	var answered = false
	for i in option_btns.size():
		var idx = i
		option_btns[i].pressed.connect(func():
			if answered: return
			answered = true
			for j in option_btns.size():
				option_btns[j].disabled = true
				option_bgs[j].color = Color(0.05, 0.3, 0.1) if j == correct_idx else Color(0.25, 0.07, 0.07)
			if idx == correct_idx:
				feedback_lbl.text = "✓ Tepat sekali!"
				feedback_lbl.add_theme_color_override("font_color", Color(0.3, 1, 0.4))
			else:
				feedback_lbl.text = "✗ Kurang tepat — jawaban benar sudah ditandai hijau."
				feedback_lbl.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
			feedback_lbl.visible = true
			next_btn.visible     = true
		)

	await next_btn.pressed
	if is_instance_valid(overlay):
		var tween2 = create_tween()
		tween2.tween_property(overlay, "modulate:a", 0.0, 0.2)
		await tween2.finished
	if is_instance_valid(overlay):
		overlay.queue_free()

func _get_wrong_answers(_move_name: String) -> Array:
	var pool = [
		"Teknik untuk mempercepat koneksi internet pengguna.",
		"Metode backup otomatis yang melindungi data dari kehilangan.",
		"Protokol komunikasi standar yang digunakan semua perangkat.",
		"Fitur keamanan bawaan sistem operasi yang aktif secara default.",
		"Cara mengoptimalkan penggunaan memori RAM pada server.",
		"Sistem autentikasi dua faktor untuk melindungi akun pengguna.",
		"Algoritma enkripsi yang digunakan bank untuk transaksi online.",
		"Proses verifikasi identitas pengguna sebelum mengakses sistem."
	]
	pool.shuffle()
	return pool.slice(0, 3)

func spawn_particles():
	var accent = Color(0.2, 0.9, 0.4) if player_won else Color(1, 0.25, 0.25)
	for i in 60:
		var p  = ColorRect.new()
		var sz = randf_range(2.0, 6.0)
		p.size     = Vector2(sz, sz)
		p.position = Vector2(randf_range(0, 1920), randf_range(0, 1080))
		p.color    = Color(accent.r * randf_range(0.5, 1.0), accent.g * randf_range(0.5, 1.0), accent.b * randf_range(0.5, 1.0), randf_range(0.3, 0.7))
		add_child(p)
		particles.append({"node": p, "vel": Vector2(randf_range(-20, 20), randf_range(-35, -10)), "base_alpha": randf_range(0.3, 0.7), "phase": randf_range(0, TAU)})

func update_particles(delta: float):
	for p in particles:
		p["node"].position += p["vel"] * delta
		if p["node"].position.y < -10:
			p["node"].position.y = 1090
			p["node"].position.x = randf_range(0, 1920)
		if p["node"].position.x < -10:  p["node"].position.x = 1930
		if p["node"].position.x > 1930: p["node"].position.x = -10
		p["node"].color.a = clamp(p["base_alpha"] + sin(time * 2.5 + p["phase"]) * 0.2, 0.05, 0.9)
	var icon = get_node_or_null("result_icon")
	if icon:
		var pulse = 0.9 + sin(time * 2.0) * 0.08
		icon.scale    = Vector2(pulse, pulse)
		icon.position = Vector2(900 + (1 - pulse) * 60, 215 + (1 - pulse) * 60)

func animate_result():
	var title = get_node_or_null("result_title")
	if title:
		title.modulate.a = 0.0
		var t = create_tween()
		t.tween_property(title, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(title, "position:y", 420, 1.2).set_trans(Tween.TRANS_BACK).from(390)
	var icon = get_node_or_null("icon_glow")
	if icon:
		icon.modulate.a = 0.0
		create_tween().tween_property(icon, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

func go_to_selection():
	GlobalData.clear_battle_result()
	# Kalau ada map aktif, pop overlay kembali ke map
	# Kalau tidak ada map (battle dari SelectionScreen), ke SelectionScreen
	if SceneManager.is_in_map():
		SceneManager.pop_overlay()
	else:
		SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")

# _clear_encounter_meta sudah tidak diperlukan
# semua cleanup dilakukan via GlobalData

func go_to_main_menu():
	GlobalData.clear_battle_result()
	SceneManager.goto_menu("res://menus/main_menu/MainMenu.tscn")

func quit_game(): get_tree().quit()

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text; l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func create_styled_button(text: String, pos: Vector2, sz: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = sz
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(10)
	style.border_color = Color(1, 1, 1, 0.15)
	style.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.2)
	hover.border_color = Color(1, 1, 1, 0.4)
	hover.set_border_width_all(3)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
