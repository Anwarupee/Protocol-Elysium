extends CanvasLayer

# ─────────────────────────────────────────
#  EduPopup.gd
#  Path: res://ui/edu_popup/EduPopup.tscn
#
#  Cara buat scene di Godot:
#  1. Buat scene baru → pilih CanvasLayer sebagai root
#  2. Rename jadi "EduPopup", set process_mode = Always
#  3. Tambah child: Control (name: Root, anchor = Full Rect)
#  4. Di dalam Root:
#     - ColorRect (name: Dimmer, size 1152x648, color #00000099)
#     - Panel (name: Panel, size 520x280, center di layar ~316,184)
#       Di dalam Panel, tambah VBoxContainer (name: VBox):
#         - HBoxContainer (name: Header)
#             - Label (name: DomainBadge, font_size: 11)
#             - Label (name: MoveName, font_size: 18, bold)
#         - HSeparator
#         - Label (name: EduText, font_size: 14, autowrap: Word)
#         - Button (name: ContinueBtn, text: "[ UNDERSTOOD ]", font_size: 14)
#  5. Attach script ini ke node CanvasLayer
# ─────────────────────────────────────────

signal popup_closed

@onready var dimmer       = $Root/Dimmer
@onready var panel        = $Root/Panel
@onready var domain_badge = $Root/Panel/VBox/Header/DomainBadge
@onready var move_name    = $Root/Panel/VBox/Header/MoveName
@onready var edu_text     = $Root/Panel/VBox/EduText
@onready var continue_btn = $Root/Panel/VBox/ContinueBtn

const DOMAIN_COLORS = {
	"Data":               Color(0.4, 0.8, 1.0),
	"Connection":         Color(1.0, 0.9, 0.3),
	"Malware":            Color(1.0, 0.4, 0.4),
	"Defensive":          Color(0.2, 0.9, 0.6),
	"System":             Color(0.6, 0.3, 1.0),
	"Social Engineering": Color(1.0, 0.7, 0.2)
}

func _ready():
	visible = false
	process_mode = PROCESS_MODE_ALWAYS
	continue_btn.pressed.connect(_on_continue_pressed)

func show_popup(p_move_name: String, p_edu_text: String, p_domain: String):
	move_name.text = p_move_name.to_upper()
	edu_text.text  = p_edu_text

	var col = DOMAIN_COLORS.get(p_domain, Color(0.4, 0.8, 1.0))
	domain_badge.text = "[ " + p_domain.to_upper() + " ]"
	domain_badge.add_theme_color_override("font_color", col)
	move_name.add_theme_color_override("font_color", Color.WHITE)

	# Panel border warna sesuai domain
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.18, 0.97)
	panel_style.border_color = col
	panel_style.set_border_width_all(0)
	panel_style.border_width_top  = 3
	panel_style.border_width_left = 3
	panel_style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", panel_style)

	# Tombol warna sesuai domain
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(col.r * 0.2, col.g * 0.2, col.b * 0.2)
	btn_style.border_color = col
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(4)
	continue_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(col.r * 0.4, col.g * 0.4, col.b * 0.4)
	continue_btn.add_theme_stylebox_override("hover", btn_hover)
	continue_btn.add_theme_color_override("font_color", col)

	visible = true
	panel.modulate.a = 0.0
	dimmer.modulate.a = 0.0
	var orig_y = panel.position.y
	panel.position.y = orig_y + 20
	get_tree().paused = true
	_animate_in(orig_y)

func _animate_in(target_y: float):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "position:y", target_y, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_continue_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tween.finished
	visible = false
	get_tree().paused = false
	emit_signal("popup_closed")
