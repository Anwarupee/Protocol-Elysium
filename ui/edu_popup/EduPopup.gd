extends CanvasLayer

# ─────────────────────────────────────────
#  EduPopup.gd — FULLY PROGRAMMATIC
#  Tidak perlu atur node di Inspector sama sekali.
#  Cukup:
#  1. Buka EduPopup.tscn
#  2. Hapus semua child node (Root, Dimmer, Panel, dll)
#  3. Pastikan root node adalah CanvasLayer
#  4. Set Process Mode = Always di Inspector
#  5. Attach script ini
#  Semua UI dibuat otomatis dari kode.
# ─────────────────────────────────────────

signal popup_closed

const SCREEN_W = 1152.0
const SCREEN_H = 648.0
const POPUP_W  = 680.0
const POPUP_H  = 170.0

const DOMAIN_COLORS = {
	"Data":               Color(0.4, 0.8, 1.0),
	"Connection":         Color(1.0, 0.9, 0.3),
	"Malware":            Color(1.0, 0.4, 0.4),
	"Defensive":          Color(0.2, 0.9, 0.6),
	"System":             Color(0.6, 0.3, 1.0),
	"Social Engineering": Color(1.0, 0.7, 0.2)
}

# Node references — dibuat di _ready()
var dimmer:       ColorRect
var panel:        ColorRect
var accent_top:   ColorRect
var accent_left:  ColorRect
var badge_label:  Label
var move_label:   Label
var edu_label:    Label
var continue_btn: Button

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func _build_ui():
	# ── Dimmer (full screen overlay) ──
	dimmer = ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.6)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(dimmer)

	# ── Panel container ──
	var px = (SCREEN_W - POPUP_W) / 2.0
	var py = (SCREEN_H - POPUP_H) / 2.0

	panel = ColorRect.new()
	panel.color = Color(0.04, 0.04, 0.16, 0.97)
	panel.size = Vector2(POPUP_W, POPUP_H)
	panel.position = Vector2(px, py)
	add_child(panel)

	# ── Accent border top ──
	accent_top = ColorRect.new()
	accent_top.size = Vector2(POPUP_W, 3)
	accent_top.position = Vector2(px, py)
	add_child(accent_top)

	# ── Accent border left ──
	accent_left = ColorRect.new()
	accent_left.size = Vector2(3, POPUP_H)
	accent_left.position = Vector2(px, py)
	add_child(accent_left)

	# ── Domain badge ──
	badge_label = Label.new()
	badge_label.position = Vector2(px + 16, py + 14)
	badge_label.add_theme_font_size_override("font_size", 11)
	add_child(badge_label)

	# ── Move name ──
	move_label = Label.new()
	move_label.position = Vector2(px + 16, py + 30)
	move_label.add_theme_font_size_override("font_size", 20)
	move_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(move_label)

	# ── Separator line ──
	var sep = ColorRect.new()
	sep.color = Color(1, 1, 1, 0.1)
	sep.size = Vector2(POPUP_W - 32, 1)
	sep.position = Vector2(px + 16, py + 62)
	add_child(sep)

	# ── Edu text ──
	edu_label = Label.new()
	edu_label.position = Vector2(px + 16, py + 70)
	edu_label.size = Vector2(POPUP_W - 32, 60)
	edu_label.add_theme_font_size_override("font_size", 13)
	edu_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	edu_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(edu_label)

	# ── Continue button ──
	continue_btn = Button.new()
	continue_btn.text = "[ UNDERSTOOD ]"
	continue_btn.size = Vector2(POPUP_W - 32, 32)
	continue_btn.position = Vector2(px + 16, py + POPUP_H - 42)
	continue_btn.add_theme_font_size_override("font_size", 13)
	add_child(continue_btn)
	continue_btn.pressed.connect(_on_continue_pressed)

func show_popup(p_move_name: String, p_edu_text: String, p_domain: String):
	var col = DOMAIN_COLORS.get(p_domain, Color(0.4, 0.8, 1.0))

	badge_label.text = "[ " + p_domain.to_upper() + " ]"
	badge_label.add_theme_color_override("font_color", col)

	move_label.text = p_move_name.to_upper()

	edu_label.text = p_edu_text

	# Accent warna domain
	accent_top.color  = col
	accent_left.color = col

	# Tombol warna domain
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(col.r * 0.15, col.g * 0.15, col.b * 0.15)
	btn_style.border_color = col
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(4)
	continue_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(col.r * 0.35, col.g * 0.35, col.b * 0.35)
	continue_btn.add_theme_stylebox_override("hover", btn_hover)
	continue_btn.add_theme_color_override("font_color", col)

	# Reset posisi panel untuk animasi
	var target_y = panel.position.y
	panel.position.y = target_y + 20
	panel.modulate.a = 0.0
	dimmer.modulate.a = 0.0
	accent_top.modulate.a = 0.0
	accent_left.modulate.a = 0.0
	badge_label.modulate.a = 0.0
	move_label.modulate.a = 0.0
	edu_label.modulate.a = 0.0
	continue_btn.modulate.a = 0.0

	visible = true
	get_tree().paused = true
	_animate_in(target_y)

func _animate_in(target_y: float):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "modulate:a", 1.0, 0.22)
	tween.tween_property(panel, "position:y", target_y, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(accent_top, "modulate:a", 1.0, 0.3)
	tween.tween_property(accent_left, "modulate:a", 1.0, 0.3)
	tween.tween_property(badge_label, "modulate:a", 1.0, 0.35)
	tween.tween_property(move_label, "modulate:a", 1.0, 0.35)
	tween.tween_property(edu_label, "modulate:a", 1.0, 0.4)
	tween.tween_property(continue_btn, "modulate:a", 1.0, 0.45)

func _on_continue_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_property(accent_top, "modulate:a", 0.0, 0.15)
	tween.tween_property(accent_left, "modulate:a", 0.0, 0.15)
	tween.tween_property(badge_label, "modulate:a", 0.0, 0.15)
	tween.tween_property(move_label, "modulate:a", 0.0, 0.15)
	tween.tween_property(edu_label, "modulate:a", 0.0, 0.15)
	tween.tween_property(continue_btn, "modulate:a", 0.0, 0.15)
	await tween.finished
	visible = false
	get_tree().paused = false
	emit_signal("popup_closed")
