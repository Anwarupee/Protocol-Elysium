extends "res://battle/Battle.gd"

# ══════════════════════════════════════════════
#  TutorialBattle.gd — Guided Tutorial
#  Fully dynamic — works dengan sentinel apapun
# ══════════════════════════════════════════════

var tutorial_active: bool = false
var tutorial_step: int = 0
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
	battle_manager.start_battle(player_choice, enemy_choice)
	await play_intro_animation()
	await start_tutorial_flow()

func _categorize_moves():
	for i in p_moves.size():
		var effect = p_moves[i].get("effect", "")
		if move_buff_idx == -1 and effect in BUFF_EFFECTS:
			move_buff_idx = i
		elif move_heal_idx == -1 and effect in HEAL_EFFECTS:
			move_heal_idx = i
		elif move_attack_idx == -1 and effect in ATTACK_EFFECTS:
			move_attack_idx = i
		elif move_extra_idx == -1:
			move_extra_idx = i
	if move_attack_idx == -1: move_attack_idx = 0
	if move_buff_idx   == -1: move_buff_idx   = 1
	if move_heal_idx   == -1: move_heal_idx   = 2
	if move_extra_idx  == -1: move_extra_idx  = 3

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
	await show_dialog("Move: " + bm["name"].to_upper() + "  [BUFF — Perkuat Pertahanan]",
		bm.get("edu_popup", bm.get("edu_log", "Move ini memperkuat pertahananmu.")),
		"Sekarang klik  " + bm["name"].to_upper() + "  di daftar move!", "🛡")
	await wait_for_move_used(move_buff_idx)
	set_buttons_disabled(true)
	await show_dialog("Bagus! " + bm["name"] + " berhasil!",
		"Move ini merepresentasikan pertahanan nyata di dunia siber.\nPertahanan berlapis adalah kunci — jangan tunggu diserang baru bertahan.",
		"Lanjut ke move serangan!", "✓")

	# Step attack
	tutorial_step = 2
	set_buttons_disabled(false)
	var am = p_moves[move_attack_idx]
	await show_dialog("Move: " + am["name"].to_upper() + "  [SERANGAN]",
		am.get("edu_popup", am.get("edu_log", "Move ini menyerang lawan.")),
		"Klik  " + am["name"].to_upper() + "  untuk menyerang Biti!", "⚔")
	await wait_for_move_used(move_attack_idx)
	set_buttons_disabled(true)
	await show_dialog("Serangan berhasil!",
		"Di dunia siber, pertahanan aktif berarti memblokir dan melawan ancaman sebelum mereka merusak lebih jauh.",
		"Lanjut ke move pemulihan!", "✓")

	# Step heal
	tutorial_step = 3
	set_buttons_disabled(false)
	var hm = p_moves[move_heal_idx]
	await show_dialog("Move: " + hm["name"].to_upper() + "  [PULIHKAN HP]",
		hm.get("edu_popup", hm.get("edu_log", "Move ini memulihkan HP.")),
		"Gunakan  " + hm["name"].to_upper() + "  untuk memulihkan HP!", "💾")
	await wait_for_move_used(move_heal_idx)
	set_buttons_disabled(true)
	await show_dialog("HP pulih!",
		"Di dunia nyata, pemulihan sistem berarti restore dari backup dan incident response yang cepat.\nSemakin siap kamu sebelum serangan, semakin cepat pemulihannya.",
		"Sekarang kamu bebas gunakan semua move!", "✓")

	# Free battle
	tutorial_step = STEP_FREE_BATTLE
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
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.07, 0.08, 0.26)
	panel.size = Vector2(720, 220)
	panel.position = Vector2(216, 214)
	overlay.add_child(panel)

	var bt = ColorRect.new(); bt.color = Color(0.4, 0.9, 1); bt.size = Vector2(720, 3); panel.add_child(bt)
	var bl = ColorRect.new(); bl.color = Color(0.4, 0.9, 1, 0.5); bl.size = Vector2(3, 220); panel.add_child(bl)

	_add_label(panel, "[ ELYSIUM INTEL ]", Vector2(12, 10), 11, Color(0.4, 0.9, 1))
	_add_label(panel, icon, Vector2(682, 8), 22, Color(0.4, 0.9, 1, 0.7))
	_add_label(panel, title, Vector2(12, 28), 15, Color(1, 1, 0.9))

	var sep = ColorRect.new(); sep.color = Color(1,1,1,0.08); sep.size = Vector2(696, 1); sep.position = Vector2(12, 52); panel.add_child(sep)

	var bl2 = _add_label(panel, body, Vector2(12, 60), 12, Color(0.85, 0.92, 1))
	bl2.size = Vector2(696, 100); bl2.autowrap_mode = TextServer.AUTOWRAP_WORD

	var tb = ColorRect.new(); tb.color = Color(0.1, 0.3, 0.15, 0.8); tb.size = Vector2(696, 30); tb.position = Vector2(12, 168); panel.add_child(tb)
	var tl = _add_label(panel, "💡  " + tip, Vector2(18, 174), 11, Color(0.5, 1, 0.6))
	tl.size = Vector2(540, 24); tl.autowrap_mode = TextServer.AUTOWRAP_WORD

	var btn = _make_button("Mengerti  ▶", Vector2(540, 176), Vector2(168, 36), Color(0.1, 0.4, 0.2))
	panel.add_child(btn)

	overlay.modulate.a = 0.0
	var tw = create_tween(); tw.tween_property(overlay, "modulate:a", 1.0, 0.2); await tw.finished
	await btn.pressed
	var tw2 = create_tween(); tw2.tween_property(overlay, "modulate:a", 0.0, 0.15); await tw2.finished
	overlay.queue_free()

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
	var target = find_child(node_name, true, false)
	if not target: return
	var glow = ColorRect.new()
	glow.color = Color(0.4, 0.9, 1, 0.25)
	glow.size = (target.size + Vector2(12,12)) if target is Control else Vector2(90, 90)
	glow.position = (target.position - Vector2(6,6)) if target is Control else (target.position - Vector2(45,45))
	add_child(glow)
	var t = create_tween(); t.set_loops(3)
	t.tween_property(glow, "modulate:a", 0.3, 0.4)
	t.tween_property(glow, "modulate:a", 1.0, 0.4)
	await t.finished
	glow.queue_free()

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
