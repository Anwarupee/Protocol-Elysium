extends "res://battle/Battle.gd"

# ══════════════════════════════════════════════
#  TutorialBattle.gd — Guided Tutorial
#  Fully dynamic — works dengan sentinel apapun
# ══════════════════════════════════════════════

var tutorial_active: bool = false
var tutorial_step: int = 0
var dialog_open: bool = false  # Flag pause ringan — tidak ganggu timer
const STEP_FREE_BATTLE = 99

var p_data: Dictionary = {}
var p_moves: Array = []

var move_buff_idx: int = -1
var move_attack_idx: int = -1
var move_heal_idx: int = -1
var move_extra_idx: int = -1

const BUFF_EFFECTS   = ["defense_buff", "accuracy_buff", "speed_buff", "evasion_buff", "super_defense", "zero_day_shield", "decoy_payload", "pretexting", "overclock"]
const HEAL_EFFECTS   = ["heal", "patch_deploy", "failover", "restore_point"]
const ATTACK_EFFECTS = ["attack", "block_move", "double_hit", "defense_debuff", "speed_debuff", "guaranteed_hit", "ssl_handshake", "ping_flood", "shell_slam", "fork_bomb", "cipher_strike", "lure_strike", "syn_flood", "polymorphic"]

func _ready():
	original_position = position
	edu_popup = get_node_or_null("EduPopup")

	var player_choice = "encryp_pup"
	if has_meta("player_monster"):
		player_choice = get_meta("player_monster")

	var enemy_choice = "biti"
	battle_manager.load_monsters()
	p_data = battle_manager.get_monster_data(player_choice)
	var enemy_data = battle_manager.get_monster_data(enemy_choice)

	if p_data.is_empty() or enemy_data.is_empty():
		push_error("Monster data not found!")
		return

	p_moves = p_data["moves"]
	_categorize_moves()

	build_ui(p_data, enemy_data)
	connect_signals()
	_add_escape_button()
	battle_manager.start_battle(player_choice, enemy_choice)
	battle_manager.tutorial_locked = true
	await play_intro_animation()
	await start_tutorial_flow()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_confirm_exit()

func _add_escape_button():
	var btn = Button.new()
	btn.text = "✕ KELUAR"
	btn.position = Vector2(16, 16)
	btn.size = Vector2(100, 28)
	btn.z_index = 10
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.06, 0.06, 0.85)
	style.border_color = Color(0.8, 0.3, 0.3, 0.6)
	style.border_width_left = 1; style.border_width_right = 1
	style.border_width_top = 1; style.border_width_bottom = 1
	style.corner_radius_top_left = 4; style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4; style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.4, 0.1, 0.1, 0.95)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	btn.pressed.connect(_confirm_exit)
	add_child(btn)

func _confirm_exit():
	# Jangan tampilkan konfirmasi kalau dialog lain sedang terbuka
	if dialog_open:
		return
	dialog_open = true

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.size = Vector2(1152, 648)
	overlay.z_index = 20
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.1, 0.05, 0.05)
	panel.size = Vector2(420, 160)
	panel.position = Vector2(366, 244)
	overlay.add_child(panel)

	var border = ColorRect.new()
	border.color = Color(0.8, 0.3, 0.3)
	border.size = Vector2(420, 3)
	panel.add_child(border)

	var lbl_title = _add_label(panel, "Keluar dari Battle?", Vector2(20, 16), 16, Color(1, 0.6, 0.6))
	var lbl_body = _add_label(panel, "Progress tutorial akan hilang.\nKamu akan kembali ke Main Menu.", Vector2(20, 48), 12, Color(0.8, 0.75, 0.75))
	lbl_body.size = Vector2(380, 50)
	lbl_body.autowrap_mode = TextServer.AUTOWRAP_WORD

	var btn_cancel = _make_button("Lanjut Battle", Vector2(20, 112), Vector2(180, 36), Color(0.08, 0.25, 0.12))
	panel.add_child(btn_cancel)

	var btn_exit = _make_button("Keluar", Vector2(218, 112), Vector2(180, 36), Color(0.35, 0.08, 0.08))
	panel.add_child(btn_exit)

	overlay.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(overlay, "modulate:a", 1.0, 0.15)
	await tw.finished

	var choice = await _wait_for_either(btn_cancel, btn_exit)

	var tw2 = create_tween()
	tw2.tween_property(overlay, "modulate:a", 0.0, 0.15)
	await tw2.finished
	overlay.queue_free()
	dialog_open = false

	if choice == "exit":
		var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
		get_tree().root.add_child(scene)
		get_tree().current_scene = scene
		queue_free()

func _wait_for_either(btn_a: Button, btn_b: Button) -> String:
	var result = ""
	var done = false
	btn_a.pressed.connect(func(): result = "cancel"; done = true)
	btn_b.pressed.connect(func(): result = "exit"; done = true)
	while not done:
		await get_tree().process_frame
	return result

func _categorize_moves():
	# Pass 1: assign buff, heal, attack berdasarkan effect
	for i in p_moves.size():
		var effect = p_moves[i].get("effect", "")
		if move_buff_idx == -1 and effect in BUFF_EFFECTS:
			move_buff_idx = i
		elif move_heal_idx == -1 and effect in HEAL_EFFECTS:
			move_heal_idx = i
		elif move_attack_idx == -1 and effect in ATTACK_EFFECTS:
			move_attack_idx = i

	# Pass 2: isi move_extra dari yang belum dipakai
	for i in p_moves.size():
		if i != move_buff_idx and i != move_heal_idx and i != move_attack_idx:
			if move_extra_idx == -1:
				move_extra_idx = i

	# Fallback jika sentinel tidak punya heal:
	# Gunakan move_extra sebagai "heal step" (tetap diajarkan, hanya beda label)
	# Pastikan tidak ada collision — tiap index harus unik
	if move_attack_idx == -1:
		move_attack_idx = _first_unused([move_buff_idx, move_heal_idx, move_extra_idx])
	if move_buff_idx == -1:
		move_buff_idx = _first_unused([move_attack_idx, move_heal_idx, move_extra_idx])
	if move_heal_idx == -1:
		# Pakai move_extra sebagai heal step kalau ada
		if move_extra_idx != -1 and move_extra_idx != move_buff_idx and move_extra_idx != move_attack_idx:
			move_heal_idx = move_extra_idx
			move_extra_idx = _first_unused([move_buff_idx, move_attack_idx, move_heal_idx])
		else:
			move_heal_idx = _first_unused([move_buff_idx, move_attack_idx, move_extra_idx])
	if move_extra_idx == -1:
		move_extra_idx = _first_unused([move_buff_idx, move_attack_idx, move_heal_idx])

	# Final safety — pastikan semua berbeda
	var used = [move_buff_idx, move_attack_idx, move_heal_idx]
	if move_extra_idx in used:
		move_extra_idx = _first_unused(used)

	print("Tutorial categorize — buff:%d attack:%d heal:%d extra:%d" % [
		move_buff_idx, move_attack_idx, move_heal_idx, move_extra_idx])

func _first_unused(used: Array) -> int:
	for i in p_moves.size():
		if i not in used:
			return i
	return 0  # fallback absolut

func on_move_pressed(index: int):
	if tutorial_active and tutorial_step != STEP_FREE_BATTLE:
		var required = -1
		match tutorial_step:
			1: required = move_buff_idx
			2: required = move_attack_idx
			3: required = move_heal_idx
		if required != -1 and index != required:
			var needed = p_moves[required]["name"]
			await show_tutorial_hint("Coba gunakan  " + needed.to_upper() + "  dulu!")
			return
	super.on_move_pressed(index)

func start_tutorial_flow():
	tutorial_active = true
	set_buttons_disabled(true)

	await show_dialog("Selamat datang di Protocol: Elysium!",
		"Kamu akan belajar keamanan siber lewat pertarungan Sentinel.\nTidak perlu jadi ahli komputer — ikuti saja langkah-langkahnya!",
		"Sentinel mewakili konsep keamanan siber di dunia nyata.", "◈")

	await highlight_element("player_sprite")
	await show_dialog("Ini adalah Sentinel-mu — " + p_data["name"].to_upper(),
		"Sentinel-mu bertipe  " + p_data["type"] + ".\n" + _get_type_description(p_data["type"]),
		"Kamu berperan sebagai DEFENDER — penjaga keamanan sistem!", "◈")

	await highlight_element("enemy_sprite")
	await show_dialog("Ini lawanmu — BITI",
		"Biti mewakili POLYMORPHIC MALWARE — malware yang terus mengubah kode dirinya agar sulit terdeteksi antivirus.\nDi dunia nyata, ancaman seperti ini menyerang jutaan perangkat setiap hari.",
		"Kalahkan Biti untuk menyelesaikan tutorial!", "⚠")

	await highlight_element("player_hp_bar")
	await show_dialog("Ini adalah HP — Health Points",
		"HP menunjukkan seberapa kuat sistem bertahan.\nKalau HP-mu habis, sistem dinyatakan COMPROMISED — berhasil diserang.",
		"Gunakan move pemulihan saat HP menipis!", "❤")

	await show_type_advantage_tutorial(p_data["type"])

	await show_dialog("Inilah senjata-senjatamu",
		"Setiap Sentinel punya 4 MOVE yang mewakili teknik keamanan siber nyata.\nAda serangan, buff pertahanan, dan pemulihan HP.",
		"Baca EDU-LOG setelah setiap move untuk belajar lebih dalam!", "◉")

	# Step buff
	tutorial_step = 1
	set_buttons_disabled(false)
	var bm = p_moves[move_buff_idx]
	var buff_dialog = _get_move_gameplay_dialog(bm)
	await show_dialog(
		buff_dialog["title"],
		buff_dialog["body"],
		"Sekarang klik  " + bm["name"].to_upper() + "  di daftar move!", "🛡")
	highlight_move_button(move_buff_idx)
	await wait_for_move_used(move_buff_idx)
	set_buttons_disabled(true)
	await show_dialog("Bagus! " + bm["name"] + " berhasil!",
		buff_dialog["after"],
		"Lanjut ke move serangan!", "✓")

	# Step attack
	tutorial_step = 2
	set_buttons_disabled(false)
	var am = p_moves[move_attack_idx]
	var atk_dialog = _get_move_gameplay_dialog(am)
	await show_dialog(
		atk_dialog["title"],
		atk_dialog["body"],
		"Klik  " + am["name"].to_upper() + "  untuk menyerang Biti!", "⚔")
	highlight_move_button(move_attack_idx)
	await wait_for_move_used(move_attack_idx)
	set_buttons_disabled(true)
	await show_dialog("Serangan berhasil!",
		atk_dialog["after"],
		"Lanjut ke move berikutnya!", "✓")

	# Step heal/special
	tutorial_step = 3
	set_buttons_disabled(false)
	var hm = p_moves[move_heal_idx]
	var heal_dialog = _get_move_gameplay_dialog(hm)
	await show_dialog(
		heal_dialog["title"],
		heal_dialog["body"],
		"Gunakan  " + hm["name"].to_upper() + "  sekarang!", "💾")
	highlight_move_button(move_heal_idx)
	await wait_for_move_used(move_heal_idx)
	set_buttons_disabled(true)
	await show_dialog("Move " + hm["name"] + " berhasil!",
		heal_dialog["after"],
		"Sekarang kamu bebas gunakan semua move!", "✓")

	# Free battle — unlock battle_ended
	tutorial_step = STEP_FREE_BATTLE
	battle_manager.tutorial_locked = false
	set_buttons_disabled(false)
	var em_name = p_moves[move_extra_idx]["name"] if move_extra_idx >= 0 else "move ke-4"
	await show_dialog("Sekarang kamu siap!",
		"Move terakhir — " + em_name.to_upper() + " — bisa kamu coba sendiri.\nTerus baca EDU-LOG yang muncul untuk belajar lebih banyak konsep cybersecurity!",
		"Kalahkan Biti dan selesaikan tutorial. Semangat, Defender!", "⚔")

	tutorial_active = false

func _get_type_description(type: String) -> String:
	match type:
		"Crypto":             return "Crypto mewakili ENKRIPSI — melindungi data agar tidak bisa dibaca pihak tidak berhak."
		"Firewall":           return "Firewall mewakili sistem yang memfilter traffic berbahaya sebelum masuk ke sistem."
		"Network":            return "Network mewakili infrastruktur jaringan yang menghubungkan semua sistem."
		"Malware":            return "Malware mewakili perangkat lunak berbahaya yang menyerang dan merusak sistem."
		"Monitor":            return "Monitor mewakili sistem pemantauan yang mendeteksi ancaman sebelum berkembang."
		"Social Engineering": return "Social Engineering mewakili serangan yang memanipulasi manusia — bukan sistem."
	return "Sentinel ini mewakili konsep penting dalam keamanan siber."

func _get_move_gameplay_dialog(move: Dictionary) -> Dictionary:
	var name = move["name"]
	var effect = move.get("effect", "")
	var power = move.get("power", 0)

	match effect:
		# ── BUFF ──
		"defense_buff", "super_defense":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Tingkatkan Defense]",
				"body": name + " akan meningkatkan Defense-mu.\nSemakin tinggi Defense, semakin kecil damage yang kamu terima dari serangan Biti.",
				"after": "Defense-mu sekarang lebih tinggi!\nCoba lihat — serangan Biti berikutnya akan memberikan damage lebih kecil dari sebelumnya."
			}
		"accuracy_buff":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Tingkatkan Akurasi]",
				"body": name + " akan meningkatkan Accuracy-mu.\nSerangan dengan accuracy tinggi lebih jarang miss — setiap hit pasti mengenai.",
				"after": "Accuracy-mu sekarang lebih tinggi!\nSerangan berikutnya akan lebih konsisten mengenai Biti."
			}
		"speed_buff":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Tingkatkan Speed]",
				"body": name + " akan meningkatkan Speed-mu.\nDengan speed lebih tinggi, kamu berpeluang menyerang duluan di ronde berikutnya.",
				"after": "Speed-mu sekarang lebih tinggi!\nDalam battle, menyerang duluan bisa jadi perbedaan antara menang dan kalah."
			}
		"evasion_buff":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Tingkatkan Evasion]",
				"body": name + " akan meningkatkan Evasion-mu.\nDengan evasion tinggi, ada kemungkinan serangan Biti meleset dan tidak mengenai.",
				"after": "Evasion-mu sekarang lebih tinggi!\nBiti mungkin akan kesulitan mengenaimu di beberapa ronde ke depan."
			}
		"zero_day_shield", "decoy_payload":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Perisai Khusus]",
				"body": name + " akan memberikan perisai khusus yang memblokir serangan berikutnya.\nSerangan pertama Biti setelah ini akan dibatalkan sepenuhnya.",
				"after": "Perisai aktif!\nSerangan berikutnya dari Biti akan terblokir — gunakan waktu ini untuk menyerang."
			}
		"overclock", "pretexting":
			return {
				"title": "Move: " + name.to_upper() + "  [BUFF — Efek Khusus]",
				"body": name + " memberikan buff khusus pada Sentinel-mu.\nEfek lengkapnya akan muncul di EDU-LOG — baca untuk tahu lebih detail.",
				"after": "Buff aktif!\nPerhatikan bagaimana statsmu berubah di ronde-ronde berikutnya."
			}

		# ── ATTACK ──
		"attack", "ssl_handshake", "shell_slam", "cipher_strike":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — " + str(power) + " Power]",
				"body": name + " adalah serangan langsung dengan power " + str(power) + ".\nSemakin tinggi power, semakin besar damage yang diterima Biti.",
				"after": "Damage masuk ke Biti!\nLihat HP bar Biti — setiap serangan yang mengenai mengurangi HP-nya."
			}
		"block_move":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN + BLOKIR]",
				"body": name + " menyerang Biti sekaligus memblokir move Biti di ronde berikutnya.\nDua keuntungan sekaligus — damage masuk dan serangan balik dicegah.",
				"after": "Serangan masuk dan blokir aktif!\nBiti tidak bisa menggunakan satu move-nya di ronde berikutnya."
			}
		"double_hit":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN GANDA]",
				"body": name + " menyerang dua kali dalam satu ronde.\nTotal damage bisa mencapai " + str(power * 2) + " jika kedua hit mengenai.",
				"after": "Dua serangan sekaligus!\nSerangan ganda efektif untuk mengurangi HP lawan dengan cepat."
			}
		"defense_debuff":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Turunkan Defense Lawan]",
				"body": name + " menyerang sekaligus menurunkan Defense Biti.\nDefense Biti yang lebih rendah berarti serangan-seranganmu berikutnya lebih sakit.",
				"after": "Defense Biti turun!\nSerangan berikutnya akan memberikan damage lebih besar dari sebelumnya."
			}
		"speed_debuff":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Turunkan Speed Lawan]",
				"body": name + " menyerang sekaligus memperlambat Biti.\nBiti yang lebih lambat mungkin akan menyerang setelah kamu di beberapa ronde.",
				"after": "Biti melambat!\nKalau speed-mu lebih tinggi dari Biti, kamu akan selalu menyerang duluan."
			}
		"guaranteed_hit":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Pasti Kena]",
				"body": name + " adalah serangan yang tidak bisa meleset.\nBahkan jika Biti punya passive evasion, serangan ini tetap mengenai.",
				"after": "Hit confirmed!\nSerangan yang guaranteed hit sangat efektif melawan lawan dengan evasion tinggi."
			}
		"ping_flood", "fork_bomb", "lure_strike", "syn_flood", "polymorphic":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN KHUSUS]",
				"body": name + " adalah serangan dengan efek tambahan unik.\nSelain damage, ada efek khusus yang mempengaruhi jalannya battle.",
				"after": "Serangan khusus berhasil!\nBaca EDU-LOG di bawah untuk tahu efek lengkap dari move ini."
			}

		# ── HEAL ──
		"heal", "restore_point":
			return {
				"title": "Move: " + name.to_upper() + "  [PULIHKAN HP]",
				"body": name + " akan memulihkan sebagian HP-mu.\nGunakan saat HP mulai menipis — jangan tunggu sampai hampir 0!",
				"after": "HP kamu pulih!\nPenting: move ini punya cooldown, jadi tidak bisa dipakai setiap ronde."
			}
		"patch_deploy":
			return {
				"title": "Move: " + name.to_upper() + "  [PULIHKAN HP]",
				"body": name + " akan memulihkan HP-mu seperti men-deploy patch keamanan.\nSemakin cepat kamu patch, semakin banyak HP yang bisa diselamatkan.",
				"after": "HP kamu pulih!\nDi dunia nyata, patch cepat adalah salah satu cara terbaik mencegah kerusakan lebih lanjut."
			}
		"failover":
			return {
				"title": "Move: " + name.to_upper() + "  [PULIHKAN HP — Failover]",
				"body": name + " mengaktifkan sistem cadangan untuk memulihkan HP.\nSeperti failover server — sistem backup langsung mengambil alih saat sistem utama bermasalah.",
				"after": "Sistem cadangan aktif!\nHP kamu pulih berkat failover. Ingat cooldown-nya — rencanakan penggunaannya."
			}

		# ── DEBUFF / SPECIAL ──
		"heal_lock":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Kunci Heal Lawan]",
				"body": name + " menyerang Biti sekaligus mengunci kemampuan heal-nya.\nBiti tidak bisa memulihkan HP selama beberapa ronde ke depan.",
				"after": "Heal Biti terkunci!\nIni saat yang tepat untuk menyerang habis-habisan — Biti tidak bisa pulih."
			}
		"confuse":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Buat Lawan Bingung]",
				"body": name + " menyerang sekaligus membuat Biti kebingungan.\nBiti yang confused punya chance menyakiti dirinya sendiri.",
				"after": "Biti kebingungan!\nPerhatikan battle log — Biti mungkin akan menyerang dirinya sendiri di ronde berikutnya."
			}
		"reset_buffs":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN — Reset Buff Lawan]",
				"body": name + " menyerang sekaligus mereset semua buff yang dimiliki Biti.\nSemua peningkatan stat Biti akan kembali ke nilai awal.",
				"after": "Buff Biti direset!\nSemua keuntungan yang dikumpulkan Biti hilang seketika."
			}
		"trojan":
			return {
				"title": "Move: " + name.to_upper() + "  [SERANGAN TERTUNDA]",
				"body": name + " menanam bom waktu di dalam sistem Biti.\nBeberapa ronde lagi, bom ini meledak dan memberikan damage besar.",
				"after": "Trojan tertanam!\nTunggu beberapa ronde — ledakan damage besar akan datang secara otomatis."
			}
		"copy_move":
			return {
				"title": "Move: " + name.to_upper() + "  [TIRU MOVE LAWAN]",
				"body": name + " meniru move terakhir yang digunakan Biti.\nDamage dan efeknya sama persis dengan move yang ditiru.",
				"after": "Move Biti berhasil ditiru!\nStrategi ini efektif saat lawan punya move powerful yang ingin kamu balik ke mereka."
			}

	# Default fallback
	return {
		"title": "Move: " + name.to_upper(),
		"body": name + " akan memberikan efek pada pertarungan ini.\nPerhatikan battle log untuk melihat apa yang terjadi.",
		"after": "Move berhasil!\nBaca EDU-LOG di bawah untuk penjelasan lebih detail tentang move ini."
	}

func wait_for_move_used(expected_index: int) -> void:
	var move_name = p_moves[expected_index]["name"]
	var used = false
	while not used:
		await get_tree().create_timer(0.15).timeout
		for m in battle_manager.moves_used_this_battle:
			if m["name"] == move_name:
				used = true
				break

func show_type_advantage_tutorial(player_type: String) -> void:
	var advantage_table = {
		"Malware":            {"strong": "Firewall",           "weak": "Crypto"},
		"Firewall":           {"strong": "Network",            "weak": "Malware"},
		"Network":            {"strong": "Crypto",             "weak": "Firewall"},
		"Crypto":             {"strong": "Malware",            "weak": "Network"},
		"Social Engineering": {"strong": "Crypto",             "weak": "Monitor"},
		"Monitor":            {"strong": "Social Engineering", "weak": "Malware"}
	}
	var type_colors = {
		"Malware":            Color(1.0, 0.3, 0.3),
		"Firewall":           Color(0.2, 0.5, 1.0),
		"Network":            Color(1.0, 0.9, 0.2),
		"Crypto":             Color(0.3, 0.9, 1.0),
		"Social Engineering": Color(1.0, 0.6, 0.1),
		"Monitor":            Color(0.2, 0.9, 0.4)
	}

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.88)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.06, 0.07, 0.22)
	panel.size = Vector2(780, 430)
	panel.position = Vector2(186, 109)
	overlay.add_child(panel)

	var border_top = ColorRect.new()
	border_top.color = Color(0.4, 0.9, 1)
	border_top.size = Vector2(780, 3)
	panel.add_child(border_top)

	_add_label(panel, "[ INTEL TUTORIAL ]  —  Sistem Tipe & Keunggulan", Vector2(20, 12), 12, Color(0.4, 0.9, 1))
	_add_label(panel, "Setiap Sentinel punya TIPE — dan ada keunggulan satu tipe terhadap tipe lainnya!", Vector2(20, 34), 14, Color(1, 1, 0.9))

	var types_order = ["Crypto", "Firewall", "Network", "Malware", "Monitor", "Social Engineering"]
	for i in types_order.size():
		var t = types_order[i]
		var info = advantage_table[t]
		var col = type_colors[t]
		var row_y = 66 + i * 52
		var is_player = (t == player_type)

		var row_bg = ColorRect.new()
		row_bg.color = Color(col.r*0.15, col.g*0.15, col.b*0.15) if is_player else Color(0.07, 0.09, 0.22)
		row_bg.size = Vector2(740, 44)
		row_bg.position = Vector2(20, row_y)
		panel.add_child(row_bg)

		if is_player:
			var marker = ColorRect.new()
			marker.color = col
			marker.size = Vector2(4, 44)
			marker.position = Vector2(20, row_y)
			panel.add_child(marker)
			_add_label(panel, "KAMU", Vector2(28, row_y + 14), 9, col)

		var badge_bg = ColorRect.new()
		badge_bg.color = Color(col.r*0.25, col.g*0.25, col.b*0.25)
		badge_bg.size = Vector2(150, 28)
		badge_bg.position = Vector2(60, row_y + 8)
		panel.add_child(badge_bg)
		_add_label(panel, t, Vector2(65, row_y + 12), 11, col)

		_add_label(panel, "⚡ KUAT VS", Vector2(218, row_y + 14), 10, Color(0.7, 0.9, 0.5))
		var sc = type_colors[info["strong"]]
		var sb = ColorRect.new()
		sb.color = Color(sc.r*0.2, sc.g*0.2, sc.b*0.2)
		sb.size = Vector2(155, 28); sb.position = Vector2(310, row_y + 8)
		panel.add_child(sb)
		_add_label(panel, info["strong"], Vector2(315, row_y + 12), 11, sc)

		_add_label(panel, "⚠ LEMAH VS", Vector2(475, row_y + 14), 10, Color(0.9, 0.6, 0.4))
		var wc = type_colors[info["weak"]]
		var wb = ColorRect.new()
		wb.color = Color(wc.r*0.2, wc.g*0.2, wc.b*0.2)
		wb.size = Vector2(155, 28); wb.position = Vector2(578, row_y + 8)
		panel.add_child(wb)
		_add_label(panel, info["weak"], Vector2(583, row_y + 12), 11, wc)

	# Note player vs Biti
	var biti_type = "Firewall"
	var note_text = ""
	var note_col = Color(0.7, 0.8, 0.9)
	if advantage_table.has(player_type):
		if advantage_table[player_type]["strong"] == biti_type:
			note_text = "✓  " + p_data["name"] + " (" + player_type + ") UNGGUL vs Biti (Firewall) — damage x1.5!"
			note_col = Color(0.4, 1, 0.55)
		elif advantage_table[player_type]["weak"] == biti_type:
			note_text = "⚠  " + p_data["name"] + " (" + player_type + ") LEMAH vs Biti (Firewall) — damage x0.5, gunakan strategi!"
			note_col = Color(1, 0.6, 0.3)
		else:
			note_text = "◈  " + p_data["name"] + " (" + player_type + ") NETRAL vs Biti (Firewall) — damage normal x1.0"

	var nb = ColorRect.new()
	nb.color = Color(note_col.r*0.08, note_col.g*0.08, note_col.b*0.08)
	nb.size = Vector2(740, 30); nb.position = Vector2(20, 390)
	panel.add_child(nb)
	_add_label(panel, note_text, Vector2(28, 397), 11, note_col)

	var btn = _make_button("Mengerti  ▶", Vector2(590, 385), Vector2(160, 36), Color(0.1, 0.4, 0.2))
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

func show_dialog(title: String, body: String, tip: String, icon: String) -> void:
	dialog_open = true

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.07, 0.08, 0.26)
	panel.size = Vector2(720, 270)
	panel.position = Vector2(216, 189)
	overlay.add_child(panel)

	var bt = ColorRect.new(); bt.color = Color(0.4, 0.9, 1); bt.size = Vector2(720, 3); panel.add_child(bt)
	var bl = ColorRect.new(); bl.color = Color(0.4, 0.9, 1, 0.5); bl.size = Vector2(3, 270); panel.add_child(bl)

	_add_label(panel, "[ ELYSIUM INTEL ]", Vector2(12, 10), 11, Color(0.4, 0.9, 1))
	_add_label(panel, icon, Vector2(682, 8), 22, Color(0.4, 0.9, 1, 0.7))
	_add_label(panel, title, Vector2(12, 28), 15, Color(1, 1, 0.9))

	var sep = ColorRect.new(); sep.color = Color(1,1,1,0.08); sep.size = Vector2(696, 1); sep.position = Vector2(12, 52); panel.add_child(sep)

	# Body — max 2 baris, ~68 karakter per baris
	# autowrap dimatikan — _fit_text yang handle, clip container mencegah overflow
	var body_display = _fit_text(body, 68, 2)
	var body_clip = Control.new()
	body_clip.position = Vector2(12, 60)
	body_clip.size = Vector2(696, 80)
	body_clip.clip_contents = true
	panel.add_child(body_clip)
	var bl2 = _add_label(body_clip, body_display, Vector2(0, 0), 12, Color(0.85, 0.92, 1))
	bl2.custom_minimum_size = Vector2(696, 0)
	bl2.autowrap_mode = TextServer.AUTOWRAP_WORD

	# Tip — 1 baris, ~58 karakter (font 11, ada prefix 💡  = ~4 char)
	var tip_display = _fit_text(tip, 58, 1)
	var tb = ColorRect.new(); tb.color = Color(0.1, 0.3, 0.15, 0.8)
	tb.size = Vector2(696, 28); tb.position = Vector2(12, 148); panel.add_child(tb)
	var tl = _add_label(panel, "💡  " + tip_display, Vector2(18, 153), 11, Color(0.5, 1, 0.6))
	tl.custom_minimum_size = Vector2(690, 0)

	# Tombol — y=222, jelas di bawah tip
	var btn = _make_button("Mengerti  ▶", Vector2(540, 222), Vector2(168, 36), Color(0.1, 0.4, 0.2))
	panel.add_child(btn)

	overlay.modulate.a = 0.0
	var tw = create_tween(); tw.tween_property(overlay, "modulate:a", 1.0, 0.2); await tw.finished
	await btn.pressed
	var tw2 = create_tween(); tw2.tween_property(overlay, "modulate:a", 0.0, 0.15); await tw2.finished
	overlay.queue_free()

	dialog_open = false

func show_tutorial_hint(msg: String) -> void:
	var hint = ColorRect.new()
	hint.color = Color(0.3, 0.1, 0.05, 0.92)
	hint.size = Vector2(500, 44); hint.position = Vector2(326, 580)
	add_child(hint)
	var border = ColorRect.new(); border.color = Color(1, 0.5, 0.2); border.size = Vector2(500, 2); hint.add_child(border)
	_add_label(hint, "⚠  " + msg, Vector2(12, 12), 13, Color(1, 0.7, 0.3))
	hint.modulate.a = 0.0
	var t = create_tween(); t.tween_property(hint, "modulate:a", 1.0, 0.15); await t.finished
	await get_tree().create_timer(1.8).timeout
	var t2 = create_tween(); t2.tween_property(hint, "modulate:a", 0.0, 0.2); await t2.finished
	hint.queue_free()

func highlight_element(node_name: String) -> void:
	var target: Node = null
	if node_name == "player_hp_bar":
		target = player_hp_bar
	elif node_name == "enemy_hp_bar":
		target = enemy_hp_bar
	else:
		target = find_child(node_name, true, false)
	if not target: return

	# Tunggu satu frame agar global_position valid
	await get_tree().process_frame

	var glow_outer = ColorRect.new()
	glow_outer.color = Color(0.4, 0.9, 1, 0.6)
	var glow_inner = ColorRect.new()
	glow_inner.color = Color(0.4, 0.9, 1, 0.25)

	if target is Control:
		var pos = target.global_position
		var sz = target.size
		glow_outer.size = sz + Vector2(10, 10)
		glow_outer.position = pos - Vector2(5, 5)
		glow_inner.size = sz
		glow_inner.position = pos
	else:
		glow_outer.size = Vector2(110, 110)
		glow_outer.position = target.position - Vector2(55, 55)
		glow_inner.size = Vector2(80, 80)
		glow_inner.position = target.position - Vector2(40, 40)

	add_child(glow_outer)
	add_child(glow_inner)

	var t = create_tween()
	t.set_loops(4)
	t.tween_property(glow_outer, "modulate:a", 0.15, 0.3)
	t.tween_property(glow_outer, "modulate:a", 1.0, 0.3)
	await t.finished
	glow_outer.queue_free()
	glow_inner.queue_free()

func on_battle_ended(player_won: bool):
	battle_active = false
	set_buttons_disabled(true)
	var loser_name = "player_sprite" if not player_won else "enemy_sprite"
	var loser = find_child(loser_name, true, false)
	if loser:
		spawn_hit_particles(loser.position, Color(1, 0.5, 0.2), 20)
		var dt = create_tween(); dt.set_parallel(true)
		dt.tween_property(loser, "modulate:a", 0.0, 0.8)
		dt.tween_property(loser, "position", loser.position + Vector2(0, 30), 0.8)
		trigger_screen_shake(10.0)
	await get_tree().create_timer(0.8).timeout
	if player_won:
		await show_dialog("Sistem berhasil diamankan!",
			"Kamu berhasil melindungi sistem dari serangan " + battle_manager.enemy_monster.monster_name + ".\nItulah inti cybersecurity — deteksi, blokir, dan pulihkan.",
			"Kamu siap untuk pertarungan sesungguhnya!", "🛡")
	else:
		await show_dialog("Sistem dikompromis!",
			"Di dunia nyata, serangan bisa terjadi kapan saja. Kesiapan adalah segalanya — backup rutin, enkripsi, dan firewall aktif.",
			"Coba lagi! Gunakan move buff lebih awal.", "⚠")
	await get_tree().create_timer(0.5).timeout
	var selection = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(selection)
	get_tree().current_scene = selection
	queue_free()

func _add_label(parent: Node, text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text; l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l

func _make_button(text: String, pos: Vector2, sz: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = sz
	var style = StyleBoxFlat.new(); style.bg_color = color
	style.corner_radius_top_left = 6; style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6; style.corner_radius_bottom_right = 6
	var hover = style.duplicate(); hover.bg_color = color.lightened(0.2)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func highlight_move_button(index: int) -> void:
	if index < 0 or index >= move_buttons.size():
		return
	var btn = move_buttons[index]
	var hs = StyleBoxFlat.new()
	hs.bg_color = btn.get_theme_stylebox("normal").bg_color.lightened(0.15)
	hs.border_color = Color(0.4, 0.9, 1)
	hs.border_width_left = 3; hs.border_width_right = 3
	hs.border_width_top = 3; hs.border_width_bottom = 3
	hs.corner_radius_top_left = 8; hs.corner_radius_top_right = 8
	hs.corner_radius_bottom_left = 8; hs.corner_radius_bottom_right = 8
	var ns = btn.get_theme_stylebox("normal").duplicate()
	for _i in 3:
		btn.add_theme_stylebox_override("normal", hs)
		await get_tree().create_timer(0.3).timeout
		btn.add_theme_stylebox_override("normal", ns)
		await get_tree().create_timer(0.2).timeout
	btn.add_theme_stylebox_override("normal", hs)  # Tetap highlight sampai diklik

func _fit_text(text: String, max_chars: int, max_lines: int) -> String:
	# Split dulu berdasarkan \n
	var raw_lines = text.split("\n")
	var all_lines: Array = []

	# Tiap baris yang terlalu panjang, potong di word boundary
	for raw in raw_lines:
		if raw.length() <= max_chars:
			all_lines.append(raw)
		else:
			var remaining = raw
			while remaining.length() > max_chars:
				var cut = max_chars
				# Cari spasi terdekat ke kiri dari posisi cut
				while cut > 0 and remaining[cut] != " ":
					cut -= 1
				if cut == 0:
					cut = max_chars  # Tidak ada spasi, potong paksa
				all_lines.append(remaining.substr(0, cut))
				remaining = remaining.substr(cut).strip_edges()
			if remaining.length() > 0:
				all_lines.append(remaining)

	# Ambil max_lines baris pertama
	var result: Array = []
	for i in min(all_lines.size(), max_lines):
		result.append(all_lines[i])
	if all_lines.size() > max_lines and result.size() > 0:
		var last = result[result.size() - 1]
		if not last.ends_with("…"):
			result[result.size() - 1] = last.substr(0, min(last.length(), max_chars - 1)) + "…"
	return "\n".join(result)
