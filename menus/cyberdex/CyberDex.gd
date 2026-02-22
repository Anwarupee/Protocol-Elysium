extends Node2D

var selected_monster: Dictionary = {}
var grid_buttons: Array = []

var monsters_data = [
	{
		"id": "encryp_pup", "name": "Encryp-Pup", "number": "001",
		"type": "Data", "color": Color(0.4, 0.8, 1),
		"hp": 120, "speed": 60, "role": "Defender",
		"desc": "Dikenal sebagai penjaga data setia. Semakin sering diserang, semakin kuat pertahanannya. Mewakili konsep enkripsi end-to-end yang melindungi data dari akses tidak sah.",
		"passive": "Hardened Shell — Defense naik setiap kali menerima serangan.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Encrypt", "edu_log": "Enkripsi mengubah data menjadi ciphertext yang tidak bisa dibaca tanpa kunci."},
			{"name": "Firewall Bark", "edu_log": "Firewall memfilter traffic berbahaya sebelum masuk ke sistem."},
			{"name": "Backup Howl", "edu_log": "Backup rutin memastikan data bisa dipulihkan saat terjadi insiden."}
		]
	},
	{
		"id": "ping_go", "name": "Ping-Go", "number": "002",
		"type": "Connection", "color": Color(1, 0.9, 0.3),
		"hp": 90, "speed": 100, "role": "Speedster",
		"desc": "Burung puyuh digital yang bergerak pada kecepatan cahaya fiber optik. Mewakili protokol jaringan yang mengutamakan kecepatan transmisi data dan efisiensi routing.",
		"passive": "Low Latency — Selalu menyerang duluan kecuali lawan punya pasif serupa.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "Packet Dash", "edu_log": "Data dikirim dalam bentuk paket-paket kecil melalui jaringan."},
			{"name": "Traceroute", "edu_log": "Traceroute memetakan jalur data untuk menemukan titik lemah jaringan."},
			{"name": "DDoS Feathers", "edu_log": "DDoS membanjiri server dengan request sampai tidak bisa merespons."}
		]
	},
	{
		"id": "biti", "name": "Biti", "number": "003",
		"type": "Malware", "color": Color(1, 0.4, 0.4),
		"hp": 95, "speed": 80, "role": "Strategist",
		"desc": "Makhluk kecil nakal yang terus bermutasi untuk menghindari deteksi. Mewakili polymorphic malware yang mengubah signature-nya agar lolos dari antivirus konvensional.",
		"passive": "Polymorphic — 30% chance serangan lawan miss karena Biti terus bermutasi.",
		"advantage": "Kuat vs Connection\nLemah vs Data",
		"moves": [
			{"name": "Mimic Byte", "edu_log": "Malware canggih bisa meniru perilaku software legitimate untuk menghindari deteksi."},
			{"name": "Inject", "edu_log": "SQL Injection menyisipkan kode berbahaya ke dalam input yang tidak divalidasi."},
			{"name": "Trojan Gift", "edu_log": "Trojan Horse menyamar sebagai software berguna sebelum mengaktifkan payload berbahaya."}
		]
	},
	{
		"id": "senti_shell", "name": "Senti-Shell", "number": "004",
		"type": "Defensive", "color": Color(0.2, 0.9, 0.6),
		"hp": 150, "speed": 40, "role": "Tank",
		"desc": "The Immutable Guardian. Kura-kura mekanik dengan cangkang berlian data transparan. Mewakili integritas data — informasi yang tidak bisa diubah meski dihantam Brute Force sekalipun.",
		"passive": "Redundancy — Saat HP menyentuh 0 pertama kalinya, bertahan dengan 1 HP.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Diamond Layer", "edu_log": "Data integrity memastikan informasi tidak berubah saat transit atau penyimpanan."},
			{"name": "Immutable Lock", "edu_log": "Immutable backup adalah backup yang tidak bisa dimodifikasi atau dihapus bahkan oleh ransomware."},
			{"name": "Restore Point", "edu_log": "System restore point memungkinkan pemulihan sistem ke kondisi sebelum serangan terjadi."}
		]
	},
	{
		"id": "octo_core", "name": "Octo-Core", "number": "005",
		"type": "System", "color": Color(0.6, 0.3, 1),
		"hp": 110, "speed": 70, "role": "Controller",
		"desc": "Penguasa kernel dari sistem Aether-Net. Delapan tentakelnya adalah kabel bus data berkecepatan tinggi. Berbahaya bahkan saat dikalahkan — mencerminkan kegagalan sistem yang menarik segalanya ikut jatuh.",
		"passive": "Kernel Panic — Saat dikalahkan, mengirim 25 damage flat ke lawan.",
		"advantage": "Kuat vs Data\nLemah vs Social Engineering",
		"moves": [
			{"name": "Memory Overflow", "edu_log": "Buffer overflow terjadi saat program menulis data melebihi batas memori yang dialokasikan."},
			{"name": "Process Kill", "edu_log": "Menghentikan proses kritis bisa melumpuhkan sistem operasi secara keseluruhan."},
			{"name": "System Hijack", "edu_log": "Privilege escalation memungkinkan attacker mengambil alih kontrol sistem dengan hak akses tertinggi."}
		]
	},
	{
		"id": "chamele_auth", "name": "Chamele-Auth", "number": "006",
		"type": "Social Engineering", "color": Color(1, 0.7, 0.2),
		"hp": 95, "speed": 85, "role": "Trickster",
		"desc": "Sang ahli Impersonation. Tidak pernah membobol pintu depan — ia hanya meyakinkan pintu bahwa ia adalah pemilik kuncinya. Melambangkan kerentanan manusia sebagai titik lemah terbesar dalam sistem keamanan.",
		"passive": "Identity Theft — 20% chance mengubah tipenya menjadi tipe lawan saat menyerang.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Phishing Cast", "edu_log": "Phishing menipu korban agar menyerahkan kredensial dengan menyamar sebagai entitas terpercaya."},
			{"name": "Spoofed Token", "edu_log": "Token spoofing memalsukan access token untuk mendapatkan akses tidak sah ke sistem."},
			{"name": "Social Override", "edu_log": "Social engineering mengeksploitasi psikologi manusia, bukan celah teknis — pertahanan terkuat adalah edukasi."}
		]
	}
]

var detail_labels = {}
var move_labels = []

func _ready():
	build_ui()
	show_monster(monsters_data[0])

func build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	for i in range(0, 1152, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)

	# Header bar
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.08, 0.08, 0.22)
	header_bg.size = Vector2(1152, 48)
	add_child(header_bg)

	var header_border = ColorRect.new()
	header_border.color = Color(0.4, 0.9, 1, 0.5)
	header_border.size = Vector2(1152, 2)
	header_border.position = Vector2(0, 48)
	add_child(header_border)

	var title = create_label("◈  CYBER-DEX", Vector2(20, 12), 20, Color(0.4, 0.9, 1))
	add_child(title)

	var count = create_label(str(monsters_data.size()) + " CYBER-MON REGISTERED", Vector2(0, 15), 13, Color(0.5, 0.5, 0.7))
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.custom_minimum_size = Vector2(1152, 20)
	add_child(count)

	# ── LEFT PANEL (detail) ──
	var left_bg = ColorRect.new()
	left_bg.color = Color(0.07, 0.07, 0.2, 0.95)
	left_bg.size = Vector2(480, 598)
	left_bg.position = Vector2(0, 50)
	add_child(left_bg)

	# Monster sprite area
	var sprite_area = ColorRect.new()
	sprite_area.color = Color(0.1, 0.1, 0.28)
	sprite_area.size = Vector2(480, 200)
	sprite_area.position = Vector2(0, 50)
	sprite_area.name = "sprite_area"
	add_child(sprite_area)

	# Monster sprite placeholder
	var sprite = ColorRect.new()
	sprite.size = Vector2(110, 110)
	sprite.position = Vector2(185, 95)
	sprite.name = "monster_sprite"
	add_child(sprite)

	var sprite_glow = ColorRect.new()
	sprite_glow.size = Vector2(140, 140)
	sprite_glow.position = Vector2(170, 80)
	sprite_glow.name = "sprite_glow"
	add_child(sprite_glow)
	move_child(sprite_glow, sprite_glow.get_index() - 1)

	var sprite_shine = ColorRect.new()
	sprite_shine.color = Color(1, 1, 1, 0.15)
	sprite_shine.size = Vector2(35, 15)
	sprite_shine.position = Vector2(190, 100)
	add_child(sprite_shine)

	# Number + name
	detail_labels["number"] = create_label("#001", Vector2(20, 258), 14, Color(0.5, 0.5, 0.7))
	add_child(detail_labels["number"])

	detail_labels["name"] = create_label("Encryp-Pup", Vector2(20, 275), 26, Color(0.4, 0.8, 1))
	add_child(detail_labels["name"])

	detail_labels["type_badge"] = create_label("[ Data ]", Vector2(20, 308), 13, Color(0.6, 0.6, 0.9))
	detail_labels["type_badge"].custom_minimum_size = Vector2(440, 20)
	add_child(detail_labels["type_badge"])

	detail_labels["role"] = create_label("Defender", Vector2(20, 328), 13, Color(1, 0.8, 0.3))
	add_child(detail_labels["role"])

	# Divider
	var div1 = ColorRect.new()
	div1.color = Color(0.3, 0.3, 0.5, 0.5)
	div1.size = Vector2(440, 1)
	div1.position = Vector2(20, 350)
	add_child(div1)

	# Desc
	detail_labels["desc"] = create_label("", Vector2(20, 354), 12, Color(0.75, 0.75, 0.85))
	detail_labels["desc"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["desc"].custom_minimum_size = Vector2(450, 65)
	add_child(detail_labels["desc"])

	# Stats
	add_child(create_label("STATS", Vector2(20, 410), 12, Color(0.5, 0.7, 1)))
	detail_labels["hp"] = create_label("HP: 120", Vector2(20, 428), 13, Color(0.3, 1, 0.4))
	add_child(detail_labels["hp"])
	detail_labels["speed"] = create_label("SPD: 60", Vector2(120, 428), 13, Color(1, 0.8, 0.3))
	add_child(detail_labels["speed"])

	# Passive
	var div2 = ColorRect.new()
	div2.color = Color(0.3, 0.3, 0.5, 0.5)
	div2.size = Vector2(440, 1)
	div2.position = Vector2(20, 448)
	add_child(div2)

	add_child(create_label("PASSIVE", Vector2(20, 455), 12, Color(1, 0.8, 0.3)))
	detail_labels["passive"] = create_label("", Vector2(20, 472), 12, Color(0.9, 0.85, 0.6))
	detail_labels["passive"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["passive"].custom_minimum_size = Vector2(440, 35)
	add_child(detail_labels["passive"])

	# Advantage
	var div3 = ColorRect.new()
	div3.color = Color(0.3, 0.3, 0.5, 0.5)
	div3.size = Vector2(440, 1)
	div3.position = Vector2(20, 512)
	add_child(div3)

	add_child(create_label("TYPE ADVANTAGE", Vector2(20, 518), 12, Color(0.4, 1, 0.4)))
	detail_labels["advantage"] = create_label("", Vector2(20, 534), 12, Color(0.7, 1, 0.7))
	detail_labels["advantage"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["advantage"].custom_minimum_size = Vector2(440, 35)
	add_child(detail_labels["advantage"])

	# ── RIGHT PANEL (grid + moves) ──
	var right_bg = ColorRect.new()
	right_bg.color = Color(0.06, 0.06, 0.18, 0.95)
	right_bg.size = Vector2(660, 598)
	right_bg.position = Vector2(492, 50)
	add_child(right_bg)

	var right_border = ColorRect.new()
	right_border.color = Color(0.2, 0.2, 0.4)
	right_border.size = Vector2(2, 598)
	right_border.position = Vector2(492, 50)
	add_child(right_border)

	# Grid label
	add_child(create_label("ALL CYBER-MON", Vector2(510, 60), 13, Color(0.5, 0.6, 0.8)))

	# Monster grid
	build_monster_grid()

	# Move section
	var move_divider = ColorRect.new()
	move_divider.color = Color(0.3, 0.3, 0.5, 0.5)
	move_divider.size = Vector2(630, 1)
	move_divider.position = Vector2(502, 295)
	add_child(move_divider)

	add_child(create_label("MOVE SET & EDU-LOG", Vector2(510, 303), 13, Color(0.5, 0.8, 1)))

	# Move slots (3 moves)
	for i in 3:
		var move_bg = ColorRect.new()
		move_bg.color = Color(0.1, 0.1, 0.25)
		move_bg.size = Vector2(618, 88)
		move_bg.position = Vector2(503, 322 + i * 96)
		move_bg.name = "move_bg_" + str(i)
		add_child(move_bg)

		var move_border = ColorRect.new()
		move_border.color = Color(0.3, 0.3, 0.5)
		move_border.size = Vector2(618, 2)
		move_border.position = Vector2(503, 322 + i * 96)
		add_child(move_border)

		var move_name = create_label("Move " + str(i+1), Vector2(515, 328 + i * 96), 14, Color(0.8, 0.9, 1))
		move_name.name = "move_name_" + str(i)
		add_child(move_name)

		var move_edu = create_label("", Vector2(515, 350 + i * 96), 11, Color(0.6, 0.8, 0.6))
		move_edu.autowrap_mode = TextServer.AUTOWRAP_WORD
		move_edu.custom_minimum_size = Vector2(598, 50)
		move_edu.name = "move_edu_" + str(i)
		add_child(move_edu)

		move_labels.append({"name": move_name, "edu": move_edu, "bg": move_bg})
		
	# back button
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(1022, 608)
	back_btn.size = Vector2(110, 30)

	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.25, 0.15, 0.45)
	back_style.corner_radius_top_left = 5
	back_style.corner_radius_top_right = 5
	back_style.corner_radius_bottom_left = 5
	back_style.corner_radius_bottom_right = 5
	back_style.border_color = Color(0.5, 0.3, 0.8)
	back_style.border_width_left = 1
	back_style.border_width_right = 1
	back_style.border_width_top = 1
	back_style.border_width_bottom = 1

	var back_hover = back_style.duplicate()
	back_hover.bg_color = Color(0.35, 0.2, 0.6)

	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_stylebox_override("hover", back_hover)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.8, 0.7, 1))
	back_btn.pressed.connect(go_back)
	add_child(back_btn)

func build_monster_grid():
	var cols = 6
	var cell_size = Vector2(88, 88)
	var start = Vector2(505, 80)

	for i in monsters_data.size():
		var m = monsters_data[i]
		var col_idx = i % cols
		var row_idx = i / cols
		var pos = start + Vector2(col_idx * (cell_size.x + 8), row_idx * (cell_size.y + 8))

		# Cell bg
		var cell_bg = ColorRect.new()
		cell_bg.color = Color(0.1, 0.1, 0.28)
		cell_bg.size = cell_size
		cell_bg.position = pos
		add_child(cell_bg)

		# Cell border
		var cell_border = StyleBoxFlat.new()
		cell_border.bg_color = Color(0.1, 0.1, 0.28)
		cell_border.border_color = Color(m["color"].r, m["color"].g, m["color"].b, 0.4)
		cell_border.border_width_left = 1
		cell_border.border_width_right = 1
		cell_border.border_width_top = 1
		cell_border.border_width_bottom = 1
		cell_border.corner_radius_top_left = 6
		cell_border.corner_radius_top_right = 6
		cell_border.corner_radius_bottom_left = 6
		cell_border.corner_radius_bottom_right = 6

		var cell_panel = PanelContainer.new()
		cell_panel.size = cell_size
		cell_panel.position = pos
		cell_panel.add_theme_stylebox_override("panel", cell_border)
		add_child(cell_panel)

		# Monster color square
		var icon = ColorRect.new()
		icon.color = m["color"]
		icon.size = Vector2(44, 44)
		icon.position = pos + Vector2(22, 10)
		add_child(icon)

		var icon_glow = ColorRect.new()
		icon_glow.color = Color(m["color"].r, m["color"].g, m["color"].b, 0.2)
		icon_glow.size = Vector2(56, 56)
		icon_glow.position = pos + Vector2(16, 4)
		add_child(icon_glow)
		move_child(icon_glow, icon_glow.get_index() - 1)

		# Number
		var num = create_label("#" + m["number"], pos + Vector2(4, 62), 10, Color(0.5, 0.5, 0.7))
		add_child(num)

		# Name short
		var short_name = m["name"].split("-")[0]
		var name_lbl = create_label(short_name, pos + Vector2(cell_size.x / 2, 74), 10, m["color"])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.custom_minimum_size = Vector2(cell_size.x, 14)
		name_lbl.position = pos + Vector2(0, 74)
		add_child(name_lbl)

		# Click button
		var btn = Button.new()
		btn.size = cell_size
		btn.position = pos
		btn.flat = true
		btn.modulate = Color(1, 1, 1, 0)
		var idx = i
		btn.pressed.connect(func(): show_monster(monsters_data[idx]))
		add_child(btn)

		grid_buttons.append({"panel": cell_panel, "style": cell_border, "monster": m})

func show_monster(m: Dictionary):
	selected_monster = m
	var col = m["color"]

	# Update sprite
	var sprite = find_child("monster_sprite", true, false)
	var glow = find_child("sprite_glow", true, false)
	var area = find_child("sprite_area", true, false)
	if sprite:
		sprite.color = col
	if glow:
		glow.color = Color(col.r, col.g, col.b, 0.15)
	if area:
		area.color = Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 1.0)

	# Update labels
	detail_labels["number"].text = "#" + m["number"]
	detail_labels["name"].text = m["name"]
	detail_labels["name"].add_theme_color_override("font_color", col)
	detail_labels["type_badge"].text = "[ " + m["type"] + " ]"
	detail_labels["type_badge"].add_theme_color_override("font_color", col)
	detail_labels["role"].text = m["role"]
	detail_labels["desc"].text = m["desc"]
	detail_labels["hp"].text = "HP: " + str(m["hp"])
	detail_labels["speed"].text = "SPD: " + str(m["speed"])
	detail_labels["passive"].text = m["passive"]
	detail_labels["advantage"].text = m["advantage"]

	# Update moves
	for i in m["moves"].size():
		if i < move_labels.size():
			move_labels[i]["name"].text = "▸ " + m["moves"][i]["name"]
			move_labels[i]["edu"].text = m["moves"][i]["edu_log"]
			move_labels[i]["bg"].color = Color(col.r * 0.15, col.g * 0.15, col.b * 0.15)

	# Highlight selected grid cell
	for g in grid_buttons:
		var is_selected = g["monster"]["id"] == m["id"]
		g["style"].border_color = Color(
			g["monster"]["color"].r,
			g["monster"]["color"].g,
			g["monster"]["color"].b,
			1.0 if is_selected else 0.4
		)
		g["style"].border_width_left = 3 if is_selected else 1
		g["style"].border_width_right = 3 if is_selected else 1
		g["style"].border_width_top = 3 if is_selected else 1
		g["style"].border_width_bottom = 3 if is_selected else 1
		g["panel"].add_theme_stylebox_override("panel", g["style"])

func go_back():
	var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
