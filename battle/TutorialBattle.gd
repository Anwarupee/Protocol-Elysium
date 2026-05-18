extends "res://battle/Battle.gd"

# ══════════════════════════════════════════════
#  TutorialBattle.gd — Guided Tutorial
#  Step-by-step: kenalkan UI → tipe → move → battle
# ══════════════════════════════════════════════

var tutorial_active: bool = false
var tutorial_step: int = 0

# Index move Encryp-Pup:
# 0 = Encrypt (buff)
# 1 = Firewall Bark (attack + block)
# 2 = Backup Howl (heal)
# 3 = SSL Handshake (attack)

const STEP_FREE_BATTLE = 99  # setelah tutorial selesai, battle bebas

func _ready():
	original_position = position
	edu_popup = get_node_or_null("EduPopup")
	var player_choice = "encryp_pup"
	if has_meta("player_monster"):
		player_choice = get_meta("player_monster")

	var enemy_choice = "biti"

	battle_manager.load_monsters()

	var player_data = battle_manager.get_monster_data(player_choice)
	var enemy_data  = battle_manager.get_monster_data(enemy_choice)

	if player_data.is_empty() or enemy_data.is_empty():
		push_error("Monster data not found!")
		return

	build_ui(player_data, enemy_data)
	connect_signals()
	battle_manager.start_battle(player_choice, enemy_choice)
	await play_intro_animation()
	await start_tutorial_flow()

# ── Override move button press saat tutorial aktif ──
func on_move_pressed(index: int):
	if tutorial_active and tutorial_step != STEP_FREE_BATTLE:
		match tutorial_step:
			1:  # Minta pakai Encrypt (index 0)
				if index != 0:
					await show_tutorial_hint("Coba gunakan  ENCRYPT  dulu ya!")
					return
			2:  # Minta pakai Firewall Bark (index 1)
				if index != 1:
					await show_tutorial_hint("Sekarang coba gunakan  FIREWALL BARK!")
					return
			3:  # Minta pakai Backup Howl (index 2)
				if index != 2:
					await show_tutorial_hint("Gunakan  BACKUP HOWL  untuk memulihkan HP!")
					return
	super.on_move_pressed(index)

func start_tutorial_flow():
	tutorial_active = true
	set_buttons_disabled(true)

	# ── STEP 0: Sambutan ──
	await show_dialog(
		"Selamat datang di Protocol: Elysium!",
		"Kamu akan belajar tentang keamanan siber — cybersecurity — melalui pertarungan Sentinel.",
		"Tenang, tidak perlu jadi ahli komputer dulu. Ikuti saja langkah-langkahnya!",
		"◈"
	)

	# ── STEP 1: Kenalkan HP Bar ──
	await highlight_element("player_hp_bar")
	await show_dialog(
		"Ini adalah HP kamu",
		"HP (Health Points) menunjukkan seberapa kuat sistemmu bertahan.\nKalau HP habis, sistem kamu dinyatakan COMPROMISED — artinya berhasil diserang.",
		"Jaga HP-mu agar tetap tinggi selama pertarungan!",
		"❤"
	)

	# ── STEP 2: Kenalkan Enemy ──
	await highlight_element("enemy_sprite")
	await show_dialog(
		"Ini lawanmu — BITI",
		"Biti adalah representasi dari POLYMORPHIC MALWARE — malware yang terus berubah bentuk agar sulit dideteksi antivirus.",
		"Di dunia nyata, malware seperti ini adalah ancaman nyata bagi komputer dan data kita!",
		"⚠"
	)

	# ── STEP 3: Kenalkan Sentinel Player ──
	await highlight_element("player_sprite")
	await show_dialog(
		"Dan ini adalah Sentinel-mu — ENCRYP-PUP",
		"Encryp-Pup mewakili teknologi ENKRIPSI — cara melindungi data agar tidak bisa dibaca orang yang tidak berhak.",
		"Kamu berperan sebagai DEFENDER — penjaga keamanan sistem!",
		"◈"
	)

	# ── STEP 4: Kenalkan tipe & advantage ──
	await show_type_advantage_tutorial()

	# ── STEP 5: Kenalkan Move Buttons ──
	await show_dialog(
		"Inilah senjata-senjatamu",
		"Setiap Sentinel punya 4 MOVE yang bisa kamu gunakan.\nMasing-masing move mewakili teknik keamanan siber yang nyata!",
		"Ada yang menyerang, ada yang memperkuat pertahanan, ada yang memulihkan HP.",
		"◉"
	)

	# ── STEP 6: Tutorial pakai Encrypt (buff) ──
	tutorial_step = 1
	set_buttons_disabled(false)
	await show_dialog(
		"Move 1 — ENCRYPT (Buff)",
		"ENCRYPT akan meningkatkan pertahananmu.\nDi dunia nyata, enkripsi melindungi data agar tidak bisa dibaca tanpa kunci.",
		"Sekarang coba klik  ENCRYPT  di daftar move!",
		"🔐"
	)

	# Tunggu player pakai Encrypt
	await wait_for_move_used(0)
	set_buttons_disabled(true)

	await show_dialog(
		"Bagus! Defense-mu meningkat",
		"Kamu baru saja 'mengenkripsi' sistemmu.\nLihat — Biti menyerang balik, tapi serangannya tidak terlalu efektif karena defense-mu lebih tinggi!",
		"Enkripsi adalah salah satu pertahanan paling dasar dan penting di dunia siber.",
		"✓"
	)

	# ── STEP 7: Tutorial pakai Firewall Bark (attack) ──
	tutorial_step = 2
	set_buttons_disabled(false)
	await show_dialog(
		"Move 2 — FIREWALL BARK (Serangan)",
		"FIREWALL BARK adalah seranganmu!\nFirewall di dunia nyata memfilter traffic berbahaya — memblokir ancaman sebelum masuk ke sistem.",
		"Sekarang coba klik  FIREWALL BARK  untuk menyerang Biti!",
		"🔥"
	)

	await wait_for_move_used(1)
	set_buttons_disabled(true)

	await show_dialog(
		"Serangan berhasil!",
		"Kamu baru saja menggunakan Firewall untuk menangkis ancaman.\nDi komputer dan router kita, firewall bekerja setiap detik — memfilter ribuan paket data.",
		"Pastikan firewall di perangkatmu selalu aktif, terutama saat pakai WiFi publik!",
		"✓"
	)

	# ── STEP 8: Tutorial pakai Backup Howl (heal) ──
	tutorial_step = 3
	set_buttons_disabled(false)
	await show_dialog(
		"Move 3 — BACKUP HOWL (Pulihkan HP)",
		"BACKUP HOWL memulihkan HP-mu.\nBegitu pula di dunia nyata — backup data memastikan kita bisa pulih dari serangan ransomware atau kerusakan sistem.",
		"Coba gunakan  BACKUP HOWL  sekarang!",
		"💾"
	)

	await wait_for_move_used(2)
	set_buttons_disabled(true)

	await show_dialog(
		"HP kamu pulih!",
		"Itulah pentingnya backup — selalu punya salinan data di tempat yang aman.\nIkuti aturan 3-2-1: 3 salinan, 2 media berbeda, 1 disimpan offsite.",
		"Setelah ini kamu bebas menggunakan semua move sesuai strategi-mu!",
		"✓"
	)

	# ── STEP 9: Free battle ──
	tutorial_step = STEP_FREE_BATTLE
	set_buttons_disabled(false)
	await show_dialog(
		"Sekarang kamu siap!",
		"Move ke-4 SSL HANDSHAKE juga tersedia — coba sendiri dan baca EDU-LOG yang muncul setelah setiap move.",
		"Kalahkan Biti dan selesaikan tutorialnya. Semangat, Defender!",
		"⚔"
	)

	tutorial_active = false

# ── Tunggu player menggunakan move tertentu ──
func wait_for_move_used(expected_index: int) -> void:
	var used = false
	while not used:
		await get_tree().create_timer(0.1).timeout
		# Cek apakah move sudah dipakai lewat moves_used_this_battle
		var move_name = battle_manager.player_monster.moves[expected_index]["name"]
		for m in battle_manager.moves_used_this_battle:
			if m["name"] == move_name:
				used = true
				break

# ── Tampilkan type advantage tutorial ──
func show_type_advantage_tutorial():
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.06, 0.07, 0.22)
	panel.size = Vector2(760, 380)
	panel.position = Vector2(196, 134)
	overlay.add_child(panel)

	# Border atas
	var border = ColorRect.new()
	border.color = Color(0.4, 0.9, 1)
	border.size = Vector2(760, 3)
	panel.add_child(border)

	var tag = _make_label("[ INTEL TUTORIAL ]  —  Sistem Tipe & Keunggulan", Vector2(20, 12), 12, Color(0.4, 0.9, 1))
	panel.add_child(tag)

	var title = _make_label("Setiap Sentinel punya TIPE — dan beberapa tipe lebih kuat dari yang lain!", Vector2(20, 36), 15, Color(1, 1, 0.9))
	title.size = Vector2(720, 40)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(title)

	# Contoh type chart sederhana
	var examples = [
		{"atk": "Crypto", "atk_col": Color(0.4, 0.8, 1), "vs": "Malware", "vs_col": Color(1, 0.4, 0.4), "desc": "Enkripsi efektif melawan Malware"},
		{"atk": "Firewall", "atk_col": Color(0.3, 1, 0.6), "vs": "Network", "vs_col": Color(1, 0.9, 0.3), "desc": "Firewall memblokir serangan jaringan"},
		{"atk": "Monitor", "atk_col": Color(0.7, 0.4, 1), "vs": "Social Eng.", "vs_col": Color(1, 0.7, 0.2), "desc": "Monitoring mendeteksi manipulasi"},
	]

	for i in examples.size():
		var ex = examples[i]
		var row_y = 90 + i * 72
		var row_bg = ColorRect.new()
		row_bg.color = Color(0.08, 0.1, 0.28)
		row_bg.size = Vector2(720, 60)
		row_bg.position = Vector2(20, row_y)
		panel.add_child(row_bg)

		# Tipe penyerang
		var atk_bg = ColorRect.new()
		atk_bg.color = Color(ex["atk_col"].r * 0.2, ex["atk_col"].g * 0.2, ex["atk_col"].b * 0.2)
		atk_bg.size = Vector2(140, 36)
		atk_bg.position = Vector2(16, 12)
		row_bg.add_child(atk_bg)
		var atk_lbl = _make_label(ex["atk"], Vector2(0, 10), 13, ex["atk_col"])
		atk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		atk_lbl.custom_minimum_size = Vector2(140, 20)
		row_bg.add_child(atk_lbl)

		# Arrow
		var arrow = _make_label("▶  KUAT VS", Vector2(162, 18), 11, Color(0.6, 0.7, 0.6))
		row_bg.add_child(arrow)

		# Tipe lawan
		var def_bg = ColorRect.new()
		def_bg.color = Color(ex["vs_col"].r * 0.2, ex["vs_col"].g * 0.2, ex["vs_col"].b * 0.2)
		def_bg.size = Vector2(140, 36)
		def_bg.position = Vector2(286, 12)
		row_bg.add_child(def_bg)
		var def_lbl = _make_label(ex["vs"], Vector2(286, 10), 13, ex["vs_col"])
		def_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		def_lbl.custom_minimum_size = Vector2(140, 20)
		row_bg.add_child(def_lbl)

		# Deskripsi
		var desc_lbl = _make_label("→  " + ex["desc"], Vector2(440, 18), 11, Color(0.7, 0.8, 0.75))
		row_bg.add_child(desc_lbl)

	# Note bawah
	var note = _make_label("Di pertarungan ini: Encryp-Pup (Crypto) VS Biti (Malware) — kamu punya keunggulan tipe!", Vector2(20, 310), 12, Color(0.4, 1, 0.55))
	note.size = Vector2(720, 30)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(note)

	var note2 = _make_label("Keunggulan tipe membuat serangan lebih kuat dan pertahananmu lebih solid.", Vector2(20, 336), 11, Color(0.55, 0.65, 0.6))
	note2.size = Vector2(720, 24)
	panel.add_child(note2)

	var btn = _make_button("Mengerti  ▶", Vector2(580, 330), Vector2(160, 36), Color(0.1, 0.4, 0.2))
	panel.add_child(btn)

	overlay.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(overlay, "modulate:a", 1.0, 0.2)
	await t.finished
	await btn.pressed
	var t2 = create_tween()
	t2.tween_property(overlay, "modulate:a", 0.0, 0.15)
	await t2.finished
	overlay.queue_free()

# ── Dialog utama tutorial ──
func show_dialog(title: String, body: String, tip: String, icon: String) -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.07, 0.08, 0.26)
	panel.size = Vector2(720, 210)
	panel.position = Vector2(216, 219)
	overlay.add_child(panel)

	# Border atas cyan
	var border_top = ColorRect.new()
	border_top.color = Color(0.4, 0.9, 1)
	border_top.size = Vector2(720, 3)
	panel.add_child(border_top)

	# Border kiri cyan
	var border_left = ColorRect.new()
	border_left.color = Color(0.4, 0.9, 1, 0.5)
	border_left.size = Vector2(3, 210)
	panel.add_child(border_left)

	# Tag header
	var tag = _make_label("[ ELYSIUM INTEL ]", Vector2(12, 10), 11, Color(0.4, 0.9, 1))
	panel.add_child(tag)

	# Icon
	var icon_lbl = _make_label(icon, Vector2(660, 10), 22, Color(0.4, 0.9, 1, 0.7))
	panel.add_child(icon_lbl)

	# Judul
	var title_lbl = _make_label(title, Vector2(12, 28), 17, Color(1, 1, 0.9))
	panel.add_child(title_lbl)

	# Separator
	var sep = ColorRect.new()
	sep.color = Color(1, 1, 1, 0.08)
	sep.size = Vector2(696, 1)
	sep.position = Vector2(12, 52)
	panel.add_child(sep)

	# Body text
	var body_lbl = _make_label(body, Vector2(12, 60), 13, Color(0.85, 0.92, 1))
	body_lbl.size = Vector2(696, 80)
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(body_lbl)

	# Tip panel
	var tip_bg = ColorRect.new()
	tip_bg.color = Color(0.1, 0.3, 0.15, 0.8)
	tip_bg.size = Vector2(696, 28)
	tip_bg.position = Vector2(12, 148)
	panel.add_child(tip_bg)

	var tip_lbl = _make_label("💡  " + tip, Vector2(18, 152), 11, Color(0.5, 1, 0.6))
	tip_lbl.size = Vector2(560, 24)
	tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(tip_lbl)

	# Tombol
	var btn = _make_button("Mengerti  ▶", Vector2(540, 168), Vector2(168, 36), Color(0.1, 0.4, 0.2))
	panel.add_child(btn)

	overlay.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(overlay, "modulate:a", 1.0, 0.2)
	await t.finished
	await btn.pressed
	var t2 = create_tween()
	t2.tween_property(overlay, "modulate:a", 0.0, 0.15)
	await t2.finished
	overlay.queue_free()

# ── Hint kecil kalau player klik move yang salah ──
func show_tutorial_hint(msg: String) -> void:
	var hint = ColorRect.new()
	hint.color = Color(0.3, 0.1, 0.05, 0.92)
	hint.size = Vector2(500, 44)
	hint.position = Vector2(326, 580)
	add_child(hint)

	var border = ColorRect.new()
	border.color = Color(1, 0.5, 0.2)
	border.size = Vector2(500, 2)
	hint.add_child(border)

	var lbl = _make_label("⚠  " + msg, Vector2(12, 12), 13, Color(1, 0.7, 0.3))
	hint.add_child(lbl)

	hint.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(hint, "modulate:a", 1.0, 0.15)
	await t.finished
	await get_tree().create_timer(1.8).timeout
	var t2 = create_tween()
	t2.tween_property(hint, "modulate:a", 0.0, 0.2)
	await t2.finished
	hint.queue_free()

# ── Highlight elemen UI (glow ring di sekitar elemen) ──
func highlight_element(node_name: String) -> void:
	var target = find_child(node_name, true, false)
	if not target:
		return

	var glow = ColorRect.new()
	glow.color = Color(0.4, 0.9, 1, 0.25)
	glow.size = target.size + Vector2(12, 12) if target is Control else Vector2(90, 90)
	glow.position = target.position - Vector2(6, 6) if target is Control else target.position - Vector2(45, 45)
	add_child(glow)

	var t = create_tween()
	t.set_loops(3)
	t.tween_property(glow, "modulate:a", 0.3, 0.4)
	t.tween_property(glow, "modulate:a", 1.0, 0.4)
	await t.finished
	glow.queue_free()

# ── Battle selesai — override dari parent ──
func on_battle_ended(player_won: bool):
	battle_active = false
	set_buttons_disabled(true)

	var loser_name = "player_sprite" if not player_won else "enemy_sprite"
	var loser = find_child(loser_name, true, false)
	if loser:
		spawn_hit_particles(loser.position, Color(1, 0.5, 0.2), 20)
		var death_tween = create_tween()
		death_tween.set_parallel(true)
		death_tween.tween_property(loser, "modulate:a", 0.0, 0.8)
		death_tween.tween_property(loser, "position", loser.position + Vector2(0, 30), 0.8)
		trigger_screen_shake(10.0)

	await get_tree().create_timer(0.8).timeout

	if player_won:
		await show_dialog(
			"Sistem berhasil diamankan!",
			"Kamu berhasil mengalahkan Biti dan melindungi sistem dari serangan malware.\nItu adalah inti dari cybersecurity — mendeteksi, memblokir, dan memulihkan sistem dari ancaman.",
			"Kamu sekarang siap untuk pertarungan sesungguhnya. Pilih Sentinel-mu dan bertarung!",
			"🛡"
		)
	else:
		await show_dialog(
			"Sistem dikompromis!",
			"Kali ini Biti berhasil menembus pertahananmu. Di dunia nyata, serangan malware bisa terjadi pada siapa saja.\nPentingnya: kita harus selalu siap dengan backup, enkripsi, dan firewall yang aktif.",
			"Coba lagi! Gunakan Encrypt lebih awal untuk perkuat defense-mu.",
			"⚠"
		)

	await get_tree().create_timer(0.5).timeout
	var selection = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(selection)
	get_tree().current_scene = selection
	queue_free()

# ── Helper: buat Label ──
func _make_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

# ── Helper: buat Button ──
func _make_button(text: String, pos: Vector2, sz: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = sz
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.2)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
