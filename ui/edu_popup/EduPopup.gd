extends Node2D

# =============================================================
# EduPopup — popup edukasi yang muncul saat move digunakan
# =============================================================
# Dipanggil oleh Battle.gd via: edu_popup.show_popup(name, text, domain)
# Emit signal popup_closed saat player klik UNDERSTOOD
# =============================================================

signal popup_closed

const SCREEN_W = 1920.0
const SCREEN_H = 1080.0
const POPUP_W  = 860.0
const POPUP_H  = 300.0

const DOMAIN_COLORS: Dictionary = {
	"Crypto":             Color(0.4,  0.8,  1.0),
	"Firewall":           Color(0.4,  0.7,  0.4),
	"Network":            Color(0.6,  0.6,  1.0),
	"Malware":            Color(1.0,  0.35, 0.35),
	"Monitor":            Color(1.0,  0.8,  0.3),
	"Social Engineering": Color(0.9,  0.5,  0.9),
}

var _built:        bool         = false
var _dimmer:       ColorRect    = null
var _panel:        ColorRect    = null
var _accent_top:   ColorRect    = null
var _accent_left:  ColorRect    = null
var _badge_label:  Label        = null
var _move_label:   Label        = null
var _edu_label:    Label        = null
var _continue_btn: Button       = null

func _ready():
	visible = false
	_build()

func _build():
	if _built:
		return
	_built = true

	var px = (SCREEN_W - POPUP_W) / 2.0
	var py = (SCREEN_H - POPUP_H) / 2.0

	# Dimmer
	_dimmer = ColorRect.new()
	_dimmer.color = Color(0, 0, 0, 0.55)
	_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dimmer.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(_dimmer)

	# Panel background
	_panel = ColorRect.new()
	_panel.color = Color(0.04, 0.04, 0.16, 0.97)
	_panel.size = Vector2(POPUP_W, POPUP_H)
	_panel.position = Vector2(px, py)
	add_child(_panel)

	# Top accent bar
	_accent_top = ColorRect.new()
	_accent_top.size = Vector2(POPUP_W, 4)
	_accent_top.position = Vector2(px, py)
	add_child(_accent_top)

	# Left accent bar
	_accent_left = ColorRect.new()
	_accent_left.size = Vector2(4, POPUP_H)
	_accent_left.position = Vector2(px, py)
	add_child(_accent_left)

	# Domain badge
	_badge_label = Label.new()
	_badge_label.position = Vector2(px + 24, py + 18)
	_badge_label.add_theme_font_size_override("font_size", 16)
	add_child(_badge_label)

	# Move name
	_move_label = Label.new()
	_move_label.position = Vector2(px + 24, py + 42)
	_move_label.add_theme_font_size_override("font_size", 30)
	_move_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(_move_label)

	# Separator
	var sep = ColorRect.new()
	sep.color = Color(1, 1, 1, 0.1)
	sep.size = Vector2(POPUP_W - 48, 1)
	sep.position = Vector2(px + 24, py + 96)
	add_child(sep)

	# Edu text
	_edu_label = Label.new()
	_edu_label.position = Vector2(px + 24, py + 108)
	_edu_label.size = Vector2(POPUP_W - 48, 120)
	_edu_label.add_theme_font_size_override("font_size", 19)
	_edu_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	_edu_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_edu_label)

	# Continue button
	_continue_btn = Button.new()
	_continue_btn.text = "[ UNDERSTOOD ]"
	_continue_btn.size = Vector2(POPUP_W - 48, 48)
	_continue_btn.position = Vector2(px + 24, py + POPUP_H - 62)
	_continue_btn.add_theme_font_size_override("font_size", 19)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.25, 0.45)
	style.corner_radius_top_left    = 4
	style.corner_radius_top_right   = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right= 4
	_continue_btn.add_theme_stylebox_override("normal", style)
	_continue_btn.add_theme_color_override("font_color", Color.WHITE)
	_continue_btn.pressed.connect(_on_continue_pressed)
	add_child(_continue_btn)

func show_popup(move_name: String, edu_text: String, domain: String):
	print("EduPopup.show_popup called: ", move_name, " | visible before: ", visible)
	_build()
	var col = DOMAIN_COLORS.get(domain, Color(0.4, 0.8, 1.0))
	_badge_label.text = "[ " + domain.to_upper() + " ]"
	_badge_label.add_theme_color_override("font_color", col)
	_move_label.text  = move_name.to_upper()
	_edu_label.text   = edu_text
	_accent_top.color  = col
	_accent_left.color = col
	visible = true

func _on_continue_pressed():
	visible = false
	emit_signal("popup_closed")
