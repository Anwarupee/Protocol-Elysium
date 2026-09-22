extends Node2D

# ══════════════════════════════════════════════
#  TheArchive.gd
#  Hub menu utama — 4 folder card visual (1920 x 1051)
#  Letakkan di: res://menus/archive/TheArchive.gd
# ══════════════════════════════════════════════

const SCREEN_W = 1920
const SCREEN_H = 1051

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

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		go_back()

func _process(delta):
	time += delta
	_animate(delta)

func _animate(_delta):
	var scan = find_child("header_scan", true, false)
	if scan:
		scan.color.a = 0.04 + sin(time * 1.2) * 0.02

func build_ui():
	card_nodes.clear()

	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(bg)

	# Noise grid
	for i in range(0, SCREEN_W, 48):
		var vl = ColorRect.new()
		vl.color = Color(1, 1, 1, 0.012)
		vl.size = Vector2(1, SCREEN_H)
		vl.position = Vector2(i, 0)
		add_child(vl)
	for i in range(0, SCREEN_H, 48):
		var hl = ColorRect.new()
		hl.color = Color(1, 1, 1, 0.012)
		hl.size = Vector2(SCREEN_W, 1)
		hl.position = Vector2(0, i)
		add_child(hl)

	# Scanlines overlay
	for i in range(0, SCREEN_H, 3):
		var sl = ColorRect.new()
		sl.color = Color(0, 0, 0, 0.04)
		sl.size = Vector2(SCREEN_W, 1)
		sl.position = Vector2(0, i)
		add_child(sl)

	# Diagonal accent kiri
	var diag = ColorRect.new()
	diag.color = Color(0.3, 0.7, 1.0, 0.04)
	diag.size = Vector2(900, SCREEN_H)
	diag.position = Vector2(-300, 0)
	diag.rotation = deg_to_rad(8)
	add_child(diag)

	# ── HEADER (Tinggi 90px) ──
	var hdr_h = 90
	var hdr_bg = ColorRect.new()
	hdr_bg.color = Color(0.06, 0.06, 0.16, 0.98)
	hdr_bg.size = Vector2(SCREEN_W, hdr_h)
	add_child(hdr_bg)

	var hdr_line = ColorRect.new()
	hdr_line.color = Color(0.3, 0.6, 1.0, 0.6)
	hdr_line.size = Vector2(SCREEN_W, 1)
	hdr_line.position = Vector2(0, hdr_h)
	add_child(hdr_line)

	var scan = ColorRect.new()
	scan.color = Color(0.3, 0.7, 1.0, 0.04)
	scan.size = Vector2(SCREEN_W, hdr_h)
	scan.name = "header_scan"
	add_child(scan)

	# Logo glyph & Judul
	var logo_glyph = _mk_label("▣", Vector2(32, 20), 42, Color(0.3, 0.75, 1.0, 0.9))
	add_child(logo_glyph)

	var title_lbl = _mk_label("THE  ARCHIVE", Vector2(90, 20), 32, Color(0.85, 0.9, 1.0))
	add_child(title_lbl)

	var sub_lbl = _mk_label("AETHER-NET INTELLIGENCE REPOSITORY  //  CLEARANCE REQUIRED", Vector2(90, 58), 12, Color(0.4, 0.5, 0.75))
	add_child(sub_lbl)

	# Status kanan
	var status_lbl = _mk_label("SYS: ONLINE  ◆  PROTOCOL-LINK v2.4  ◆  " + _timestamp(), Vector2(0, 24), 12, Color(0.3, 0.55, 0.4))
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_lbl.custom_minimum_size = Vector2(SCREEN_W - 32, 20)
	add_child(status_lbl)

	var status2 = _mk_label("SELECT A SECTION TO PROCEED", Vector2(0, 58), 12, Color(0.3, 0.4, 0.6))
	status2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status2.custom_minimum_size = Vector2(SCREEN_W - 32, 20)
	add_child(status2)

	# ── CARDS (360 x 720) ──
	var card_w = 360
	var card_h = 720
	var spacing = 40
	var total_w = 4 * card_w + 3 * spacing
	var start_x = (SCREEN_W - total_w) / 2
	
	var bot_h = 56
	var available_h = SCREEN_H - hdr_h - bot_h
	var card_y = hdr_h + (available_h - card_h) / 2

	for i in sections.size():
		var s = sections[i]
		var cx = start_x + i * (card_w + spacing)
		var card = _build_card(s, Vector2(cx, card_y), card_w, card_h, i)
		add_child(card)
		card_nodes.append(card)

	# ── BOTTOM BAR (Tinggi 56px) ──
	var bot_y = SCREEN_H - bot_h
	var bot_bg = ColorRect.new()
	bot_bg.color = Color(0.05, 0.05, 0.14, 0.98)
	bot_bg.size = Vector2(SCREEN_W, bot_h)
	bot_bg.position = Vector2(0, bot_y)
	add_child(bot_bg)

	var bot_line = ColorRect.new()
	bot_line.color = Color(0.2, 0.3, 0.6, 0.5)
	bot_line.size = Vector2(SCREEN_W, 1)
	bot_line.position = Vector2(0, bot_y)
	add_child(bot_line)

	var hint = _mk_label("[ CLICK ] OPEN SECTION    [ ESC / BACK ] RETURN TO MAIN MENU", Vector2(0, bot_y + 18), 13, Color(0.35, 0.4, 0.6))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.custom_minimum_size = Vector2(SCREEN_W, 20)
	add_child(hint)

	# ── BACK BUTTON ──
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(32, bot_y + 10)
	back_btn.size = Vector2(120, 36)
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var bs = StyleBoxFlat.new()
	bs.bg_color = Color(0.1, 0.1, 0.22)
	bs.border_color = Color(0.3, 0.4, 0.7, 0.5)
	bs.border_width_left = 1; bs.border_width_right = 1
	bs.border_width_top = 1; bs.border_width_bottom = 1
	bs.corner_radius_top_left = 4; bs.corner_radius_top_right = 4
	bs.corner_radius_bottom_left = 4; bs.corner_radius_bottom_right = 4
	
	var bsh = bs.duplicate()
	bsh.bg_color = Color(0.15, 0.15, 0.32)
	bsh.border_color = Color(0.4, 0.7, 1.0, 0.8)

	back_btn.add_theme_stylebox_override("normal", bs)
	back_btn.add_theme_stylebox_override("hover", bsh)
	back_btn.add_theme_font_size_override("font_size", 14)
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
	shadow.position = Vector2(6, 8)
	card.add_child(shadow)

	# Card background
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(dark.r, dark.g, dark.b, 0.97)
	card_style.border_color = Color(col.r, col.g, col.b, 0.35)
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.corner_radius_top_left = 6
	card_style.corner_radius_top_right = 6
	card_style.corner_radius_bottom_left = 6
	card_style.corner_radius_bottom_right = 6

	var panel = PanelContainer.new()
	panel.size = Vector2(w, h)
	panel.add_theme_stylebox_override("panel", card_style)
	card.add_child(panel)

	# Top color bar
	var top_bar = ColorRect.new()
	top_bar.color = col
	top_bar.size = Vector2(w, 4)
	card.add_child(top_bar)

	# Ilustrasi area
	var art_h = 380
	var art_bg = ColorRect.new()
	art_bg.color = Color(col.r * 0.08, col.g * 0.08, col.b * 0.08, 1.0)
	art_bg.size = Vector2(w, art_h)
	art_bg.position = Vector2(0, 4)
	card.add_child(art_bg)

	# Grid pattern
	for gx in range(0, w, 20):
		var gl = ColorRect.new()
		gl.color = Color(col.r, col.g, col.b, 0.04)
		gl.size = Vector2(1, art_h)
		gl.position = Vector2(gx, 4)
		card.add_child(gl)
	for gy in range(0, art_h, 20):
		var gl = ColorRect.new()
		gl.color = Color(col.r, col.g, col.b, 0.04)
		gl.size = Vector2(w, 1)
		gl.position = Vector2(0, 4 + gy)
		card.add_child(gl)

	# Glow circle
	var glow_outer = ColorRect.new()
	glow_outer.color = Color(col.r, col.g, col.b, 0.06)
	glow_outer.size = Vector2(260, 260)
	glow_outer.position = Vector2((w - 260) / 2, 4 + (art_h - 260) / 2)
	card.add_child(glow_outer)

	var glow_mid = ColorRect.new()
	glow_mid.color = Color(col.r, col.g, col.b, 0.08)
	glow_mid.size = Vector2(180, 180)
	glow_mid.position = Vector2((w - 180) / 2, 4 + (art_h - 180) / 2)
	card.add_child(glow_mid)

	var glow_inner = ColorRect.new()
	glow_inner.color = Color(col.r, col.g, col.b, 0.12)
	glow_inner.size = Vector2(100, 100)
	glow_inner.position = Vector2((w - 100) / 2, 4 + (art_h - 100) / 2)
	card.add_child(glow_inner)

	# Glyph besar
	var glyph_lbl = _mk_label(s["glyph"], Vector2(0, 4 + (art_h - 100) / 2), 96, Color(col.r, col.g, col.b, 0.9 if not is_locked else 0.3))
	glyph_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_lbl.custom_minimum_size = Vector2(w, 100)
	card.add_child(glyph_lbl)

	if is_locked:
		var lock_overlay = ColorRect.new()
		lock_overlay.color = Color(0, 0, 0, 0.5)
		lock_overlay.size = Vector2(w, art_h)
		lock_overlay.position = Vector2(0, 4)
		card.add_child(lock_overlay)

		var lock_lbl = _mk_label("🔒", Vector2(0, 4 + (art_h - 60) / 2), 48, Color(0.5, 0.5, 0.6))
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_lbl.custom_minimum_size = Vector2(w, 60)
		card.add_child(lock_lbl)

	# Index tag
	var idx_lbl = _mk_label("0" + str(idx + 1), Vector2(w - 40, 16), 14, Color(col.r, col.g, col.b, 0.4))
	card.add_child(idx_lbl)

	# Divider
	var divider = ColorRect.new()
	divider.color = Color(col.r, col.g, col.b, 0.3)
	divider.size = Vector2(w, 1)
	divider.position = Vector2(0, art_h + 4)
	card.add_child(divider)

	# ── INFO AREA ──
	var info_y = art_h + 16

	var type_bg = ColorRect.new()
	type_bg.color = Color(col.r, col.g, col.b, 0.15)
	type_bg.size = Vector2(w - 32, 24)
	type_bg.position = Vector2(16, info_y)
	card.add_child(type_bg)

	var type_accent = ColorRect.new()
	type_accent.color = col
	type_accent.size = Vector2(4, 24)
	type_accent.position = Vector2(16, info_y)
	card.add_child(type_accent)

	var type_lbl = _mk_label(s["label"], Vector2(28, info_y + 3), 11, Color(col.r, col.g, col.b, 0.9))
	card.add_child(type_lbl)

	info_y += 36

	var title_lbl = _mk_label(s["title"], Vector2(16, info_y), 20, Color(0.9, 0.93, 1.0))
	card.add_child(title_lbl)
	info_y += 30

	var sub_lbl = _mk_label(s["subtitle"], Vector2(16, info_y), 13, Color(col.r * 0.8, col.g * 0.8, col.b * 0.8))
	card.add_child(sub_lbl)
	info_y += 26

	var d2 = ColorRect.new()
	d2.color = Color(col.r, col.g, col.b, 0.15)
	d2.size = Vector2(w - 32, 1)
	d2.position = Vector2(16, info_y)
	card.add_child(d2)
	info_y += 16

	var desc_lbl = _mk_label(s["desc"], Vector2(16, info_y), 13, Color(0.6, 0.65, 0.75))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.custom_minimum_size = Vector2(w - 32, 0)
	card.add_child(desc_lbl)

	var tag_lbl = _mk_label(s["tag"], Vector2(16, h - 50), 12, Color(col.r, col.g, col.b, 0.7 if not is_locked else 0.3))
	card.add_child(tag_lbl)

	var arrow = _mk_label("→" if not is_locked else "—", Vector2(w - 36, h - 50), 18, Color(col.r, col.g, col.b, 0.7))
	card.add_child(arrow)

	var bot_card = ColorRect.new()
	bot_card.color = Color(col.r, col.g, col.b, 0.08)
	bot_card.size = Vector2(w, 40)
	bot_card.position = Vector2(0, h - 40)
	card.add_child(bot_card)

	# ── INVISIBLE HOVER & CLICK BUTTON ──
	if not is_locked:
		var btn = Button.new()
		btn.size = Vector2(w, h)
		btn.flat = true
		btn.modulate = Color(1, 1, 1, 0)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var scene_path = s["scene"]
		var style_ref = card_style
		var col_ref = col

		btn.mouse_entered.connect(func():
			style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.9)
			style_ref.border_width_left = 2
			style_ref.border_width_right = 2
			style_ref.border_width_top = 2
			style_ref.border_width_bottom = 2
			panel.add_theme_stylebox_override("panel", style_ref)
			
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(card, "position:y", pos.y - 10, 0.15)
		)
		
		btn.mouse_exited.connect(func():
			style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.35)
			style_ref.border_width_left = 1
			style_ref.border_width_right = 1
			style_ref.border_width_top = 1
			style_ref.border_width_bottom = 1
			panel.add_theme_stylebox_override("panel", style_ref)
			
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(card, "position:y", pos.y, 0.15)
		)
		
		btn.pressed.connect(func(): open_section(scene_path))
		card.add_child(btn)
	else:
		var lock_style = card_style.duplicate()
		lock_style.bg_color = Color(0.07, 0.07, 0.1, 0.97)
		panel.add_theme_stylebox_override("panel", lock_style)

	return card

func open_section(scene_path: String):
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		push_warning("TheArchive: Scene path tidak valid atau file tidak ditemukan -> " + scene_path)
		return
	SceneManager.goto_menu(scene_path)

func go_back():
	var main_menu_path = "res://menus/main_menu/MainMenu.tscn"
	if ResourceLoader.exists(main_menu_path):
		SceneManager.goto_menu(main_menu_path)

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
