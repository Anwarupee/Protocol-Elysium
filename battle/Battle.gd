extends Node2D

const DEBUG_FILE = "battle.gd v4 — 1920x1080 native"

@onready var battle_manager = $BattleManager
var edu_popup = null

var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_hp_label: Label
var player_name_label: Label
var enemy_name_label: Label
var battle_log_label: Label
var move_buttons: Array = []
var battle_active: bool = true
var player_monster_moves: Array = []
var edu_scroll: ScrollContainer
var edu_vbox: VBoxContainer
var screen_shake_intensity: float = 0.0
var original_position: Vector2

var item_panel_node = null
var flee_btn: Button
var item_btn: Button
var catch_btn: Button
var enemy_id: String = ""

# ══════════════════════════════════════════════════════════
# Layout constants — semua koordinat 1920×1080 native
# ══════════════════════════════════════════════════════════
# Zone pembagian layar:
#   Kiri bawah  (0–660, 530–900)   : panel player
#   Kanan atas  (960–1660, 30–230) : panel enemy
#   Kiri tengah (0–660, 900–1080)  : battle log + edu log
#   Kanan tengah(700–1920, 700–1080): move buttons + action buttons
#   Tengah atas : arena (sprite battle)

const PANEL_W    = 620   # lebar panel info
const HP_BAR_W   = 560
const MOVE_BTN_W = 290
const MOVE_BTN_H = 72
const ACT_BTN_W  = 180
const ACT_BTN_H  = 52

# Player panel: pojok kiri bawah
const PP_X = 50;  const PP_Y = 540
# Enemy panel: pojok kanan atas
const EP_X = 960; const EP_Y = 30
# Move buttons: kanan bawah 2×2
const MB_X1 = 960;  const MB_X2 = 1270
const MB_Y1 = 720;  const MB_Y2 = 805
# Action buttons (flee/item/catch): baris di bawah move buttons
const AB_Y = 895

func _ready():
	original_position = position
	edu_popup = get_node_or_null("EduPopup")

	# Baca dari GlobalData — tidak ada root meta lagi
	var player_choice = GlobalData.get_active_monster_id()
	if GlobalData.pending_sentinel != "":
		player_choice = GlobalData.pending_sentinel
		GlobalData.pending_sentinel = ""

	var all_monsters = [
		"encryp_pup","ping_go","biti","senti_shell","octo_core","chamele_auth",
		"vaultex","cipher_ray","routerex","latencia","ransom_rex","worm_ling",
		"patchwork","bastion","daemon_x","bios_wraith","vish_ara","bait_eel",
		"hash_hound","key_lynx","signal_snail","warp_wolf","login_leech",
		"trojan_taurus","brick_bear","gate_gorilla","phish_falcon","scam_serpent",
		"sentry_stinger","radar_rhino"
	]
	all_monsters.erase(player_choice)
	var enemy_choice = all_monsters[randi() % all_monsters.size()]
	# Pakai enemy dari EncounterZone kalau ada
	if GlobalData.encounter_enemy != "":
		enemy_choice = GlobalData.encounter_enemy
	enemy_id = enemy_choice

	battle_manager.load_monsters()
	var player_data = battle_manager.get_monster_data(player_choice)
	var enemy_data  = battle_manager.get_monster_data(enemy_choice)
	if player_data.is_empty() or enemy_data.is_empty():
		push_error("Monster data not found!"); return

	build_ui(player_data, enemy_data)
	connect_signals()
	battle_manager.start_battle(player_choice, enemy_choice)
	await play_intro_animation()

func _process(_delta):
	if screen_shake_intensity > 0:
		screen_shake_intensity = lerp(screen_shake_intensity, 0.0, 0.2)
		position = original_position + Vector2(
			randf_range(-screen_shake_intensity, screen_shake_intensity),
			randf_range(-screen_shake_intensity, screen_shake_intensity)
		)
		if screen_shake_intensity < 0.5:
			position = original_position
			screen_shake_intensity = 0.0

func trigger_screen_shake(intensity: float): screen_shake_intensity = intensity

# ════════════════════════════════════════════
# ── VFX ──
# ════════════════════════════════════════════

func spawn_hit_particles(pos: Vector2, color: Color, count: int = 14):
	for i in count:
		var p = ColorRect.new()
		var sz = randf_range(4, 10)
		p.size = Vector2(sz, sz)
		p.color = Color(color.r, color.g, color.b, 0.9)
		p.position = pos + Vector2(randf_range(-25, 25), randf_range(-25, 25))
		add_child(p)
		var vel = Vector2(randf_range(-150, 150), randf_range(-180, -40))
		var lt  = randf_range(0.3, 0.7)
		var tw  = create_tween(); tw.set_parallel(true)
		tw.tween_property(p, "position", p.position + vel * lt, lt)
		tw.tween_property(p, "modulate:a", 0.0, lt)
		get_tree().create_timer(lt).timeout.connect(func(): if is_instance_valid(p): p.queue_free())

func spawn_slash_effect(pos: Vector2, color: Color, is_player: bool):
	for i in 3:
		var slash = ColorRect.new()
		slash.color = Color(color.r, color.g, color.b, 0.8)
		var dir = 1 if is_player else -1
		slash.size = Vector2(80 + i * 20, 5 - i)
		slash.rotation = deg_to_rad(-30 + i * 20)
		slash.position = pos + Vector2(dir * (i * 14 - 14), -12 + i * 18)
		add_child(slash)
		var tw = create_tween(); tw.set_parallel(true)
		tw.tween_property(slash, "modulate:a", 0.0, 0.25)
		tw.tween_property(slash, "position", slash.position + Vector2(dir * 50, -25), 0.25)
		get_tree().create_timer(0.3).timeout.connect(func(): if is_instance_valid(slash): slash.queue_free())

func spawn_impact_flash(pos: Vector2, _color: Color):
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.5)
	flash.size = Vector2(100, 100)
	flash.position = pos - Vector2(50, 50)
	add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "size", Vector2(200, 200), 0.1)
	tw.tween_property(flash, "modulate:a", 0.0, 0.15)
	get_tree().create_timer(0.3).timeout.connect(func(): if is_instance_valid(flash): flash.queue_free())

func animate_attack(is_player: bool):
	var sname = "player_sprite" if is_player else "enemy_sprite"
	var tname = "enemy_sprite"  if is_player else "player_sprite"
	var sprite = find_child(sname, true, false)
	var target = find_child(tname, true, false)
	if sprite == null or target == null: return

	var orig = sprite.position
	var dir  = Vector2(150, -25) if is_player else Vector2(-150, 25)
	var tpos = target.position

	var tw1 = create_tween()
	tw1.tween_property(sprite, "position", orig - dir * 0.3, 0.1)
	await tw1.finished
	var tw2 = create_tween(); tw2.set_parallel(true)
	tw2.tween_property(sprite, "position", orig + dir, 0.12).set_trans(Tween.TRANS_EXPO)
	await tw2.finished

	spawn_slash_effect(tpos, Color.WHITE, is_player)
	spawn_impact_flash(tpos, Color.WHITE)
	trigger_screen_shake(7.0)

	var ft = create_tween()
	ft.tween_property(target, "modulate", Color(2, 0.3, 0.3), 0.06)
	ft.tween_property(target, "modulate", Color(1, 1, 1), 0.06)
	ft.tween_property(target, "modulate", Color(2, 0.3, 0.3), 0.06)
	ft.tween_property(target, "modulate", Color(1, 1, 1), 0.08)

	var to = target.position
	var st = create_tween()
	st.tween_property(target, "position", to + Vector2(10, -5), 0.05)
	st.tween_property(target, "position", to + Vector2(-10, 5), 0.05)
	st.tween_property(target, "position", to + Vector2(6, -3), 0.04)
	st.tween_property(target, "position", to, 0.04)

	spawn_hit_particles(tpos, Color(1, 0.4, 0.4))
	await get_tree().create_timer(0.15).timeout
	var tw3 = create_tween()
	tw3.tween_property(sprite, "position", orig, 0.2).set_trans(Tween.TRANS_BACK)

func play_intro_animation():
	battle_active = false
	set_all_buttons_disabled(true)
	var ps = find_child("player_sprite", true, false)
	var es = find_child("enemy_sprite",  true, false)
	if ps == null or es == null:
		battle_active = true; set_all_buttons_disabled(false); return

	var po = ps.position; var eo = es.position
	ps.position = Vector2(-300, po.y); es.position = Vector2(2100, eo.y)
	ps.modulate.a = 0.0;               es.modulate.a = 0.0
	battle_log_label.text = ""

	var ft = create_tween(); ft.set_parallel(true)
	ft.tween_property(ps, "modulate:a", 1.0, 0.3)
	ft.tween_property(es, "modulate:a", 1.0, 0.3)
	await ft.finished
	battle_log_label.text = "A wild " + es.get_meta("monster_name", "Enemy") + " appeared!"

	var tw = create_tween(); tw.set_parallel(true)
	tw.tween_property(ps, "position", po, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(es, "position", eo, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tw.finished
	trigger_screen_shake(5.0)
	spawn_hit_particles(ps.position, Color(0.4, 0.8, 1.0), 8)
	spawn_hit_particles(es.position, Color.WHITE, 8)
	await get_tree().create_timer(0.5).timeout

	var vs = create_label("⚔ VS ⚔", Vector2(0, 430), 52, Color(1, 0.9, 0.2))
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs.custom_minimum_size  = Vector2(1920, 70)
	vs.modulate.a = 0.0
	add_child(vs)
	var vt = create_tween()
	vt.tween_property(vs, "modulate:a", 1.0, 0.2)
	vt.tween_property(vs, "modulate:a", 0.0, 0.5)
	await vt.finished; vs.queue_free()

	battle_log_label.text = "Battle Start!"
	battle_active = true
	set_all_buttons_disabled(false)

# ════════════════════════════════════════════
# ── BUILD UI  (1920×1080 native) ──
# ════════════════════════════════════════════

func build_ui(player_data: Dictionary, enemy_data: Dictionary):
	# ── Backgrounds ──
	var sky = ColorRect.new(); sky.color = Color(0.08, 0.08, 0.25); sky.size = Vector2(1920, 1080); add_child(sky)
	var far = ColorRect.new(); far.color = Color(0.12, 0.15, 0.35); far.size = Vector2(1920, 520); add_child(far)
	var hor = ColorRect.new(); hor.color = Color(0.2, 0.3, 0.6, 0.3); hor.size = Vector2(1920, 55); hor.position = Vector2(0, 480); add_child(hor)
	var near= ColorRect.new(); near.color= Color(0.05, 0.06, 0.18); near.size = Vector2(1920, 545); near.position = Vector2(0, 535); add_child(near)

	# ── ENEMY PANEL (kanan atas) ──
	var ec = get_type_color(enemy_data["type"])
	add_child(create_panel(Vector2(EP_X, EP_Y), Vector2(PANEL_W, 195), ec))
	enemy_name_label = create_label(enemy_data["name"], Vector2(EP_X+20, EP_Y+18), 30, ec)
	add_child(enemy_name_label)
	var etb = ColorRect.new(); etb.color = Color(ec.r,ec.g,ec.b,0.2); etb.size = Vector2(160,28); etb.position = Vector2(EP_X+20, EP_Y+56); add_child(etb)
	add_child(create_label("  "+enemy_data["type"], Vector2(EP_X+20, EP_Y+56), 18, ec))
	enemy_hp_bar = create_hp_bar(Vector2(EP_X+20, EP_Y+100), HP_BAR_W, Color(1,0.3,0.3))
	add_child(enemy_hp_bar)
	enemy_hp_label = create_label("HP: "+str(enemy_data["hp"])+"/"+str(enemy_data["hp"]), Vector2(EP_X+20, EP_Y+130), 18, Color(0.9,0.9,0.9))
	add_child(enemy_hp_label)

	# ── PLAYER PANEL (kiri bawah) ──
	var pc = get_type_color(player_data["type"])
	add_child(create_panel(Vector2(PP_X, PP_Y), Vector2(PANEL_W, 195), pc))
	player_name_label = create_label(player_data["name"], Vector2(PP_X+20, PP_Y+18), 30, pc)
	add_child(player_name_label)
	var ptb = ColorRect.new(); ptb.color = Color(pc.r,pc.g,pc.b,0.2); ptb.size = Vector2(160,28); ptb.position = Vector2(PP_X+20, PP_Y+56); add_child(ptb)
	add_child(create_label("  "+player_data["type"], Vector2(PP_X+20, PP_Y+56), 18, pc))
	player_hp_bar = create_hp_bar(Vector2(PP_X+20, PP_Y+100), HP_BAR_W, Color(0.2,0.8,0.4))
	add_child(player_hp_bar)
	player_hp_label = create_label("HP: "+str(player_data["hp"])+"/"+str(player_data["hp"]), Vector2(PP_X+20, PP_Y+130), 18, Color(0.9,0.9,0.9))
	add_child(player_hp_label)
	# Type advantage hint
	var adv_map = {
		"Crypto": "⚡ Kuat vs Malware  |  ⚠ Lemah vs Network",
		"Network": "⚡ Kuat vs Crypto  |  ⚠ Lemah vs Firewall",
		"Malware": "⚡ Kuat vs Firewall  |  ⚠ Lemah vs Crypto",
		"Monitor": "⚡ Kuat vs Social Engineering  |  ⚠ Lemah vs Malware",
		"Social Engineering": "⚡ Kuat vs Crypto  |  ⚠ Lemah vs Monitor",
		"Firewall": "⚡ Kuat vs Network  |  ⚠ Lemah vs Malware",
	}
	add_child(create_label(adv_map.get(player_data["type"],""), Vector2(PP_X+20, PP_Y+162), 15, Color(0.6,0.6,0.8)))

	# ── BATTLE LOG ──
	add_child(create_panel(Vector2(PP_X, PP_Y+202), Vector2(PANEL_W, 75), Color(0.5,0.5,0.8)))
	battle_log_label = create_label("Battle Start!", Vector2(PP_X+18, PP_Y+214), 20, Color(1,1,0.7))
	battle_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	battle_log_label.custom_minimum_size = Vector2(PANEL_W-30, 55)
	add_child(battle_log_label)

	# ── EDU LOG ──
	add_child(create_panel(Vector2(PP_X, PP_Y+284), Vector2(PANEL_W, 155), Color(0.3,0.5,0.3)))
	add_child(create_label("EDU-LOG", Vector2(PP_X+18, PP_Y+294), 16, Color(0.5,1,0.5)))
	edu_scroll = ScrollContainer.new()
	edu_scroll.position = Vector2(PP_X+12, PP_Y+318)
	edu_scroll.size     = Vector2(PANEL_W-20, 115)
	edu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(edu_scroll)
	edu_vbox = VBoxContainer.new()
	edu_vbox.custom_minimum_size = Vector2(PANEL_W-30, 0)
	edu_scroll.add_child(edu_vbox)

	# ── MOVE BUTTONS (2×2, kanan bawah) ──
	var moves      = player_data["moves"]
	var btn_colors = [Color(0.15,0.35,0.75), Color(0.75,0.35,0.05), Color(0.15,0.6,0.25), Color(0.5,0.15,0.6)]
	var btn_pos    = [Vector2(MB_X1,MB_Y1), Vector2(MB_X2,MB_Y1), Vector2(MB_X1,MB_Y2), Vector2(MB_X2,MB_Y2)]
	for i in moves.size():
		player_monster_moves.append(moves[i]["name"])
		var btn = create_move_btn(moves[i]["name"], btn_pos[i], btn_colors[i], i)
		add_child(btn)
		move_buttons.append(btn)

	# ── ACTION BUTTONS (FLEE / ITEM / CATCH) ──
	_build_action_buttons()

	# ── SPRITES ──
	# Enemy: kanan atas, di bawah panel
	var es = SentinelSprites.draw(self, enemy_data["id"], Vector2(1250, 360), ec, 130)
	es.name = "enemy_sprite"; es.set_meta("monster_name", enemy_data["name"])
	# Player: kiri tengah, di atas panel
	var ps = SentinelSprites.draw(self, player_data["id"], Vector2(370, 460), pc, 150)
	ps.name = "player_sprite"; ps.set_meta("monster_name", player_data["name"])

func _build_action_buttons():
	flee_btn = _make_act_btn("📡 FLEE",  Vector2(MB_X1,       AB_Y), Color(0.5,0.4,0.1))
	flee_btn.pressed.connect(_on_flee_pressed); add_child(flee_btn)

	item_btn = _make_act_btn("💊 ITEM",  Vector2(MB_X1+195,   AB_Y), Color(0.15,0.5,0.4))
	item_btn.pressed.connect(_on_item_pressed); add_child(item_btn)

	catch_btn= _make_act_btn("🔑 CATCH", Vector2(MB_X1+395,   AB_Y), Color(0.4,0.2,0.6))
	catch_btn.pressed.connect(_on_catch_pressed); add_child(catch_btn)
	_refresh_catch_button()

func _make_act_btn(text: String, pos: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = Vector2(ACT_BTN_W, ACT_BTN_H)
	var s = StyleBoxFlat.new(); s.bg_color = color
	s.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", s)
	var h = s.duplicate(); h.bg_color = color.lightened(0.25)
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func _refresh_catch_button():
	if catch_btn == null: return
	if GlobalData.has_caught(enemy_id):
		catch_btn.text = "✅ CAUGHT"; catch_btn.disabled = true
	else:
		catch_btn.text = "🔑 CATCH"; catch_btn.disabled = false

# ── ITEM PANEL OVERLAY ──
func _show_item_panel():
	if item_panel_node != null:
		item_panel_node.queue_free(); item_panel_node = null; return

	var panel = Node2D.new()
	# Tampil di atas action buttons, tidak menutupi move buttons
	panel.position = Vector2(MB_X1, AB_Y - 310)
	add_child(panel); item_panel_node = panel

	var bg = ColorRect.new()
	bg.color = Color(0.05,0.05,0.18,0.97); bg.size = Vector2(600, 300); panel.add_child(bg)
	var border = ColorRect.new()
	border.color = Color(0.3,0.8,0.5); border.size = Vector2(600,4); panel.add_child(border)

	var title = Label.new(); title.text = "── ITEMS IN BATTLE ──"
	title.position = Vector2(16,14)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.5,1,0.5)); panel.add_child(title)

	var y_off = 55; var has_any = false
	for item_id in ["heal_potion","capture_key"]:
		var count = GlobalData.get_item_count(item_id)
		if count <= 0: continue
		has_any = true
		var idef = GlobalData.ITEM_DATA.get(item_id, {})
		var btn  = Button.new()
		btn.text = idef.get("icon","?")+" "+idef.get("name",item_id)+"  ×"+str(count)
		btn.position = Vector2(16, y_off); btn.size = Vector2(568, 55)
		var s = StyleBoxFlat.new(); s.bg_color = Color(0.15,0.35,0.25); s.set_corner_radius_all(7)
		btn.add_theme_stylebox_override("normal", s)
		btn.add_theme_font_size_override("font_size", 19)
		btn.add_theme_color_override("font_color", Color.WHITE)
		var cid = item_id; btn.pressed.connect(func(): _use_item_from_panel(cid))
		panel.add_child(btn); y_off += 65

	if not has_any:
		var empty = Label.new(); empty.text = "Tidak ada item yang bisa dipakai."
		empty.position = Vector2(16, y_off)
		empty.add_theme_font_size_override("font_size", 19)
		empty.add_theme_color_override("font_color", Color(0.6,0.6,0.6)); panel.add_child(empty)

	var close = Button.new(); close.text = "✕ Tutup"
	close.position = Vector2(440, 255); close.size = Vector2(145, 40)
	close.pressed.connect(func():
		if is_instance_valid(item_panel_node): item_panel_node.queue_free(); item_panel_node = null)
	panel.add_child(close)

func _use_item_from_panel(item_id: String):
	if item_panel_node != null: item_panel_node.queue_free(); item_panel_node = null
	set_all_buttons_disabled(true)
	battle_manager.player_use_item(item_id)

# ════════════════════════════════════════════
# ── BUTTON HANDLERS ──
# ════════════════════════════════════════════

func _on_flee_pressed():
	if not battle_active: return
	set_all_buttons_disabled(true); battle_manager.player_flee()

func _on_item_pressed():
	if not battle_active: return
	_show_item_panel()

func _on_catch_pressed():
	if not battle_active: return
	if GlobalData.get_item_count("capture_key") <= 0:
		battle_log_label.text = "🔑 Tidak punya Capture Key!"; return
	set_all_buttons_disabled(true)
	GlobalData.use_item("capture_key")
	battle_manager.player_catch()

func on_move_pressed(index: int):
	if not battle_active: return
	if item_panel_node != null: item_panel_node.queue_free(); item_panel_node = null
	set_all_buttons_disabled(true)
	animate_attack(true)
	battle_manager.player_use_move(index)

# ════════════════════════════════════════════
# ── SIGNAL HANDLERS ──
# ════════════════════════════════════════════

func connect_signals():
	battle_manager.battle_log.connect(on_battle_log)
	battle_manager.edu_log.connect(on_edu_log)
	battle_manager.edu_popup.connect(on_edu_popup)
	battle_manager.battle_ended.connect(on_battle_ended)
	battle_manager.hp_updated.connect(on_hp_updated)
	battle_manager.enemy_attacking.connect(func(): animate_attack(false))
	battle_manager.cooldown_updated.connect(on_cooldown_updated)
	battle_manager.fled_battle.connect(on_fled_battle)
	battle_manager.catch_result.connect(on_catch_result)

func on_battle_log(msg: String): battle_log_label.text = msg

func on_edu_log(msg: String):
	var entry = Label.new()
	entry.text = "▸ " + msg
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD
	entry.custom_minimum_size = Vector2(PANEL_W-40, 0)
	entry.add_theme_font_size_override("font_size", 15)
	entry.add_theme_color_override("font_color", Color(0.6,1,0.6))
	edu_vbox.add_child(entry)
	var sep = ColorRect.new(); sep.color = Color(0.3,0.5,0.3,0.4)
	sep.custom_minimum_size = Vector2(PANEL_W-40, 1); edu_vbox.add_child(sep)
	await get_tree().process_frame
	edu_scroll.scroll_vertical = int(edu_scroll.get_v_scroll_bar().max_value)

func on_edu_popup(move_name: String, edu_text: String, domain: String):
	print("on_edu_popup called, edu_popup is: ", edu_popup)
	if edu_popup: edu_popup.show_popup(move_name, edu_text, domain)

func on_hp_updated(p_hp: int, p_max: int, e_hp: int, e_max: int):
	player_hp_bar.value = (float(p_hp)/p_max)*100
	player_hp_label.text = "HP: "+str(p_hp)+"/"+str(p_max)
	enemy_hp_bar.value  = (float(e_hp)/e_max)*100
	enemy_hp_label.text  = "HP: "+str(e_hp)+"/"+str(e_max)
	for bar_info in [[player_hp_bar, p_hp, p_max, Color(0.2,0.8,0.4)],[enemy_hp_bar, e_hp, e_max, Color(1,0.3,0.3)]]:
		if bar_info[1] < bar_info[2] * 0.3:
			var s = StyleBoxFlat.new(); s.bg_color = Color(1,0.6,0)
			bar_info[0].add_theme_stylebox_override("fill", s)
	if battle_active: set_all_buttons_disabled(false)

func on_cooldown_updated(cooldowns: Array):
	for i in move_buttons.size():
		if i < cooldowns.size():
			move_buttons[i].disabled = cooldowns[i] or not battle_active
			move_buttons[i].text = player_monster_moves[i] + ("\n[COOLDOWN]" if cooldowns[i] else "")

func on_battle_ended(player_won: bool):
	battle_active = false; set_all_buttons_disabled(true)
	if player_won:
		var reward = GlobalData.on_battle_won()
		battle_log_label.text = "✅ Menang! Reward: +1 Heal Potion, +1 Capture Key!" if reward else "✅ You won!"
	var loser = find_child("player_sprite" if not player_won else "enemy_sprite", true, false)
	if loser:
		spawn_hit_particles(loser.position, Color(1,0.5,0.2), 22)
		var dt = create_tween(); dt.set_parallel(true)
		dt.tween_property(loser, "modulate:a", 0.0, 0.8)
		dt.tween_property(loser, "position", loser.position+Vector2(0,40), 0.8)
		trigger_screen_shake(12.0)
	await get_tree().create_timer(2.5).timeout
	_go_to_result(player_won)

func on_fled_battle():
	battle_active = false; set_all_buttons_disabled(true)
	battle_log_label.text = "📡 Kabur berhasil..."
	# Pakai process_always=true supaya timer jalan meski tree di-pause
	await get_tree().create_timer(1.5, true).timeout
	_return_after_battle()

func on_catch_result(success: bool, _monster_id: String, monster_name: String):
	if success:
		battle_active = false; set_all_buttons_disabled(true)
		battle_log_label.text = "🎉 "+monster_name+" telah ditangkap!"
		_refresh_catch_button(); trigger_screen_shake(6.0)
		var es = find_child("enemy_sprite", true, false)
		if es:
			spawn_hit_particles(es.position, Color(0.5,0.3,1.0), 28)
			var ct = create_tween(); ct.set_parallel(true)
			ct.tween_property(es, "modulate", Color(1.5,1.5,2.5), 0.3)
			ct.tween_property(es, "scale",    Vector2(0.5,0.5),     0.6)
			ct.tween_property(es, "modulate:a", 0.0, 0.6)
		await get_tree().create_timer(2.0).timeout
		_go_to_result(true)
	else:
		set_all_buttons_disabled(false); _refresh_catch_button()

# ════════════════════════════════════════════
# ── NAVIGATION ──
# ════════════════════════════════════════════

func _go_to_result(player_won: bool):
	# Simpan hasil battle ke GlobalData — tidak ada root meta lagi
	GlobalData.set_battle_result(
		player_won,
		player_name_label.text,
		enemy_name_label.text,
		battle_manager.get_moves_used()
	)
	# Clear encounter data karena battle sudah selesai
	GlobalData.clear_encounter()
	SceneManager.replace_overlay("res://menus/result/ResultScreen.tscn")

func _return_after_battle():
	# Flee — tutup overlay, kembali ke map
	# Bersihkan encounter meta
	# Encounter sudah di-clear oleh _go_to_result, clear lagi untuk safety
	GlobalData.clear_encounter()
	SceneManager.pop_overlay()

# ════════════════════════════════════════════
# ── HELPERS ──
# ════════════════════════════════════════════

func get_type_color(type: String) -> Color:
	match type:
		"Malware":            return Color(1.0, 0.3, 0.3)
		"Firewall":           return Color(0.2, 0.5, 1.0)
		"Network":            return Color(1.0, 0.9, 0.2)
		"Crypto":             return Color(0.3, 0.9, 1.0)
		"Social Engineering": return Color(1.0, 0.6, 0.1)
		"Monitor":            return Color(0.2, 0.9, 0.4)
	return Color(1, 1, 1)

func create_panel(pos: Vector2, size: Vector2, accent: Color) -> Node2D:
	var c = Node2D.new(); c.position = pos
	var bg = ColorRect.new(); bg.color = Color(0.08,0.08,0.22,0.6); bg.size = size; c.add_child(bg)
	var bt = ColorRect.new(); bt.color = accent; bt.size = Vector2(size.x,4); c.add_child(bt)
	var bl = ColorRect.new(); bl.color = Color(accent.r,accent.g,accent.b,0.4); bl.size = Vector2(4,size.y); c.add_child(bl)
	return c

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new(); l.text = text; l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func create_hp_bar(pos: Vector2, width: int, color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = pos; bar.size = Vector2(width, 24)
	bar.min_value = 0; bar.max_value = 100; bar.value = 100; bar.show_percentage = false
	var fs = StyleBoxFlat.new(); fs.bg_color = color; fs.set_corner_radius_all(5)
	bar.add_theme_stylebox_override("fill", fs)
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(0.2,0.2,0.2)
	bar.add_theme_stylebox_override("background", bs)
	return bar

func create_move_btn(text: String, pos: Vector2, color: Color, index: int) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = Vector2(MOVE_BTN_W, MOVE_BTN_H)
	var s = StyleBoxFlat.new(); s.bg_color = color; s.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", s)
	var h = s.duplicate(); h.bg_color = color.lightened(0.3)
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(func(): on_move_pressed(index))
	return btn

func set_all_buttons_disabled(disabled: bool):
	for btn in move_buttons: btn.disabled = disabled
	if flee_btn:  flee_btn.disabled  = disabled
	if item_btn:  item_btn.disabled  = disabled
	if catch_btn and not GlobalData.has_caught(enemy_id): catch_btn.disabled = disabled

func set_buttons_disabled(disabled: bool): set_all_buttons_disabled(disabled)
func enable_move_button(index: int, enabled: bool):
	if index < move_buttons.size(): move_buttons[index].disabled = not enabled
func show_tutorial_message(text: String): battle_log_label.text = text
