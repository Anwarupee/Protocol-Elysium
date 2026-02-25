extends Node2D

var selected_monster: String = ""
var active_tab: String = "Data"
var card_nodes = []
var tab_buttons = {}
var cards_container: Node2D
var confirm_btn: Button
var detail_labels = {}
var detail_panel: Node2D
var particles: Array = []
var time: float = 0.0
var card_w = 240

var monsters_info = [
	{
		"id": "encryp_pup", "name": "ENCRYP-PUP", "type": "Data",
		"color": Color(0.4, 0.8, 1), "hp": 120, "speed": 60, "role": "Defender",
		"desc": "Anjing gembok yang tangguh. Makin kuat saat diserang.",
		"moves": ["Encrypt", "Firewall Bark", "Backup Howl", "SSL Handshake"]
	},
	{
		"id": "ping_go", "name": "PING-GO", "type": "Connection",
		"color": Color(1, 0.9, 0.3), "hp": 90, "speed": 100, "role": "Speedster",
		"desc": "Burung puyuh super cepat. Selalu menyerang duluan.",
		"moves": ["Packet Dash", "Traceroute", "DDoS Feathers", "Ping Flood"]
	},
	{
		"id": "biti", "name": "BITI", "type": "Malware",
		"color": Color(1, 0.4, 0.4), "hp": 95, "speed": 80, "role": "Strategist",
		"desc": "Makhluk nakal yang bisa meniru jurus lawan.",
		"moves": ["Mimic Byte", "Inject", "Trojan Gift", "Rootkit Hide"]
	},
	{
		"id": "senti_shell", "name": "SENTI-SHELL", "type": "Defensive",
		"color": Color(0.2, 0.9, 0.6), "hp": 150, "speed": 40, "role": "Tank",
		"desc": "Kura-kura mekanik dengan cangkang berlian data. Tidak bisa ditembus.",
		"moves": ["Diamond Layer", "Shell Slam", "Immutable Lock", "Restore Point"]
	},
	{
		"id": "octo_core", "name": "OCTO-CORE", "type": "System",
		"color": Color(0.6, 0.3, 1), "hp": 110, "speed": 70, "role": "Controller",
		"desc": "Gurita CPU yang menguasai kernel. Berbahaya bahkan saat kalah.",
		"moves": ["Memory Overflow", "Process Kill", "System Hijack", "Fork Bomb"]
	},
	{
		"id": "chamele_auth", "name": "CHAMELE-AUTH", "type": "Social Engineering",
		"color": Color(1, 0.7, 0.2), "hp": 95, "speed": 85, "role": "Trickster",
		"desc": "Bunglon piksel yang mencuri identitas. Tidak pernah menyerang langsung.",
		"moves": ["Phishing Cast", "Spoofed Token", "Social Override", "Pretexting"]
	},
	{
		"id": "vaultex", "name": "VAULTEX", "type": "Data",
		"color": Color(0.5, 0.85, 1), "hp": 130, "speed": 45, "role": "Support",
		"desc": "Brankas digital berjalan. Tidak akan terbuka kecuali menerima hash key yang tepat.",
		"moves": ["Hash Lock", "Integrity Check", "Data Shred", "Mirror Backup"]
	},
	{
		"id": "cipher_ray", "name": "CIPHER-RAY", "type": "Data",
		"color": Color(0.6, 0.9, 1), "hp": 100, "speed": 80, "role": "Attacker",
		"desc": "Elang kristal predator data tak terenkripsi di lapisan Upper-Net.",
		"moves": ["Brute Decrypt", "Key Exchange", "Cipher Strike", "Zero-Knowledge"]
	},
	{
		"id": "routerex", "name": "ROUTEREX", "type": "Connection",
		"color": Color(1, 0.85, 0.2), "hp": 105, "speed": 65, "role": "Controller",
		"desc": "Dinosaurus gateway yang membelokkan serangan ke jalur buntu.",
		"moves": ["NAT Punch", "Port Scan", "Bandwidth Throttle", "Reroute"]
	},
	{
		"id": "latencia", "name": "LATENCIA", "type": "Connection",
		"color": Color(1, 0.7, 0.1), "hp": 88, "speed": 90, "role": "Speedster",
		"desc": "Ubur-ubur serat optik manifestasi lag jaringan.",
		"moves": ["Timeout Strike", "Packet Loss", "QoS Drain", "Syn Flood"]
	},
	{
		"id": "ransom_rex", "name": "RANSOM-REX", "type": "Malware",
		"color": Color(1, 0.2, 0.2), "hp": 105, "speed": 60, "role": "Controller",
		"desc": "Naga rantai digital penyandera data paling ditakuti.",
		"moves": ["File Encrypt", "Ransom Note", "Double Extortion", "Decoy Payload"]
	},
	{
		"id": "worm_ling", "name": "WORM-LING", "type": "Malware",
		"color": Color(0.8, 0.3, 0.3), "hp": 85, "speed": 95, "role": "Swarm",
		"desc": "Cacing neon yang menduplikasi diri secara eksponensial.",
		"moves": ["Propagate", "Network Crawl", "Payload Deploy", "Mass Infection"]
	},
	{
		"id": "patchwork", "name": "PATCHWORK", "type": "Defensive",
		"color": Color(0.1, 0.8, 0.5), "hp": 140, "speed": 50, "role": "Tank/Healer",
		"desc": "Beruang tambalan digital dari jutaan perbaikan sistem darurat.",
		"moves": ["Patch Deploy", "Vulnerability Scan", "Zero-Day Shield", "Hardened Kernel"]
	},
	{
		"id": "bastion", "name": "BASTION", "type": "Defensive",
		"color": Color(0.3, 1, 0.7), "hp": 160, "speed": 35, "role": "Pure Tank",
		"desc": "Ksatria firewall baris pertahanan terakhir mainframe.",
		"moves": ["Perimeter Strike", "Access Denied", "Failover", "Iron Curtain"]
	},
	{
		"id": "daemon_x", "name": "DAEMON-X", "type": "System",
		"color": Color(0.5, 0.2, 0.9), "hp": 100, "speed": 75, "role": "Debuffer",
		"desc": "Entitas background yang bisa menghentikan proses hidup lawan.",
		"moves": ["Process Inject", "Kill Switch", "Daemon Spawn", "Memory Leak"]
	},
	{
		"id": "bios_wraith", "name": "BIOS-WRAITH", "type": "System",
		"color": Color(0.7, 0.4, 1), "hp": 95, "speed": 55, "role": "Controller",
		"desc": "Roh motherboard kuno pengontrol instruksi paling dasar.",
		"moves": ["BIOS Flash", "Boot Loop", "Overclock", "Firmware Lock"]
	},
	{
		"id": "vish_ara", "name": "VISH-ARA", "type": "Social Engineering",
		"color": Color(1, 0.6, 0.1), "hp": 90, "speed": 80, "role": "Controller",
		"desc": "Ular kobra speaker spesialis manipulasi suara.",
		"moves": ["Voice Spoof", "Hypnotic Tone", "Caller ID Fake", "Social Script"]
	},
	{
		"id": "bait_eel", "name": "BAIT-EEL", "type": "Social Engineering",
		"color": Color(1, 0.5, 0.0), "hp": 92, "speed": 88, "role": "Trickster",
		"desc": "Belut umpan digital pemancing mangsa dengan janji palsu.",
		"moves": ["Lure Strike", "Watering Hole", "Click Bait", "Drive-by Download"]
	}
]

var type_colors = {
	"Data": Color(0.4, 0.8, 1),
	"Connection": Color(1, 0.9, 0.3),
	"Malware": Color(1, 0.4, 0.4),
	"Defensive": Color(0.2, 0.9, 0.6),
	"System": Color(0.6, 0.3, 1),
	"Social Engineering": Color(1, 0.7, 0.2)
}

var passive_texts = {
	"encryp_pup": "Hardened Shell\nDefense naik tiap kena serangan",
	"ping_go": "Low Latency\nSelalu menyerang duluan",
	"biti": "Polymorphic\n30% chance serangan lawan miss",
	"senti_shell": "Redundancy\nBertahan di 1 HP saat pertama kali KO",
	"octo_core": "Kernel Panic\nDeal 25 damage saat dikalahkan",
	"chamele_auth": "Identity Theft\n20% chance salin tipe lawan",
	"vaultex": "Checksum\nJika HP genap di akhir turn, pulihkan 5 HP",
	"cipher_ray": "AES-256\n20% chance enkripsi diri, kurangi damage masuk",
	"routerex": "BGP Route\n25% chance redirect serangan lawan -50% damage",
	"latencia": "Jitter\n30% chance serangan hit dua kali dengan power separuh",
	"ransom_rex": "Encryption Lock\n25% chance lock heal lawan 2 turn saat menyerang",
	"worm_ling": "Self-Replicating\nDamage naik 5 tiap kena serangan (max 3 stack)",
	"patchwork": "Hot Patch\nDamage > 30 masuk, defense naik 1 otomatis",
	"bastion": "DMZ\nSerangan di bawah 15 damage diabaikan",
	"daemon_x": "Background Process\n20% chance 10 damage otomatis tiap akhir turn",
	"bios_wraith": "Legacy Code\n15% chance lawan gagal gunakan move",
	"vish_ara": "Vishing\n25% chance serangan lawan menyerang diri sendiri",
	"bait_eel": "Honeypot\n30% chance lawan skip turn jika pakai move power > 60"
}

var advantage_texts = {
	"encryp_pup": "⚡ Kuat vs Malware\n⚠ Lemah vs Connection",
	"ping_go": "⚡ Kuat vs Data\n⚠ Lemah vs Malware",
	"biti": "⚡ Kuat vs Connection\n⚠ Lemah vs Data",
	"senti_shell": "⚡ Kuat vs Social Engineering\n⚠ Lemah vs System",
	"octo_core": "⚡ Kuat vs Data\n⚠ Lemah vs Social Engineering",
	"chamele_auth": "⚡ Kuat vs System\n⚠ Lemah vs Connection",
	"vaultex": "⚡ Kuat vs Malware\n⚠ Lemah vs Connection",
	"cipher_ray": "⚡ Kuat vs Malware\n⚠ Lemah vs Connection",
	"routerex": "⚡ Kuat vs Data\n⚠ Lemah vs Malware",
	"latencia": "⚡ Kuat vs Data\n⚠ Lemah vs Malware",
	"ransom_rex": "⚡ Kuat vs Connection\n⚠ Lemah vs Data",
	"worm_ling": "⚡ Kuat vs Connection\n⚠ Lemah vs Data",
	"patchwork": "⚡ Kuat vs Social Engineering\n⚠ Lemah vs System",
	"bastion": "⚡ Kuat vs Social Engineering\n⚠ Lemah vs System",
	"daemon_x": "⚡ Kuat vs Data\n⚠ Lemah vs Social Engineering",
	"bios_wraith": "⚡ Kuat vs Data\n⚠ Lemah vs Social Engineering",
	"vish_ara": "⚡ Kuat vs System\n⚠ Lemah vs Connection",
	"bait_eel": "⚡ Kuat vs System\n⚠ Lemah vs Connection"
}

func _ready():
	build_ui()
	spawn_particles()

func _process(delta):
	time += delta
	update_particles(delta)

func build_ui():
	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12)
	bg.size = Vector2(1152, 648)
	add_child(bg)

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

	for i in range(0, 648, 4):
		var scan = ColorRect.new()
		scan.color = Color(0, 0, 0, 0.025)
		scan.size = Vector2(1152, 2)
		scan.position = Vector2(0, i)
		add_child(scan)

	# ── HEADER ──
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.06, 0.06, 0.18, 0.95)
	header_bg.size = Vector2(1152, 95)
	add_child(header_bg)

	var header_border = ColorRect.new()
	header_border.color = Color(0.3, 0.5, 0.9, 0.5)
	header_border.size = Vector2(1152, 2)
	header_border.position = Vector2(0, 95)
	add_child(header_border)

	var title = create_label("SELECT YOUR SENTINEL", Vector2(0, 18), 30, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 40)
	add_child(title)

	var subtitle = create_label("Pilih domain lalu pilih Sentinel untuk melawan ancaman siber!", Vector2(0, 58), 13, Color(0.5, 0.6, 0.8))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1152, 20)
	add_child(subtitle)

	# ── TABS ──
	build_tabs()

	# ── CARDS AREA ──
	cards_container = Node2D.new()
	cards_container.position = Vector2(0, 185)
	add_child(cards_container)

	# ── DETAIL PANEL ──
	detail_panel = build_detail_panel()
	add_child(detail_panel)
	detail_panel.visible = false

	# ── CONFIRM BUTTON ──
	confirm_btn = create_styled_button("⚔  START BATTLE!", Vector2(380, 606), Vector2(390, 38), Color(0.08, 0.4, 0.15))
	confirm_btn.pressed.connect(start_battle)
	confirm_btn.visible = false
	add_child(confirm_btn)

	# ── BACK BUTTON ──
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(20, 608)
	back_btn.size = Vector2(110, 34)

	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.12, 0.12, 0.28)
	back_style.corner_radius_top_left = 6
	back_style.corner_radius_top_right = 6
	back_style.corner_radius_bottom_left = 6
	back_style.corner_radius_bottom_right = 6
	back_style.border_color = Color(0.3, 0.3, 0.6, 0.5)
	back_style.border_width_left = 1
	back_style.border_width_right = 1
	back_style.border_width_top = 1
	back_style.border_width_bottom = 1
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_font_size_override("font_size", 13)
	back_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	back_btn.pressed.connect(func():
		var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
		get_tree().root.add_child(scene)
		get_tree().current_scene = scene
		queue_free()
	)
	add_child(back_btn)

	show_tab("Data")

func build_tabs():
	var types = ["Data", "Connection", "Malware", "Defensive", "System", "Social Engineering"]
	var tab_width = 158
	var spacing = 6
	var total_w = types.size() * tab_width + (types.size() - 1) * spacing
	var start_x = (1152 - total_w) / 2

	for i in types.size():
		var t = types[i]
		var col = type_colors[t]
		var x = start_x + i * (tab_width + spacing)

		var tab_bg = ColorRect.new()
		tab_bg.size = Vector2(tab_width, 44)
		tab_bg.position = Vector2(x, 100)
		tab_bg.color = Color(col.r, col.g, col.b, 0.1)
		tab_bg.name = "tab_bg_" + t
		add_child(tab_bg)

		var tab_accent = ColorRect.new()
		tab_accent.size = Vector2(tab_width, 3)
		tab_accent.position = Vector2(x, 141)
		tab_accent.color = Color(col.r, col.g, col.b, 0.3)
		tab_accent.name = "tab_border_" + t
		add_child(tab_accent)

		var btn = Button.new()
		btn.text = t
		btn.size = Vector2(tab_width, 44)
		btn.position = Vector2(x, 100)
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", col)
		btn.pressed.connect(func(): show_tab(t))
		add_child(btn)

		tab_buttons[t] = {"bg": tab_bg, "border": tab_accent, "btn": btn, "color": col}

	var divider = ColorRect.new()
	divider.color = Color(0.2, 0.2, 0.4, 0.5)
	divider.size = Vector2(1152, 1)
	divider.position = Vector2(0, 144)
	add_child(divider)

func show_tab(type_name: String):
	active_tab = type_name

	for t in tab_buttons:
		var col = tab_buttons[t]["color"]
		if t == type_name:
			tab_buttons[t]["bg"].color = Color(col.r, col.g, col.b, 0.3)
			tab_buttons[t]["border"].color = col
			tab_buttons[t]["border"].size.y = 4
		else:
			tab_buttons[t]["bg"].color = Color(col.r, col.g, col.b, 0.08)
			tab_buttons[t]["border"].color = Color(col.r, col.g, col.b, 0.25)
			tab_buttons[t]["border"].size.y = 2

	for child in cards_container.get_children():
		child.queue_free()
	card_nodes.clear()

	var filtered = monsters_info.filter(func(m): return m["type"] == type_name)
	var type_col = type_colors[type_name]

	# Domain header
	var adv_map = {
		"Data": "⚡ Kuat vs Malware   ⚠ Lemah vs Connection",
		"Connection": "⚡ Kuat vs Data   ⚠ Lemah vs Malware",
		"Malware": "⚡ Kuat vs Connection   ⚠ Lemah vs Data",
		"Defensive": "⚡ Kuat vs Social Engineering   ⚠ Lemah vs System",
		"System": "⚡ Kuat vs Data   ⚠ Lemah vs Social Engineering",
		"Social Engineering": "⚡ Kuat vs System   ⚠ Lemah vs Connection"
	}

	var domain_bar = ColorRect.new()
	domain_bar.color = Color(type_col.r, type_col.g, type_col.b, 0.08)
	domain_bar.size = Vector2(1152, 38)
	domain_bar.position = Vector2(0, 0)
	cards_container.add_child(domain_bar)

	var domain_accent = ColorRect.new()
	domain_accent.color = Color(type_col.r, type_col.g, type_col.b, 0.5)
	domain_accent.size = Vector2(4, 38)
	domain_accent.position = Vector2(0, 0)
	cards_container.add_child(domain_accent)

	var header = create_label(type_name.to_upper() + " DOMAIN  —  " + str(filtered.size()) + " Sentinels", Vector2(15, 8), 14, type_col)
	cards_container.add_child(header)

	var adv_label = create_label(adv_map[type_name], Vector2(0, 12), 11, Color(type_col.r, type_col.g, type_col.b, 0.7))
	adv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	adv_label.custom_minimum_size = Vector2(1132, 18)
	cards_container.add_child(adv_label)

	# Cards
	var card_w = 240
	var spacing = 25
	var total_w = filtered.size() * card_w + (filtered.size() - 1) * spacing
	var start_x = (1152 - total_w) / 2

	for i in filtered.size():
		var card = build_monster_card(filtered[i], Vector2(start_x + i * (card_w + spacing), 48))
		cards_container.add_child(card)
		card_nodes.append(card)

	var current_type = ""
	for m in monsters_info:
		if m["id"] == selected_monster:
			current_type = m["type"]
	if current_type != type_name:
		detail_panel.visible = false
		confirm_btn.visible = false

func build_monster_card(info: Dictionary, pos: Vector2) -> Node2D:
	var card = Node2D.new()
	card.position = pos
	var col = info["color"]

	# Card background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.2, 0.95)
	style.border_color = Color(col.r, col.g, col.b, 0.5)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	var panel = PanelContainer.new()
	panel.size = Vector2(card_w, 360)
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)

	# Sprite area background
	var sprite_bg = ColorRect.new()
	sprite_bg.color = Color(col.r * 0.15, col.g * 0.15, col.b * 0.2)
	sprite_bg.size = Vector2(card_w, 150)
	card.add_child(sprite_bg)

	# Top accent
	var top_accent = ColorRect.new()
	top_accent.color = col
	top_accent.size = Vector2(card_w, 3)
	card.add_child(top_accent)

	# Sprite glow
	var glow = ColorRect.new()
	glow.color = Color(col.r, col.g, col.b, 0.2)
	glow.size = Vector2(100, 100)
	glow.position = Vector2((card_w - 100) / 2, 25)
	card.add_child(glow)

	# Sprite
	var sprite = ColorRect.new()
	sprite.color = col
	sprite.size = Vector2(75, 75)
	sprite.position = Vector2((card_w - 75) / 2, 37)
	card.add_child(sprite)

	var shine = ColorRect.new()
	shine.color = Color(1, 1, 1, 0.18)
	shine.size = Vector2(22, 10)
	shine.position = Vector2((card_w - 75) / 2 + 5, 42)
	card.add_child(shine)

	# Role badge
	var role_bg = ColorRect.new()
	role_bg.color = Color(col.r * 0.3, col.g * 0.3, col.b * 0.3)
	role_bg.size = Vector2(card_w, 22)
	role_bg.position = Vector2(0, 128)
	card.add_child(role_bg)

	var role_lbl = create_label(info["role"].to_upper(), Vector2(0, 131), 11, col)
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.custom_minimum_size = Vector2(card_w, 16)
	card.add_child(role_lbl)

	# Name
	var name_lbl = create_label(info["name"], Vector2(0, 158), 16, col)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.custom_minimum_size = Vector2(card_w, 22)
	card.add_child(name_lbl)

	# Divider
	var div = ColorRect.new()
	div.color = Color(col.r, col.g, col.b, 0.25)
	div.size = Vector2(card_w - 30, 1)
	div.position = Vector2(15, 184)
	card.add_child(div)

	# Stats bar HP
	var hp_label = create_label("HP", Vector2(15, 190), 10, Color(0.5, 0.7, 0.5))
	card.add_child(hp_label)

	var hp_bar_bg = ColorRect.new()
	hp_bar_bg.color = Color(0.1, 0.1, 0.1)
	hp_bar_bg.size = Vector2(card_w - 45, 8)
	hp_bar_bg.position = Vector2(35, 193)
	card.add_child(hp_bar_bg)

	var hp_fill = ColorRect.new()
	hp_fill.color = Color(0.2, 0.8, 0.3)
	hp_fill.size = Vector2((card_w - 45) * (info["hp"] / 160.0), 8)
	hp_fill.position = Vector2(35, 193)
	card.add_child(hp_fill)

	var hp_val = create_label(str(info["hp"]), Vector2(card_w - 38, 190), 10, Color(0.6, 0.9, 0.6))
	card.add_child(hp_val)

	# Stats bar SPD
	var spd_label = create_label("SPD", Vector2(15, 206), 10, Color(0.7, 0.6, 0.3))
	card.add_child(spd_label)

	var spd_bar_bg = ColorRect.new()
	spd_bar_bg.color = Color(0.1, 0.1, 0.1)
	spd_bar_bg.size = Vector2(card_w - 45, 8)
	spd_bar_bg.position = Vector2(35, 209)
	card.add_child(spd_bar_bg)

	var spd_fill = ColorRect.new()
	spd_fill.color = Color(0.9, 0.7, 0.2)
	spd_fill.size = Vector2((card_w - 45) * (info["speed"] / 100.0), 8)
	spd_fill.position = Vector2(35, 209)
	card.add_child(spd_fill)

	var spd_val = create_label(str(info["speed"]), Vector2(card_w - 38, 206), 10, Color(0.9, 0.8, 0.4))
	card.add_child(spd_val)

	# Divider 2
	var div2 = ColorRect.new()
	div2.color = Color(col.r, col.g, col.b, 0.2)
	div2.size = Vector2(card_w - 30, 1)
	div2.position = Vector2(15, 222)
	card.add_child(div2)

	# Moves
	var moves_header = create_label("MOVES", Vector2(15, 228), 10, Color(0.5, 0.7, 0.9))
	card.add_child(moves_header)

	for j in info["moves"].size():
		var move_dot = ColorRect.new()
		move_dot.color = col
		move_dot.size = Vector2(4, 4)
		move_dot.position = Vector2(15, 246 + j * 26)
		card.add_child(move_dot)

		var m_bg = ColorRect.new()
		m_bg.color = Color(col.r * 0.1, col.g * 0.1, col.b * 0.15)
		m_bg.size = Vector2(card_w - 30, 22)
		m_bg.position = Vector2(15, 242 + j * 26)
		card.add_child(m_bg)

		var m = create_label(info["moves"][j], Vector2(25, 246 + j * 26), 11, Color(0.8, 0.85, 0.9))
		card.add_child(m)

	# Click area
	var btn = Button.new()
	btn.size = Vector2(card_w, 360)
	btn.flat = true
	btn.modulate = Color(1, 1, 1, 0)
	btn.pressed.connect(func(): select_monster(card, info))
	card.add_child(btn)

	return card

func build_detail_panel() -> Node2D:
	var panel = Node2D.new()
	panel.position = Vector2(800, 190)

	var bg = ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.2, 0.97)
	bg.size = Vector2(340, 400)
	panel.add_child(bg)

	var border_top = ColorRect.new()
	border_top.color = Color(0.4, 0.6, 1)
	border_top.size = Vector2(340, 3)
	panel.add_child(border_top)

	var border_left = ColorRect.new()
	border_left.color = Color(0.4, 0.6, 1, 0.4)
	border_left.size = Vector2(3, 400)
	panel.add_child(border_left)

	var selected_title = create_label("— SELECTED SENTINEL —", Vector2(0, 12), 11, Color(0.5, 0.6, 0.8))
	selected_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_title.custom_minimum_size = Vector2(340, 18)
	panel.add_child(selected_title)

	detail_labels["title"] = create_label("???", Vector2(0, 32), 20, Color(0.4, 0.9, 1))
	detail_labels["title"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_labels["title"].custom_minimum_size = Vector2(340, 28)
	panel.add_child(detail_labels["title"])

	detail_labels["desc"] = create_label("", Vector2(15, 68), 11, Color(0.75, 0.75, 0.85))
	detail_labels["desc"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["desc"].custom_minimum_size = Vector2(310, 55)
	panel.add_child(detail_labels["desc"])

	var div1 = ColorRect.new()
	div1.color = Color(0.3, 0.3, 0.5, 0.4)
	div1.size = Vector2(310, 1)
	div1.position = Vector2(15, 128)
	panel.add_child(div1)

	panel.add_child(create_label("PASSIVE", Vector2(15, 135), 11, Color(1, 0.8, 0.3)))
	detail_labels["passive"] = create_label("", Vector2(15, 153), 11, Color(0.9, 0.85, 0.6))
	detail_labels["passive"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["passive"].custom_minimum_size = Vector2(310, 55)
	panel.add_child(detail_labels["passive"])

	var div2 = ColorRect.new()
	div2.color = Color(0.3, 0.3, 0.5, 0.4)
	div2.size = Vector2(310, 1)
	div2.position = Vector2(15, 213)
	panel.add_child(div2)

	panel.add_child(create_label("DOMAIN ADVANTAGE", Vector2(15, 220), 11, Color(0.4, 1, 0.4)))
	detail_labels["advantage"] = create_label("", Vector2(15, 238), 12, Color(0.7, 1, 0.7))
	detail_labels["advantage"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["advantage"].custom_minimum_size = Vector2(310, 45)
	panel.add_child(detail_labels["advantage"])

	var div3 = ColorRect.new()
	div3.color = Color(0.3, 0.3, 0.5, 0.4)
	div3.size = Vector2(310, 1)
	div3.position = Vector2(15, 288)
	panel.add_child(div3)

	panel.add_child(create_label("TIPS", Vector2(15, 295), 11, Color(0.5, 0.7, 1)))
	detail_labels["tips"] = create_label("", Vector2(15, 313), 11, Color(0.6, 0.7, 0.8))
	detail_labels["tips"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["tips"].custom_minimum_size = Vector2(310, 75)
	panel.add_child(detail_labels["tips"])

	return panel

var tips_map = {
	"encryp_pup": "Biarkan lawan menyerang duluan untuk stack defense, lalu balas dengan SSL Handshake saat sudah terbuff.",
	"ping_go": "Manfaatkan speed untuk debuff lawan duluan, lalu Ping Flood saat lawan sudah melambat.",
	"biti": "Gunakan Rootkit Hide untuk menghindari serangan besar, lalu Inject saat lawan sudah terdebuff.",
	"senti_shell": "Passive Redundancy memberimu satu nyawa ekstra. Jangan takut untuk bermain agresif di akhir.",
	"octo_core": "Fork Bomb sangat efektif untuk menghabiskan giliran lawan. Biarkan Kernel Panic menjadi senjata terakhir.",
	"chamele_auth": "Gunakan Pretexting untuk guaranteed hit, lalu ikuti dengan Social Override yang menembus defense.",
	"vaultex": "Jaga HP tetap genap untuk trigger Checksum heal. Mirror Backup bisa mencuri defense buff lawan.",
	"cipher_ray": "Key Exchange + Cipher Strike adalah combo mematikan vs lawan yang suka buffing defense.",
	"routerex": "Reroute sangat powerful untuk membalikkan debuff lawan. Gunakan saat sudah kena speed debuff.",
	"latencia": "Jitter passive bisa trigger double hit saat HP lawan kritis. QoS Drain sangat annoyng untuk lawan cepat.",
	"ransom_rex": "File Encrypt + Ransom Note memastikan lawan tidak bisa heal sambil kena DoT. Sangat mematikan vs tank.",
	"worm_ling": "Biarkan lawan menyerang untuk stack Self-Replicating. Mass Infection di stack 3 sangat mematikan.",
	"patchwork": "Zero-Day Shield adalah counter sempurna untuk serangan besar. Simpan untuk momen kritis.",
	"bastion": "DMZ passive mengabaikan damage kecil. Lawan multi-hit seperti Worm-Ling dan Ping-Go tidak akan efektif.",
	"daemon_x": "Kill Switch bisa one-shot di bawah 20% HP. Set up dengan Memory Leak + Daemon Spawn untuk DoT.",
	"bios_wraith": "BIOS Flash bisa reset semua buff saat lawan sudah stack tinggi. Timing adalah segalanya.",
	"vish_ara": "Vishing passive bisa membalikkan serangan besar lawan. Hypnotic Tone + Social Script untuk full control.",
	"bait_eel": "Honeypot passive punish lawan yang pakai move besar. Drive-by Download bypass defense sepenuhnya."
}

func select_monster(card: Node2D, info: Dictionary):
	selected_monster = info["id"]

	for c in card_nodes:
		var p = c.get_child(0)
		var s = p.get_theme_stylebox("panel").duplicate()
		s.border_width_top = 2
		s.border_width_bottom = 2
		s.border_width_left = 2
		s.border_width_right = 2
		s.border_color = Color(info["color"].r, info["color"].g, info["color"].b, 0.5)
		p.add_theme_stylebox_override("panel", s)

	var sel_panel = card.get_child(0)
	var sel_style = sel_panel.get_theme_stylebox("panel").duplicate()
	sel_style.border_width_top = 4
	sel_style.border_width_bottom = 4
	sel_style.border_width_left = 4
	sel_style.border_width_right = 4
	sel_style.border_color = info["color"]
	sel_panel.add_theme_stylebox_override("panel", sel_style)

	detail_labels["title"].text = info["name"]
	detail_labels["title"].add_theme_color_override("font_color", info["color"])
	detail_labels["desc"].text = info["desc"]
	detail_labels["passive"].text = passive_texts[info["id"]]
	detail_labels["advantage"].text = advantage_texts[info["id"]]
	detail_labels["tips"].text = tips_map[info["id"]]

	detail_panel.visible = true
	confirm_btn.visible = true
	confirm_btn.text = "⚔  Battle with " + info["name"] + "!"

func start_battle():
	if selected_monster == "":
		return
	var battle_scene = load("res://battle/Battle.tscn").instantiate()
	battle_scene.set_meta("player_monster", selected_monster)
	get_tree().root.add_child(battle_scene)
	get_tree().current_scene = battle_scene
	queue_free()

func spawn_particles():
	for i in 30:
		var p = ColorRect.new()
		var sz = randf_range(1.5, 3.5)
		p.size = Vector2(sz, sz)
		p.position = Vector2(randf_range(0, 1152), randf_range(0, 648))
		var brightness = randf_range(0.3, 0.7)
		p.color = Color(brightness * 0.4, brightness * 0.7, brightness, randf_range(0.2, 0.6))
		add_child(p)
		particles.append({
			"node": p,
			"vel": Vector2(randf_range(-12, 12), randf_range(-20, -6)),
			"base_alpha": randf_range(0.2, 0.6),
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
		var alpha = p["base_alpha"] + sin(time * 2.0 + p["phase"]) * 0.15
		p["node"].color.a = clamp(alpha, 0.05, 0.8)

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
	style.border_color = Color(0.3, 0.8, 0.4, 0.5)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.border_color = Color(0.4, 1, 0.5, 0.8)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
