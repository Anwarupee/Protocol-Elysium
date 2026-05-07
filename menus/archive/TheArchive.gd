extends Node2D

# ══════════════════════════════════════════════
#  TheArchive.gd
#  Hub menu utama — 4 folder card visual
#  Letakkan di: res://menus/archive/TheArchive.gd
# ══════════════════════════════════════════════

var time: float = 0.0
var card_nodes: Array = []
var hover_idx: int = -1

# Data tiap card
var sections = [
	{
		"id": "sentinel",
		"title": "DATA SENTINEL",
		"subtitle": "Sentinel Registry",
		"desc": "Katalog lengkap seluruh Sentinel yang terdaftar di Aether-Net. Stats, tipe, kemampuan, dan lore asal-usul mereka.",
		"tag": "28 ENTRIES",
		"scene": "res://menus/cyberdex/CyberDex.tscn",
		"color_main": Color(0.3, 0.75, 1.0),
		"color_dark": Color(0.05, 0.1, 0.25),
		"glyph": "◈",
		"label": "POKEDEX-STYLE"
	},
	{
		"id": "knowledge",
		"title": "KNOWLEDGE BASE",
		"subtitle": "Cyber Intelligence",
		"desc": "Ensiklopedia teknis keamanan siber. Dari dasar Malware hingga arsitektur Zero Trust — ditulis untuk dipahami, bukan dihapal.",
		"tag": "12 ARTICLES",
		"scene": "res://menus/knowledge/KnowledgeBase.tscn",
		"color_main": Color(0.4, 1.0, 0.6),
		"color_dark": Color(0.04, 0.18, 0.08),
		"glyph": "◉",
		"label": "WIKI-STYLE"
	},
	{
		"id": "field",
		"title": "FIELD REPORTS",
		"subtitle": "Classified Transmissions",
		"desc": "Catatan lapangan, surat terakhir, dan log yang terpotong dari garis depan Aether-Net. Beberapa tidak pernah mencapai tujuannya.",
		"tag": "9 DOCUMENTS",
		"scene": "res://menus/field_reports/FieldReports.tscn",
		"color_main": Color(1.0, 0.7, 0.25),
		"color_dark": Color(0.2, 0.1, 0.02),
		"glyph": "◧",
		"label": "NieR-STYLE"
	},
	{
		"id": "classified",
		"title": "???",
		"subtitle": "Access Restricted",
		"desc": "File ini dikunci di balik lapisan enkripsi yang belum terpecahkan. Seseorang menyembunyikan sesuatu di sini.",
		"tag": "LOCKED",
		"scene": "",
		"color_main": Color(0.5, 0.5, 0.6),
		"color_dark": Color(0.08, 0.08, 0.12),
		"glyph": "◫",
		"label": "COMING SOON"
	}
]

func _ready():
	build_ui()

func _process(delta):
	time += delta
	_animate(delta)

func _animate(_delta):
	# Pulse glow pada scanline
	var scan = find_child("header_scan", true, false)
	if scan:
		scan.color.a = 0.04 + sin(time * 1.2) * 0.02

func build_ui():
	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Noise grid
	for i in range(0, 1152, 48):
		var vl = ColorRect.new()
		vl.color = Color(1, 1, 1, 0.012)
		vl.size = Vector2(1, 648)
		vl.position = Vector2(i, 0)
		add_child(vl)
	for i in range(0, 648, 48):
		var hl = ColorRect.new()
		hl.color = Color(1, 1, 1, 0.012)
		hl.size = Vector2(1152, 1)
		hl.position = Vector2(0, i)
		add_child(hl)

	# Scanlines overlay
	for i in range(0, 648, 3):
		var sl = ColorRect.new()
		sl.color = Color(0, 0, 0, 0.04)
		sl.size = Vector2(1152, 1)
		sl.position = Vector2(0, i)
		add_child(sl)

	# Diagonal accent kiri
	var diag = ColorRect.new()
	diag.color = Color(0.3, 0.7, 1.0, 0.04)
	diag.size = Vector2(600, 648)
	diag.position = Vector2(-200, 0)
	diag.rotation = deg_to_rad(8)
	add_child(diag)

	# ── HEADER ──
	var hdr_bg = ColorRect.new()
	hdr_bg.color = Color(0.06, 0.06, 0.16, 0.98)
	hdr_bg.size = Vector2(1152, 80)
	add_child(hdr_bg)

	var hdr_line = ColorRect.new()
	hdr_line.color = Color(0.3, 0.6, 1.0, 0.6)
	hdr_line.size = Vector2(1152, 1)
	hdr_line.position = Vector2(0, 80)
	add_child(hdr_line)

	# Header scan animasi
	var scan = ColorRect.new()
	scan.color = Color(0.3, 0.7, 1.0, 0.04)
	scan.size = Vector2(1152, 80)
	scan.name = "header_scan"
	add_child(scan)

	# Logo glyph kiri
	var logo_glyph = _mk_label("▣", Vector2(24, 16), 36, Color(0.3, 0.75, 1.0, 0.9))
	add_child(logo_glyph)

	# Judul
	var title_lbl = _mk_label("THE  ARCHIVE", Vector2(72, 18), 28, Color(0.85, 0.9, 1.0))
	add_child(title_lbl)

	var sub_lbl = _mk_label("AETHER-NET INTELLIGENCE REPOSITORY  //  CLEARANCE REQUIRED", Vector2(72, 52), 10, Color(0.4, 0.5, 0.75))
	add_child(sub_lbl)

	# Status kanan
	var status_lbl = _mk_label("SYS: ONLINE  ◆  PROTOCOL-LINK v2.4  ◆  " + _timestamp(), Vector2(0, 20), 10, Color(0.3, 0.55, 0.4))
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_lbl.custom_minimum_size = Vector2(1130, 20)
	add_child(status_lbl)

	var status2 = _mk_label("SELECT A SECTION TO PROCEED", Vector2(0, 54), 10, Color(0.3, 0.4, 0.6))
	status2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status2.custom_minimum_size = Vector2(1130, 20)
	add_child(status2)

	# ── CARDS ──
	var card_w = 240
	var card_h = 460
	var spacing = 20
	var total_w = 4 * card_w + 3 * spacing
	var start_x = (1152 - total_w) / 2
	var card_y = 115

	for i in sections.size():
		var s = sections[i]
		var cx = start_x + i * (card_w + spacing)
		var card = _build_card(s, Vector2(cx, card_y), card_w, card_h, i)
		add_child(card)
		card_nodes.append(card)

	# ── BOTTOM BAR ──
	var bot_bg = ColorRect.new()
	bot_bg.color = Color(0.05, 0.05, 0.14, 0.98)
	bot_bg.size = Vector2(1152, 48)
	bot_bg.position = Vector2(0, 600)
	add_child(bot_bg)

	var bot_line = ColorRect.new()
	bot_line.color = Color(0.2, 0.3, 0.6, 0.5)
	bot_line.size = Vector2(1152, 1)
	bot_line.position = Vector2(0, 600)
	add_child(bot_line)

	var hint = _mk_label("[ CLICK ] OPEN SECTION    [ ESC / BACK ] RETURN TO MAIN MENU", Vector2(0, 616), 11, Color(0.35, 0.4, 0.6))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.custom_minimum_size = Vector2(1152, 20)
	add_child(hint)

	# ── BACK BUTTON ──
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(20, 610)
	back_btn.size = Vector2(100, 30)
	var bs = StyleBoxFlat.new()
	bs.bg_color = Color(0.1, 0.1, 0.22)
	bs.border_color = Color(0.3, 0.4, 0.7, 0.5)
	bs.border_width_left = 1; bs.border_width_right = 1
	bs.border_width_top = 1; bs.border_width_bottom = 1
	bs.corner_radius_top_left = 4; bs.corner_radius_top_right = 4
	bs.corner_radius_bottom_left = 4; bs.corner_radius_bottom_right = 4
	var bsh = bs.duplicate()
	bsh.bg_color = Color(0.15, 0.15, 0.32)
	back_btn.add_theme_stylebox_override("normal", bs)
	back_btn.add_theme_stylebox_override("hover", bsh)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	back_btn.pressed.connect(go_back)
	add_child(back_btn)

func _build_card(s: Dictionary, pos: Vector2, w: int, h: int, idx: int) -> Node2D:
	var card = Node2D.new()
	card.position = pos
	var col = s["color_main"]
	var dark = s["color_dark"]
	var is_locked = s["scene"] == ""

	# Shadow
	var shadow = ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.5)
	shadow.size = Vector2(w, h)
	shadow.position = Vector2(4, 6)
	card.add_child(shadow)

	# Card background
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(dark.r, dark.g, dark.b, 0.97)
	card_style.border_color = Color(col.r, col.g, col.b, 0.35)
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.corner_radius_top_left = 4
	card_style.corner_radius_top_right = 4
	card_style.corner_radius_bottom_left = 4
	card_style.corner_radius_bottom_right = 4
	var panel = PanelContainer.new()
	panel.size = Vector2(w, h)
	panel.add_theme_stylebox_override("panel", card_style)
	card.add_child(panel)

	# Top color bar
	var top_bar = ColorRect.new()
	top_bar.color = col
	top_bar.size = Vector2(w, 3)
	card.add_child(top_bar)

	# Ilustrasi area (visual block besar di atas)
	var art_bg = ColorRect.new()
	art_bg.color = Color(col.r * 0.08, col.g * 0.08, col.b * 0.08, 1.0)
	art_bg.size = Vector2(w, 240)
	art_bg.position = Vector2(0, 3)
	card.add_child(art_bg)

	# Grid pattern di art area
	for gx in range(0, w, 16):
		var gl = ColorRect.new()
		gl.color = Color(col.r, col.g, col.b, 0.04)
		gl.size = Vector2(1, 240)
		gl.position = Vector2(gx, 3)
		card.add_child(gl)
	for gy in range(0, 240, 16):
		var gl = ColorRect.new()
		gl.color = Color(col.r, col.g, col.b, 0.04)
		gl.size = Vector2(w, 1)
		gl.position = Vector2(0, 3 + gy)
		card.add_child(gl)

	# Glow circle di tengah art area
	var glow_outer = ColorRect.new()
	glow_outer.color = Color(col.r, col.g, col.b, 0.06)
	glow_outer.size = Vector2(180, 180)
	glow_outer.position = Vector2((w - 180) / 2, 3 + 30)
	card.add_child(glow_outer)
	var glow_mid = ColorRect.new()
	glow_mid.color = Color(col.r, col.g, col.b, 0.08)
	glow_mid.size = Vector2(120, 120)
	glow_mid.position = Vector2((w - 120) / 2, 3 + 60)
	card.add_child(glow_mid)
	var glow_inner = ColorRect.new()
	glow_inner.color = Color(col.r, col.g, col.b, 0.12)
	glow_inner.size = Vector2(60, 60)
	glow_inner.position = Vector2((w - 60) / 2, 3 + 90)
	card.add_child(glow_inner)

	# Glyph besar di tengah art
	var glyph_lbl = _mk_label(s["glyph"], Vector2(0, 90), 64, Color(col.r, col.g, col.b, 0.9 if not is_locked else 0.3))
	glyph_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_lbl.custom_minimum_size = Vector2(w, 80)
	card.add_child(glyph_lbl)

	# Lock overlay untuk card locked
	if is_locked:
		var lock_overlay = ColorRect.new()
		lock_overlay.color = Color(0, 0, 0, 0.5)
		lock_overlay.size = Vector2(w, 240)
		lock_overlay.position = Vector2(0, 3)
		card.add_child(lock_overlay)
		var lock_lbl = _mk_label("🔒", Vector2(0, 100), 32, Color(0.5, 0.5, 0.6))
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_lbl.custom_minimum_size = Vector2(w, 40)
		card.add_child(lock_lbl)

	# Corner tag (nomor index)
	var idx_lbl = _mk_label("0" + str(idx + 1), Vector2(w - 30, 10), 11, Color(col.r, col.g, col.b, 0.4))
	card.add_child(idx_lbl)

	# Divider antara art dan info
	var divider = ColorRect.new()
	divider.color = Color(col.r, col.g, col.b, 0.3)
	divider.size = Vector2(w, 1)
	divider.position = Vector2(0, 243)
	card.add_child(divider)

	# ── INFO AREA di bawah art ──
	var info_y = 252

	# Label type (tag kecil)
	var type_bg = ColorRect.new()
	type_bg.color = Color(col.r, col.g, col.b, 0.15)
	type_bg.size = Vector2(w - 24, 18)
	type_bg.position = Vector2(12, info_y)
	card.add_child(type_bg)
	var type_accent = ColorRect.new()
	type_accent.color = col
	type_accent.size = Vector2(3, 18)
	type_accent.position = Vector2(12, info_y)
	card.add_child(type_accent)
	var type_lbl = _mk_label(s["label"], Vector2(20, info_y + 2), 9, Color(col.r, col.g, col.b, 0.9))
	card.add_child(type_lbl)

	info_y += 26

	# Judul section
	var title_lbl = _mk_label(s["title"], Vector2(12, info_y), 15, Color(0.9, 0.93, 1.0))
	card.add_child(title_lbl)
	info_y += 22

	# Subtitle
	var sub_lbl = _mk_label(s["subtitle"], Vector2(12, info_y), 10, Color(col.r * 0.8, col.g * 0.8, col.b * 0.8))
	card.add_child(sub_lbl)
	info_y += 20

	# Divider tipis
	var d2 = ColorRect.new()
	d2.color = Color(col.r, col.g, col.b, 0.15)
	d2.size = Vector2(w - 24, 1)
	d2.position = Vector2(12, info_y)
	card.add_child(d2)
	info_y += 10

	# Deskripsi
	var desc_lbl = _mk_label(s["desc"], Vector2(12, info_y), 10, Color(0.6, 0.65, 0.75))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.custom_minimum_size = Vector2(w - 24, 0)
	card.add_child(desc_lbl)

	# Tag jumlah entry (bawah)
	var tag_lbl = _mk_label(s["tag"], Vector2(12, h - 36), 10, Color(col.r, col.g, col.b, 0.7 if not is_locked else 0.3))
	card.add_child(tag_lbl)

	# Arrow indicator
	var arrow = _mk_label("→" if not is_locked else "—", Vector2(w - 28, h - 36), 14, Color(col.r, col.g, col.b, 0.7))
	card.add_child(arrow)

	# Bottom bar card
	var bot_card = ColorRect.new()
	bot_card.color = Color(col.r, col.g, col.b, 0.08)
	bot_card.size = Vector2(w, 30)
	bot_card.position = Vector2(0, h - 30)
	card.add_child(bot_card)

	# ── INVISIBLE BUTTON ──
	if not is_locked:
		var btn = Button.new()
		btn.size = Vector2(w, h)
		btn.flat = true
		btn.modulate = Color(1, 1, 1, 0)
		var scene_path = s["scene"]
		var card_ref = card
		var style_ref = card_style
		var col_ref = col

		btn.mouse_entered.connect(func():
			style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.9)
			style_ref.border_width_left = 2
			style_ref.border_width_right = 2
			style_ref.border_width_top = 2
			style_ref.border_width_bottom = 2
			panel.add_theme_stylebox_override("panel", style_ref)
		)
		btn.mouse_exited.connect(func():
			style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.35)
			style_ref.border_width_left = 1
			style_ref.border_width_right = 1
			style_ref.border_width_top = 1
			style_ref.border_width_bottom = 1
			panel.add_theme_stylebox_override("panel", style_ref)
		)
		btn.pressed.connect(func(): open_section(scene_path))
		card.add_child(btn)
	else:
		# Locked card — cursor not-allowed feel via different styling
		var lock_style = card_style.duplicate()
		lock_style.bg_color = Color(0.07, 0.07, 0.1, 0.97)
		panel.add_theme_stylebox_override("panel", lock_style)

	return card

func open_section(scene_path: String):
	if scene_path == "":
		return
	var scene = load(scene_path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func go_back():
	var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func _timestamp() -> String:
	var t = Time.get_datetime_dict_from_system()
	return "%04d.%02d.%02d  %02d:%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"]]

func _mk_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l
