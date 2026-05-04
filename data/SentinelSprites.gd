extends Node
# ══════════════════════════════════════════════
#  SentinelSprites.gd
#  Daftarkan sebagai Autoload di Project Settings
#  dengan nama "SentinelSprites"
#
#  Cara pakai dari scene manapun:
#  SentinelSprites.draw(parent_node, monster_id, position, color, size)
# ══════════════════════════════════════════════

func draw(parent: Node, monster_id: String, pos: Vector2, color: Color, size: float) -> Node2D:
	var root = Node2D.new()
	root.position = pos
	parent.add_child(root)

	var glow = ColorRect.new()
	glow.color = Color(color.r, color.g, color.b, 0.1)
	glow.size = Vector2(size + 40, size + 40)
	glow.position = Vector2(-(size + 40) / 2, -(size + 40) / 2)
	root.add_child(glow)

	match monster_id:
		"encryp_pup":    _draw_encryp_pup(root, color, size)
		"ping_go":       _draw_ping_go(root, color, size)
		"biti":          _draw_biti(root, color, size)
		"senti_shell":   _draw_senti_shell(root, color, size)
		"octo_core":     _draw_octo_core(root, color, size)
		"chamele_auth":  _draw_chamele_auth(root, color, size)
		"vaultex":       _draw_vaultex(root, color, size)
		"cipher_ray":    _draw_cipher_ray(root, color, size)
		"routerex":      _draw_routerex(root, color, size)
		"latencia":      _draw_latencia(root, color, size)
		"ransom_rex":    _draw_ransom_rex(root, color, size)
		"worm_ling":     _draw_worm_ling(root, color, size)
		"patchwork":     _draw_patchwork(root, color, size)
		"bastion":       _draw_bastion(root, color, size)
		"daemon_x":      _draw_daemon_x(root, color, size)
		"bios_wraith":   _draw_bios_wraith(root, color, size)
		"vish_ara":      _draw_vish_ara(root, color, size)
		"bait_eel":      _draw_bait_eel(root, color, size)
		"hash_hound":    _draw_hash_hound(root, color, size)
		"key_lynx":      _draw_key_lynx(root, color, size)
		"signal_snail":  _draw_signal_snail(root, color, size)
		"warp_wolf":     _draw_warp_wolf(root, color, size)
		"logic_leech":   _draw_logic_leech(root, color, size)
		"trojan_taurus": _draw_trojan_taurus(root, color, size)
		"brick_bear":    _draw_brick_bear(root, color, size)
		"gate_gorilla":  _draw_gate_gorilla(root, color, size)
		"phish_falcon":  _draw_phish_falcon(root, color, size)
		"scam_serpent":  _draw_scam_serpent(root, color, size)
		"sentry_stinger":_draw_sentry_stinger(root, color, size)
		"radar_rhino":   _draw_radar_rhino(root, color, size)
		_:               _draw_default(root, color, size)

	return root

# ── Helpers ──
func _r(p: Node, x: float, y: float, w: float, h: float, c: Color):
	var r = ColorRect.new()
	r.color = c; r.size = Vector2(w, h); r.position = Vector2(x, y)
	p.add_child(r)

func _dk(c: Color, a: float = 0.3) -> Color: return c.darkened(a)
func _lt(c: Color, a: float = 0.3) -> Color: return c.lightened(a)

# ══════════════════════════════════════════════
#  EXISTING 18 SENTINELS
# ══════════════════════════════════════════════

func _draw_encryp_pup(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-25*sc,-15*sc,50*sc,40*sc,c); _r(p,-20*sc,-40*sc,40*sc,28*sc,c)
	_r(p,-22*sc,-55*sc,14*sc,20*sc,_dk(c)); _r(p,8*sc,-55*sc,14*sc,20*sc,_dk(c))
	_r(p,-10*sc,-25*sc,20*sc,12*sc,_lt(c,0.4))
	_r(p,-14*sc,-36*sc,7*sc,7*sc,Color(0.1,0.1,0.2)); _r(p,7*sc,-36*sc,7*sc,7*sc,Color(0.1,0.1,0.2))
	_r(p,-22*sc,22*sc,14*sc,18*sc,_dk(c)); _r(p,-5*sc,22*sc,14*sc,18*sc,_dk(c)); _r(p,12*sc,22*sc,14*sc,18*sc,_dk(c))
	_r(p,24*sc,-10*sc,10*sc,8*sc,c); _r(p,32*sc,-18*sc,8*sc,10*sc,c)
	_r(p,-8*sc,-8*sc,16*sc,12*sc,Color(1,0.85,0.2)); _r(p,-5*sc,-16*sc,10*sc,10*sc,Color(1,0.85,0.2,0.7))
	_r(p,-18*sc,-38*sc,8*sc,4*sc,Color(1,1,1,0.2))

func _draw_ping_go(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-20*sc,-15*sc,40*sc,35*sc,c); _r(p,-15*sc,-38*sc,30*sc,26*sc,c)
	_r(p,-38*sc,-10*sc,20*sc,28*sc,_dk(c,0.2)); _r(p,-50*sc,-5*sc,15*sc,15*sc,_dk(c,0.3))
	_r(p,18*sc,-10*sc,20*sc,28*sc,_dk(c,0.2)); _r(p,35*sc,-5*sc,15*sc,15*sc,_dk(c,0.3))
	_r(p,12*sc,-28*sc,18*sc,10*sc,Color(1,0.7,0.1)); _r(p,16*sc,-20*sc,14*sc,8*sc,Color(1,0.6,0.0))
	_r(p,-8*sc,-32*sc,9*sc,9*sc,Color(0.05,0.05,0.15)); _r(p,-5*sc,-30*sc,4*sc,4*sc,Color(1,1,1,0.5))
	_r(p,-10*sc,20*sc,8*sc,16*sc,Color(1,0.7,0.1)); _r(p,2*sc,20*sc,8*sc,16*sc,Color(1,0.7,0.1))
	_r(p,-5*sc,-52*sc,10*sc,4*sc,Color(1,1,1,0.3)); _r(p,-10*sc,-60*sc,20*sc,4*sc,Color(1,1,1,0.2))

func _draw_biti(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-18*sc,-18*sc,36*sc,36*sc,c)
	_r(p,-5*sc,-34*sc,10*sc,18*sc,c); _r(p,-2*sc,-40*sc,4*sc,8*sc,_dk(c))
	_r(p,-5*sc,16*sc,10*sc,18*sc,c); _r(p,-2*sc,32*sc,4*sc,8*sc,_dk(c))
	_r(p,-34*sc,-5*sc,18*sc,10*sc,c); _r(p,-40*sc,-2*sc,8*sc,4*sc,_dk(c))
	_r(p,16*sc,-5*sc,18*sc,10*sc,c); _r(p,32*sc,-2*sc,8*sc,4*sc,_dk(c))
	_r(p,-28*sc,-28*sc,10*sc,10*sc,_dk(c,0.2)); _r(p,18*sc,-28*sc,10*sc,10*sc,_dk(c,0.2))
	_r(p,-28*sc,18*sc,10*sc,10*sc,_dk(c,0.2)); _r(p,18*sc,18*sc,10*sc,10*sc,_dk(c,0.2))
	_r(p,-10*sc,-8*sc,8*sc,10*sc,Color(0.8,0.1,0.1)); _r(p,2*sc,-8*sc,8*sc,10*sc,Color(0.8,0.1,0.1))
	_r(p,-8*sc,-8*sc,16*sc,16*sc,Color(c.r,c.g,c.b,0.4))

func _draw_senti_shell(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-30*sc,-25*sc,60*sc,45*sc,_dk(c,0.2))
	_r(p,-20*sc,-22*sc,18*sc,18*sc,c); _r(p,2*sc,-22*sc,18*sc,18*sc,_lt(c,0.1))
	_r(p,-25*sc,-2*sc,22*sc,18*sc,_lt(c,0.1)); _r(p,-1*sc,-2*sc,22*sc,18*sc,c)
	_r(p,-30*sc,-4*sc,60*sc,2*sc,_dk(c,0.4)); _r(p,-2*sc,-25*sc,2*sc,45*sc,_dk(c,0.4))
	_r(p,-12*sc,-38*sc,24*sc,16*sc,_lt(c,0.2))
	_r(p,-8*sc,-35*sc,6*sc,6*sc,Color(0.1,0.1,0.2)); _r(p,2*sc,-35*sc,6*sc,6*sc,Color(0.1,0.1,0.2))
	_r(p,-38*sc,-5*sc,10*sc,14*sc,_lt(c,0.2)); _r(p,28*sc,-5*sc,10*sc,14*sc,_lt(c,0.2))
	_r(p,-20*sc,18*sc,12*sc,14*sc,_lt(c,0.2)); _r(p,8*sc,18*sc,12*sc,14*sc,_lt(c,0.2))
	_r(p,-15*sc,-20*sc,10*sc,5*sc,Color(1,1,1,0.3))

func _draw_octo_core(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-25*sc,-40*sc,50*sc,45*sc,c)
	_r(p,-15*sc,-30*sc,30*sc,20*sc,_dk(c,0.3)); _r(p,-10*sc,-28*sc,20*sc,16*sc,Color(0.8,0.5,1,0.3))
	_r(p,-15*sc,-35*sc,12*sc,12*sc,Color(0.9,0.3,1)); _r(p,3*sc,-35*sc,12*sc,12*sc,Color(0.9,0.3,1))
	_r(p,-11*sc,-32*sc,5*sc,5*sc,Color(1,1,1,0.6)); _r(p,7*sc,-32*sc,5*sc,5*sc,Color(1,1,1,0.6))
	for i in 8:
		var tx = (-35 + i * 10)*sc; var wave = 5 if i % 2 == 0 else -5
		_r(p,tx,5*sc,8*sc,20*sc,_dk(c,0.1)); _r(p,tx+wave*sc,22*sc,8*sc,15*sc,_dk(c,0.2))
		_r(p,tx+wave*2*sc,34*sc,6*sc,10*sc,_dk(c,0.3))
	_r(p,-22*sc,-20*sc,44*sc,2*sc,Color(0.8,0.5,1,0.4))
	_r(p,-10*sc,-30*sc,2*sc,25*sc,Color(0.8,0.5,1,0.4)); _r(p,8*sc,-30*sc,2*sc,25*sc,Color(0.8,0.5,1,0.4))

func _draw_chamele_auth(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-20*sc,-10*sc,42*sc,32*sc,c); _r(p,-22*sc,-30*sc,38*sc,24*sc,c); _r(p,-30*sc,-22*sc,12*sc,15*sc,c)
	_r(p,-20*sc,-32*sc,16*sc,16*sc,_dk(c,0.3)); _r(p,-17*sc,-29*sc,10*sc,10*sc,Color(0.9,0.7,0.1))
	_r(p,-14*sc,-27*sc,5*sc,5*sc,Color(0.05,0.05,0.1))
	_r(p,4*sc,-28*sc,12*sc,12*sc,_dk(c,0.3)); _r(p,6*sc,-26*sc,8*sc,8*sc,Color(0.9,0.7,0.1))
	_r(p,8*sc,-24*sc,4*sc,4*sc,Color(0.05,0.05,0.1))
	_r(p,-28*sc,5*sc,10*sc,22*sc,_dk(c,0.2)); _r(p,-36*sc,22*sc,10*sc,6*sc,_dk(c,0.3))
	_r(p,20*sc,5*sc,10*sc,22*sc,_dk(c,0.2)); _r(p,24*sc,22*sc,12*sc,6*sc,_dk(c,0.3))
	_r(p,20*sc,-5*sc,18*sc,8*sc,c); _r(p,34*sc,-14*sc,8*sc,12*sc,c); _r(p,28*sc,-22*sc,10*sc,10*sc,c)
	_r(p,-10*sc,-15*sc,22*sc,14*sc,Color(1,0.85,0.2,0.3))

func _draw_vaultex(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-32*sc,56*sc,58*sc,_dk(c,0.2)); _r(p,-24*sc,-28*sc,48*sc,50*sc,c)
	_r(p,-14*sc,-18*sc,28*sc,28*sc,_dk(c,0.4)); _r(p,-10*sc,-14*sc,20*sc,20*sc,_lt(c,0.2))
	_r(p,-14*sc,-5*sc,28*sc,3*sc,_dk(c,0.5)); _r(p,-2*sc,-18*sc,3*sc,28*sc,_dk(c,0.5))
	_r(p,22*sc,-20*sc,6*sc,8*sc,_dk(c,0.4)); _r(p,22*sc,4*sc,6*sc,8*sc,_dk(c,0.4))
	_r(p,-24*sc,26*sc,16*sc,12*sc,_dk(c,0.3)); _r(p,8*sc,26*sc,16*sc,12*sc,_dk(c,0.3))
	_r(p,-22*sc,-26*sc,20*sc,6*sc,Color(1,1,1,0.2)); _r(p,-4*sc,10*sc,8*sc,10*sc,_dk(c,0.6))

func _draw_cipher_ray(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-14*sc,-12*sc,28*sc,32*sc,c); _r(p,-12*sc,-30*sc,24*sc,22*sc,c)
	_r(p,8*sc,-28*sc,16*sc,8*sc,Color(1,0.8,0.2)); _r(p,18*sc,-22*sc,10*sc,8*sc,Color(1,0.7,0.1))
	_r(p,-8*sc,-26*sc,10*sc,8*sc,Color(0.1,0.05,0.2)); _r(p,-5*sc,-24*sc,6*sc,5*sc,Color(1,0.9,0.2))
	_r(p,-50*sc,-20*sc,38*sc,8*sc,Color(c.r,c.g,c.b,0.7)); _r(p,-55*sc,-12*sc,30*sc,6*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-48*sc,-28*sc,25*sc,6*sc,Color(c.r,c.g,c.b,0.6))
	_r(p,12*sc,-20*sc,38*sc,8*sc,Color(c.r,c.g,c.b,0.7)); _r(p,25*sc,-12*sc,30*sc,6*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,23*sc,-28*sc,25*sc,6*sc,Color(c.r,c.g,c.b,0.6))
	_r(p,-12*sc,20*sc,10*sc,14*sc,_dk(c)); _r(p,2*sc,20*sc,10*sc,14*sc,_dk(c))
	_r(p,-45*sc,-22*sc,12*sc,3*sc,Color(1,1,1,0.3)); _r(p,25*sc,-22*sc,12*sc,3*sc,Color(1,1,1,0.3))

func _draw_routerex(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-25*sc,-5*sc,50*sc,42*sc,c); _r(p,-12*sc,-25*sc,24*sc,22*sc,c); _r(p,-18*sc,-45*sc,36*sc,24*sc,c)
	_r(p,12*sc,-38*sc,28*sc,14*sc,_dk(c,0.1))
	_r(p,-12*sc,-40*sc,10*sc,10*sc,Color(0.2,0.2,0.1)); _r(p,-9*sc,-38*sc,5*sc,5*sc,Color(1,0.9,0.2))
	_r(p,-20*sc,-58*sc,6*sc,15*sc,_dk(c,0.3)); _r(p,-8*sc,-60*sc,6*sc,17*sc,_dk(c,0.3)); _r(p,4*sc,-56*sc,6*sc,13*sc,_dk(c,0.3))
	_r(p,-18*sc,-60*sc,4*sc,4*sc,Color(0.2,1,0.3)); _r(p,-6*sc,-62*sc,4*sc,4*sc,Color(1,0.8,0.1)); _r(p,6*sc,-58*sc,4*sc,4*sc,Color(0.2,0.5,1))
	_r(p,-22*sc,35*sc,16*sc,14*sc,_dk(c,0.2)); _r(p,6*sc,35*sc,16*sc,14*sc,_dk(c,0.2))
	_r(p,-40*sc,10*sc,18*sc,10*sc,c); _r(p,-52*sc,18*sc,14*sc,8*sc,_dk(c))

func _draw_latencia(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-35*sc,56*sc,40*sc,c); _r(p,-20*sc,-30*sc,40*sc,30*sc,Color(c.r,c.g,c.b,0.4))
	_r(p,-26*sc,-20*sc,52*sc,4*sc,Color(1,1,1,0.15)); _r(p,-24*sc,-10*sc,48*sc,3*sc,Color(1,1,1,0.1))
	for i in 7:
		var tx = (-24 + i * 8)*sc; var tl = 30 + (i % 3) * 15
		_r(p,tx,5*sc,4*sc,tl*sc,Color(c.r,c.g,c.b,0.6 - i * 0.05))
	_r(p,-14*sc,-28*sc,10*sc,10*sc,Color(1,0.9,0.2,0.8)); _r(p,4*sc,-28*sc,10*sc,10*sc,Color(1,0.9,0.2,0.8))
	_r(p,-30*sc,-37*sc,60*sc,4*sc,Color(c.r,c.g,c.b,0.3))

func _draw_ransom_rex(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-5*sc,55*sc,45*sc,c); _r(p,-20*sc,-42*sc,45*sc,40*sc,c)
	_r(p,-18*sc,-18*sc,40*sc,15*sc,_dk(c,0.2))
	for i in 5: _r(p,(-15+i*8)*sc,-20*sc,5*sc,6*sc,Color(0.95,0.95,0.9))
	_r(p,-14*sc,-38*sc,14*sc,14*sc,Color(0.1,0.05,0.05)); _r(p,-10*sc,-35*sc,8*sc,8*sc,Color(0.9,0.1,0.1))
	_r(p,-8*sc,-33*sc,4*sc,4*sc,Color(1,0.5,0.5))
	for i in 4: _r(p,(-20+i*12)*sc,5*sc,10*sc,8*sc,Color(0.7,0.6,0.2)); _r(p,(-16+i*12)*sc,2*sc,2*sc,14*sc,Color(0.7,0.6,0.2))
	_r(p,-22*sc,38*sc,18*sc,16*sc,_dk(c)); _r(p,6*sc,38*sc,18*sc,16*sc,_dk(c))
	_r(p,-42*sc,8*sc,16*sc,10*sc,c); _r(p,-54*sc,15*sc,14*sc,8*sc,_dk(c))

func _draw_worm_ling(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-16*sc,-38*sc,32*sc,28*sc,c)
	_r(p,-10*sc,-32*sc,8*sc,8*sc,Color(0.1,0.1,0.1)); _r(p,2*sc,-32*sc,8*sc,8*sc,Color(0.1,0.1,0.1))
	_r(p,-7*sc,-30*sc,4*sc,4*sc,Color(1,0.3,0.3)); _r(p,5*sc,-30*sc,4*sc,4*sc,Color(1,0.3,0.3))
	for i in 5:
		var br = 1.0 - i * 0.1
		_r(p,(-14+i*2)*sc,(-12+i*10)*sc,(28-i*4)*sc,12*sc,Color(c.r*br,c.g*br,c.b*br))
		_r(p,(-14+i*2)*sc,(-2+i*10)*sc,(28-i*4)*sc,2*sc,_dk(c,0.3))
	_r(p,20*sc,-10*sc,10*sc,8*sc,_lt(c,0.1)); _r(p,22*sc,-18*sc,8*sc,10*sc,_lt(c,0.1)); _r(p,-32*sc,5*sc,10*sc,8*sc,_lt(c,0.1))

func _draw_patchwork(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-10*sc,56*sc,48*sc,c); _r(p,-22*sc,-38*sc,44*sc,32*sc,c)
	_r(p,-26*sc,-48*sc,16*sc,16*sc,c); _r(p,10*sc,-48*sc,16*sc,16*sc,c)
	_r(p,-22*sc,-46*sc,10*sc,10*sc,_lt(c,0.2)); _r(p,12*sc,-46*sc,10*sc,10*sc,_lt(c,0.2))
	_r(p,-10*sc,-28*sc,20*sc,14*sc,_lt(c,0.3))
	_r(p,-14*sc,-34*sc,8*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,6*sc,-34*sc,8*sc,8*sc,Color(0.1,0.1,0.15))
	_r(p,-22*sc,-5*sc,16*sc,14*sc,_dk(c,0.2)); _r(p,6*sc,5*sc,14*sc,12*sc,_lt(c,0.2))
	_r(p,-10*sc,18*sc,18*sc,14*sc,_dk(c,0.15)); _r(p,14*sc,-10*sc,12*sc,12*sc,_lt(c,0.3))
	_r(p,-22*sc,-5*sc,16*sc,1*sc,Color(1,1,1,0.2)); _r(p,-22*sc,8*sc,16*sc,1*sc,Color(1,1,1,0.2))
	_r(p,-24*sc,36*sc,18*sc,14*sc,_dk(c,0.2)); _r(p,6*sc,36*sc,18*sc,14*sc,_dk(c,0.2))

func _draw_bastion(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-40*sc,56*sc,70*sc,_dk(c,0.2)); _r(p,-24*sc,-36*sc,48*sc,62*sc,c)
	_r(p,-14*sc,-22*sc,28*sc,36*sc,_lt(c,0.15))
	_r(p,-4*sc,-32*sc,8*sc,56*sc,Color(1,1,1,0.1)); _r(p,-18*sc,-8*sc,36*sc,8*sc,Color(1,1,1,0.1))
	_r(p,-16*sc,-50*sc,32*sc,14*sc,_dk(c,0.3)); _r(p,-10*sc,-58*sc,20*sc,12*sc,_dk(c,0.4))
	_r(p,-14*sc,-46*sc,28*sc,6*sc,Color(0.1,0.8,1,0.6))
	_r(p,-40*sc,-30*sc,14*sc,24*sc,_dk(c,0.1)); _r(p,26*sc,-30*sc,14*sc,24*sc,_dk(c,0.1))
	_r(p,-20*sc,28*sc,14*sc,18*sc,_dk(c,0.2)); _r(p,6*sc,28*sc,14*sc,18*sc,_dk(c,0.2))
	_r(p,-20*sc,-34*sc,18*sc,8*sc,Color(1,1,1,0.2))

func _draw_daemon_x(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-22*sc,-8*sc,44*sc,46*sc,Color(c.r*0.4,c.g*0.4,c.b*0.4))
	_r(p,-18*sc,-5*sc,36*sc,40*sc,Color(c.r*0.6,c.g*0.6,c.b*0.6))
	_r(p,-16*sc,-32*sc,32*sc,26*sc,Color(c.r*0.5,c.g*0.5,c.b*0.5))
	_r(p,-12*sc,2*sc,24*sc,24*sc,_dk(c,0.4)); _r(p,-8*sc,6*sc,16*sc,16*sc,c); _r(p,-4*sc,10*sc,8*sc,8*sc,_lt(c))
	_r(p,-16*sc,14*sc,8*sc,2*sc,Color(c.r,c.g,c.b,0.5)); _r(p,8*sc,14*sc,8*sc,2*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-2*sc,-8*sc,4*sc,12*sc,Color(c.r,c.g,c.b,0.5)); _r(p,-2*sc,26*sc,4*sc,12*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-12*sc,-26*sc,10*sc,8*sc,c); _r(p,2*sc,-26*sc,10*sc,8*sc,c)
	_r(p,-9*sc,-24*sc,5*sc,4*sc,Color(1,1,1,0.8)); _r(p,5*sc,-24*sc,5*sc,4*sc,Color(1,1,1,0.8))
	_r(p,-36*sc,0*sc,16*sc,10*sc,Color(c.r*0.4,c.g*0.4,c.b*0.4)); _r(p,20*sc,0*sc,16*sc,10*sc,Color(c.r*0.4,c.g*0.4,c.b*0.4))

func _draw_bios_wraith(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-24*sc,10*sc,10*sc,28*sc,Color(c.r,c.g,c.b,0.5)); _r(p,-10*sc,15*sc,10*sc,32*sc,Color(c.r,c.g,c.b,0.6))
	_r(p,4*sc,12*sc,10*sc,30*sc,Color(c.r,c.g,c.b,0.5)); _r(p,18*sc,8*sc,10*sc,26*sc,Color(c.r,c.g,c.b,0.4))
	_r(p,-26*sc,-28*sc,52*sc,42*sc,c); _r(p,-22*sc,-24*sc,44*sc,34*sc,Color(c.r*0.7,c.g*0.7,c.b*0.7,0.5))
	_r(p,-20*sc,-10*sc,40*sc,2*sc,Color(1,0.9,0.3,0.4))
	_r(p,-8*sc,-24*sc,2*sc,30*sc,Color(1,0.9,0.3,0.4)); _r(p,6*sc,-24*sc,2*sc,20*sc,Color(1,0.9,0.3,0.4))
	_r(p,-20*sc,4*sc,20*sc,2*sc,Color(1,0.9,0.3,0.4))
	_r(p,-12*sc,-22*sc,24*sc,18*sc,Color(0.1,0.1,0.1)); _r(p,-8*sc,-18*sc,16*sc,10*sc,Color(0.2,0.8,0.4))
	_r(p,-14*sc,-24*sc,10*sc,6*sc,_lt(c)); _r(p,4*sc,-24*sc,10*sc,6*sc,_lt(c))

func _draw_vish_ara(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-8*sc,5*sc,18*sc,14*sc,c); _r(p,-6*sc,18*sc,16*sc,12*sc,_dk(c,0.1))
	_r(p,-10*sc,28*sc,20*sc,12*sc,c); _r(p,-8*sc,38*sc,16*sc,10*sc,_dk(c,0.1))
	_r(p,-18*sc,-35*sc,36*sc,42*sc,c); _r(p,-30*sc,-28*sc,60*sc,20*sc,_dk(c,0.1))
	_r(p,-28*sc,-20*sc,56*sc,10*sc,Color(c.r,c.g,c.b,0.7)); _r(p,-24*sc,-26*sc,48*sc,4*sc,Color(1,1,1,0.1))
	_r(p,-10*sc,-28*sc,10*sc,10*sc,Color(0.8,0.1,0.1)); _r(p,0*sc,-28*sc,10*sc,10*sc,Color(0.8,0.1,0.1))
	_r(p,-7*sc,-26*sc,5*sc,5*sc,Color(0.05,0.05,0.05)); _r(p,3*sc,-26*sc,5*sc,5*sc,Color(0.05,0.05,0.05))
	_r(p,-2*sc,-10*sc,4*sc,16*sc,Color(1,0.3,0.3)); _r(p,-6*sc,4*sc,4*sc,8*sc,Color(1,0.2,0.2)); _r(p,2*sc,4*sc,4*sc,8*sc,Color(1,0.2,0.2))
	_r(p,-14*sc,-18*sc,6*sc,6*sc,_dk(c,0.4)); _r(p,8*sc,-18*sc,6*sc,6*sc,_dk(c,0.4))

func _draw_bait_eel(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-10*sc,-10*sc,22*sc,14*sc,c); _r(p,-14*sc,2*sc,22*sc,12*sc,_dk(c,0.1))
	_r(p,-8*sc,12*sc,22*sc,12*sc,c); _r(p,-12*sc,22*sc,20*sc,12*sc,_dk(c,0.1)); _r(p,-6*sc,32*sc,16*sc,12*sc,c)
	_r(p,-18*sc,-32*sc,36*sc,24*sc,c); _r(p,-16*sc,-16*sc,32*sc,8*sc,_dk(c,0.4))
	for i in 4: _r(p,(-12+i*8)*sc,-16*sc,4*sc,5*sc,Color(0.9,0.9,0.85))
	_r(p,-12*sc,-28*sc,12*sc,12*sc,Color(0.8,0.7,0.1)); _r(p,0*sc,-28*sc,12*sc,12*sc,Color(0.8,0.7,0.1))
	_r(p,-9*sc,-26*sc,6*sc,6*sc,Color(0.1,0.1,0.1)); _r(p,3*sc,-26*sc,6*sc,6*sc,Color(0.1,0.1,0.1))
	_r(p,-2*sc,-48*sc,4*sc,18*sc,_dk(c,0.3)); _r(p,-8*sc,-56*sc,16*sc,10*sc,Color(1,0.9,0.2))
	_r(p,-5*sc,-54*sc,10*sc,6*sc,Color(1,1,0.5,0.8))
	_r(p,10*sc,-5*sc,18*sc,6*sc,Color(c.r,c.g,c.b,0.6)); _r(p,14*sc,8*sc,14*sc,5*sc,Color(c.r,c.g,c.b,0.5))

# ══════════════════════════════════════════════
#  NEW 12 SENTINELS
# ══════════════════════════════════════════════

func _draw_hash_hound(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-22*sc,-10*sc,44*sc,36*sc,c); _r(p,-18*sc,-38*sc,36*sc,30*sc,c)
	_r(p,-22*sc,-52*sc,12*sc,16*sc,_dk(c)); _r(p,10*sc,-52*sc,12*sc,16*sc,_dk(c))
	_r(p,-12*sc,-34*sc,8*sc,2*sc,Color(0.1,0.1,0.2)); _r(p,-12*sc,-30*sc,8*sc,2*sc,Color(0.1,0.1,0.2))
	_r(p,-10*sc,-36*sc,2*sc,8*sc,Color(0.1,0.1,0.2)); _r(p,-6*sc,-36*sc,2*sc,8*sc,Color(0.1,0.1,0.2))
	_r(p,4*sc,-34*sc,8*sc,2*sc,Color(0.1,0.1,0.2)); _r(p,4*sc,-30*sc,8*sc,2*sc,Color(0.1,0.1,0.2))
	_r(p,6*sc,-36*sc,2*sc,8*sc,Color(0.1,0.1,0.2)); _r(p,10*sc,-36*sc,2*sc,8*sc,Color(0.1,0.1,0.2))
	_r(p,-8*sc,-20*sc,16*sc,10*sc,_lt(c,0.3))
	_r(p,-20*sc,24*sc,12*sc,16*sc,_dk(c)); _r(p,-4*sc,24*sc,12*sc,16*sc,_dk(c)); _r(p,12*sc,24*sc,12*sc,16*sc,_dk(c))
	_r(p,24*sc,-15*sc,10*sc,10*sc,Color(c.r,c.g,c.b,0.4)); _r(p,-34*sc,-10*sc,10*sc,10*sc,Color(c.r,c.g,c.b,0.4))
	_r(p,22*sc,5*sc,8*sc,6*sc,c); _r(p,28*sc,-2*sc,6*sc,8*sc,c)
	_r(p,-16*sc,-36*sc,10*sc,4*sc,Color(1,1,1,0.2))

func _draw_key_lynx(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-16*sc,-8*sc,32*sc,30*sc,c); _r(p,-18*sc,-36*sc,36*sc,30*sc,c)
	_r(p,-20*sc,-52*sc,10*sc,18*sc,c); _r(p,-18*sc,-56*sc,6*sc,8*sc,_dk(c))
	_r(p,10*sc,-52*sc,10*sc,18*sc,c); _r(p,12*sc,-56*sc,6*sc,8*sc,_dk(c))
	_r(p,-14*sc,-32*sc,10*sc,5*sc,Color(0.9,0.7,0.1)); _r(p,4*sc,-32*sc,10*sc,5*sc,Color(0.9,0.7,0.1))
	_r(p,-11*sc,-30*sc,5*sc,3*sc,Color(0.1,0.05,0.2)); _r(p,6*sc,-30*sc,5*sc,3*sc,Color(0.1,0.05,0.2))
	_r(p,-6*sc,-22*sc,12*sc,8*sc,_lt(c,0.3))
	_r(p,-14*sc,20*sc,8*sc,18*sc,_dk(c)); _r(p,6*sc,20*sc,8*sc,18*sc,_dk(c))
	_r(p,16*sc,-4*sc,6*sc,28*sc,Color(1,0.85,0.2)); _r(p,12*sc,20*sc,14*sc,8*sc,Color(1,0.85,0.2))
	_r(p,20*sc,28*sc,6*sc,6*sc,Color(1,0.75,0.1))
	_r(p,-28*sc,-20*sc,6*sc,6*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-16*sc,-34*sc,10*sc,4*sc,Color(1,1,1,0.2))

func _draw_signal_snail(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-16*sc,5*sc,32*sc,24*sc,c); _r(p,10*sc,-10*sc,24*sc,20*sc,c)
	_r(p,16*sc,-26*sc,4*sc,18*sc,_dk(c)); _r(p,14*sc,-30*sc,8*sc,6*sc,Color(1,1,1,0.8))
	_r(p,24*sc,-22*sc,4*sc,14*sc,_dk(c)); _r(p,22*sc,-26*sc,8*sc,6*sc,Color(1,1,1,0.7))
	_r(p,12*sc,-8*sc,7*sc,7*sc,Color(0.1,0.1,0.2)); _r(p,14*sc,-6*sc,3*sc,3*sc,Color(1,1,1,0.5))
	_r(p,-28*sc,-20*sc,36*sc,36*sc,_dk(c,0.1)); _r(p,-24*sc,-16*sc,28*sc,28*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-18*sc,-10*sc,16*sc,16*sc,_dk(c,0.3)); _r(p,-14*sc,-6*sc,8*sc,8*sc,c)
	_r(p,-28*sc,-6*sc,28*sc,3*sc,Color(1,1,1,0.15)); _r(p,-14*sc,-16*sc,3*sc,16*sc,Color(1,1,1,0.15))
	_r(p,-14*sc,26*sc,8*sc,10*sc,_dk(c)); _r(p,-2*sc,26*sc,8*sc,10*sc,_dk(c)); _r(p,10*sc,24*sc,8*sc,10*sc,_dk(c))
	_r(p,-26*sc,-18*sc,12*sc,4*sc,Color(1,1,1,0.2))

func _draw_warp_wolf(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-20*sc,-5*sc,40*sc,30*sc,c); _r(p,-16*sc,-32*sc,32*sc,28*sc,c); _r(p,10*sc,-28*sc,22*sc,14*sc,_dk(c,0.1))
	_r(p,-18*sc,-48*sc,10*sc,18*sc,c); _r(p,8*sc,-48*sc,10*sc,18*sc,c)
	_r(p,-12*sc,-28*sc,10*sc,5*sc,Color(0.2,0.9,1.0)); _r(p,2*sc,-28*sc,10*sc,5*sc,Color(0.2,0.9,1.0))
	_r(p,-18*sc,22*sc,10*sc,18*sc,_dk(c)); _r(p,-4*sc,22*sc,10*sc,18*sc,_dk(c)); _r(p,10*sc,22*sc,10*sc,18*sc,_dk(c))
	_r(p,-38*sc,5*sc,20*sc,6*sc,Color(c.r,c.g,c.b,0.7)); _r(p,-48*sc,8*sc,12*sc,4*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-55*sc,10*sc,8*sc,3*sc,Color(c.r,c.g,c.b,0.3))
	_r(p,-18*sc,5*sc,36*sc,2*sc,Color(1,1,1,0.25)); _r(p,0*sc,-32*sc,2*sc,32*sc,Color(1,1,1,0.2))
	_r(p,-14*sc,-30*sc,12*sc,4*sc,Color(1,1,1,0.2))

func _draw_logic_leech(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-14*sc,-30*sc,28*sc,22*sc,c); _r(p,-16*sc,-10*sc,32*sc,22*sc,c)
	_r(p,-14*sc,10*sc,28*sc,20*sc,_dk(c,0.15)); _r(p,-12*sc,28*sc,24*sc,14*sc,_dk(c,0.25))
	_r(p,-16*sc,-10*sc,32*sc,2*sc,_dk(c,0.5)); _r(p,-14*sc,10*sc,28*sc,2*sc,_dk(c,0.5))
	_r(p,-12*sc,-46*sc,24*sc,18*sc,c)
	_r(p,-8*sc,-44*sc,16*sc,6*sc,Color(0.05,0.05,0.1))
	_r(p,-10*sc,-40*sc,4*sc,4*sc,Color(1,0.3,0.3)); _r(p,-2*sc,-40*sc,4*sc,4*sc,Color(1,0.3,0.3)); _r(p,6*sc,-40*sc,4*sc,4*sc,Color(1,0.3,0.3))
	_r(p,-8*sc,-46*sc,8*sc,6*sc,Color(0.8,0.1,0.1)); _r(p,2*sc,-46*sc,8*sc,6*sc,Color(0.8,0.1,0.1))
	_r(p,-6*sc,40*sc,4*sc,10*sc,Color(c.r,c.g,c.b,0.5))
	_r(p,-10*sc,-44*sc,8*sc,3*sc,Color(1,1,1,0.15))

func _draw_trojan_taurus(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-28*sc,-5*sc,56*sc,44*sc,c); _r(p,-22*sc,-40*sc,44*sc,36*sc,c)
	_r(p,-28*sc,-52*sc,8*sc,14*sc,_dk(c,0.2)); _r(p,-32*sc,-58*sc,8*sc,8*sc,_dk(c,0.3))
	_r(p,20*sc,-52*sc,8*sc,14*sc,_dk(c,0.2)); _r(p,24*sc,-58*sc,8*sc,8*sc,_dk(c,0.3))
	_r(p,-14*sc,-24*sc,28*sc,16*sc,_dk(c,0.1))
	_r(p,-6*sc,-22*sc,6*sc,6*sc,Color(0.2,0.1,0.1)); _r(p,2*sc,-22*sc,6*sc,6*sc,Color(0.2,0.1,0.1))
	_r(p,-16*sc,-36*sc,10*sc,8*sc,Color(0.9,0.1,0.1)); _r(p,6*sc,-36*sc,10*sc,8*sc,Color(0.9,0.1,0.1))
	_r(p,-16*sc,2*sc,32*sc,28*sc,_dk(c,0.4))
	_r(p,-12*sc,6*sc,24*sc,20*sc,Color(0.9,0.1,0.1,0.8)); _r(p,-8*sc,10*sc,16*sc,12*sc,Color(1,0.3,0.3,0.9))
	_r(p,-4*sc,13*sc,8*sc,6*sc,Color(1,0.6,0.6))
	_r(p,-24*sc,38*sc,16*sc,16*sc,_dk(c)); _r(p,8*sc,38*sc,16*sc,16*sc,_dk(c))
	_r(p,-20*sc,-38*sc,16*sc,5*sc,Color(1,1,1,0.15))

func _draw_brick_bear(p: Node, c: Color, s: float):
	var sc = s / 80.0
	for row in 3:
		for col in 3:
			var bx = (-24 + col * 16)*sc; var by = (-5 + row * 16)*sc
			var br = 1.0 - (row * 0.1 + col * 0.05)
			_r(p,bx,by,14*sc,14*sc,Color(c.r*br,c.g*br,c.b*br))
			_r(p,bx,by,14*sc,1*sc,Color(1,1,1,0.1)); _r(p,bx,by,1*sc,14*sc,Color(1,1,1,0.1))
	_r(p,-22*sc,-38*sc,44*sc,34*sc,c)
	_r(p,-26*sc,-46*sc,14*sc,12*sc,c); _r(p,12*sc,-46*sc,14*sc,12*sc,c)
	_r(p,-24*sc,-44*sc,10*sc,8*sc,_lt(c,0.15)); _r(p,14*sc,-44*sc,10*sc,8*sc,_lt(c,0.15))
	_r(p,-10*sc,-28*sc,20*sc,12*sc,_lt(c,0.2))
	_r(p,-14*sc,-34*sc,8*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,6*sc,-34*sc,8*sc,8*sc,Color(0.1,0.1,0.15))
	_r(p,-22*sc,44*sc,16*sc,12*sc,_dk(c)); _r(p,6*sc,44*sc,16*sc,12*sc,_dk(c))
	_r(p,-24*sc,10*sc,48*sc,2*sc,Color(0,0,0,0.3)); _r(p,-24*sc,26*sc,48*sc,2*sc,Color(0,0,0,0.3))
	_r(p,-20*sc,-36*sc,16*sc,5*sc,Color(1,1,1,0.2))

func _draw_gate_gorilla(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-30*sc,-5*sc,60*sc,48*sc,c); _r(p,-24*sc,-40*sc,48*sc,36*sc,c)
	_r(p,-26*sc,-48*sc,52*sc,12*sc,_dk(c,0.2))
	_r(p,-14*sc,-38*sc,10*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,-10*sc,-36*sc,5*sc,5*sc,Color(0.2,0.8,0.3))
	_r(p,4*sc,-38*sc,10*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,8*sc,-36*sc,5*sc,5*sc,Color(0.2,0.8,0.3))
	_r(p,-12*sc,-26*sc,24*sc,16*sc,_dk(c,0.1))
	_r(p,-58*sc,-20*sc,30*sc,48*sc,_dk(c,0.15)); _r(p,-56*sc,-18*sc,26*sc,44*sc,c)
	_r(p,-52*sc,-8*sc,18*sc,18*sc,_dk(c,0.4)); _r(p,-50*sc,-6*sc,14*sc,14*sc,_lt(c,0.1))
	_r(p,-52*sc,0*sc,18*sc,2*sc,_dk(c,0.6)); _r(p,-44*sc,-8*sc,2*sc,18*sc,_dk(c,0.6))
	_r(p,28*sc,-20*sc,30*sc,48*sc,_dk(c,0.15)); _r(p,30*sc,-18*sc,26*sc,44*sc,c)
	_r(p,30*sc,-14*sc,6*sc,8*sc,_dk(c,0.5)); _r(p,30*sc,10*sc,6*sc,8*sc,_dk(c,0.5))
	_r(p,-26*sc,42*sc,18*sc,14*sc,_dk(c)); _r(p,8*sc,42*sc,18*sc,14*sc,_dk(c))
	_r(p,-22*sc,-38*sc,20*sc,6*sc,Color(1,1,1,0.15))

func _draw_phish_falcon(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-14*sc,-10*sc,28*sc,30*sc,c); _r(p,-12*sc,-34*sc,24*sc,26*sc,c)
	_r(p,8*sc,-28*sc,14*sc,6*sc,Color(1,0.8,0.2)); _r(p,18*sc,-24*sc,6*sc,10*sc,Color(1,0.7,0.1))
	_r(p,12*sc,-16*sc,10*sc,4*sc,Color(1,0.7,0.1))
	_r(p,-8*sc,-30*sc,10*sc,7*sc,Color(0.1,0.05,0.2)); _r(p,-5*sc,-28*sc,5*sc,4*sc,Color(1,0.9,0.2))
	_r(p,-44*sc,-18*sc,32*sc,8*sc,c); _r(p,-50*sc,-10*sc,24*sc,6*sc,Color(c.r*0.8,c.g*0.8,c.b*0.8,0.8))
	_r(p,-46*sc,-26*sc,20*sc,6*sc,Color(c.r,c.g*0.6,c.b*0.6,0.9))
	_r(p,-40*sc,-20*sc,8*sc,3*sc,Color(1,0.9,0.2,0.8)); _r(p,-36*sc,-14*sc,6*sc,3*sc,Color(1,0.4,0.8,0.7))
	_r(p,12*sc,-18*sc,32*sc,8*sc,c); _r(p,26*sc,-10*sc,24*sc,6*sc,Color(c.r*0.8,c.g*0.8,c.b*0.8,0.8))
	_r(p,-12*sc,18*sc,10*sc,14*sc,_dk(c)); _r(p,2*sc,18*sc,10*sc,14*sc,_dk(c))
	_r(p,-10*sc,-32*sc,10*sc,4*sc,Color(1,1,1,0.2))

func _draw_scam_serpent(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-10*sc,-8*sc,20*sc,14*sc,c); _r(p,-14*sc,4*sc,20*sc,12*sc,_dk(c,0.1))
	_r(p,-8*sc,14*sc,20*sc,12*sc,c); _r(p,-12*sc,24*sc,18*sc,10*sc,_dk(c,0.1)); _r(p,-6*sc,32*sc,14*sc,10*sc,c)
	_r(p,-16*sc,-32*sc,32*sc,26*sc,c)
	_r(p,-14*sc,-28*sc,8*sc,6*sc,_lt(c,0.2)); _r(p,-2*sc,-24*sc,8*sc,6*sc,_lt(c,0.2)); _r(p,6*sc,-28*sc,8*sc,6*sc,_lt(c,0.2))
	_r(p,-12*sc,-28*sc,8*sc,8*sc,Color(0.9,0.1,0.5)); _r(p,-9*sc,-26*sc,4*sc,4*sc,Color(0.1,0.1,0.1))
	_r(p,4*sc,-28*sc,8*sc,8*sc,Color(0.9,0.1,0.5)); _r(p,7*sc,-26*sc,4*sc,4*sc,Color(0.1,0.1,0.1))
	_r(p,-2*sc,-8*sc,4*sc,14*sc,Color(1,0.3,0.5))
	_r(p,-6*sc,4*sc,4*sc,8*sc,Color(1,0.2,0.4)); _r(p,2*sc,4*sc,4*sc,8*sc,Color(1,0.2,0.4))
	_r(p,20*sc,-20*sc,18*sc,12*sc,Color(1,0.9,0.2,0.7)); _r(p,22*sc,-18*sc,6*sc,6*sc,Color(0.9,0.1,0.1,0.8))
	_r(p,-36*sc,-14*sc,16*sc,10*sc,Color(1,0.9,0.2,0.6))
	_r(p,-14*sc,-30*sc,10*sc,4*sc,Color(1,1,1,0.15))

func _draw_sentry_stinger(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-14*sc,-8*sc,28*sc,20*sc,c); _r(p,-10*sc,10*sc,20*sc,18*sc,_dk(c,0.15))
	_r(p,-8*sc,26*sc,16*sc,12*sc,Color(c.r,c.g,c.b,0.8))
	_r(p,-10*sc,28*sc,20*sc,2*sc,Color(1,0.9,0.2,0.6)); _r(p,-10*sc,32*sc,20*sc,2*sc,Color(1,0.9,0.2,0.6))
	_r(p,-16*sc,-34*sc,32*sc,28*sc,c)
	for row in 2:
		for col in 3:
			var ex = (-12+col*8)*sc; var ey = (-32+row*8)*sc
			_r(p,ex,ey,7*sc,7*sc,Color(0.05,0.05,0.1)); _r(p,ex+2*sc,ey+2*sc,3*sc,3*sc,Color(0.2,0.8,0.3))
	_r(p,-4*sc,36*sc,8*sc,18*sc,_dk(c,0.2)); _r(p,-2*sc,50*sc,4*sc,8*sc,_dk(c,0.5))
	_r(p,-36*sc,-14*sc,22*sc,8*sc,Color(c.r,c.g,c.b,0.35)); _r(p,-34*sc,-6*sc,18*sc,5*sc,Color(c.r,c.g,c.b,0.25))
	_r(p,14*sc,-14*sc,22*sc,8*sc,Color(c.r,c.g,c.b,0.35)); _r(p,16*sc,-6*sc,18*sc,5*sc,Color(c.r,c.g,c.b,0.25))
	_r(p,-10*sc,-44*sc,3*sc,12*sc,_dk(c)); _r(p,8*sc,-44*sc,3*sc,12*sc,_dk(c))
	_r(p,-14*sc,-46*sc,8*sc,4*sc,Color(0.2,0.9,0.3)); _r(p,8*sc,-46*sc,8*sc,4*sc,Color(0.2,0.9,0.3))
	_r(p,-14*sc,-32*sc,12*sc,4*sc,Color(1,1,1,0.2))

func _draw_radar_rhino(p: Node, c: Color, s: float):
	var sc = s / 80.0
	_r(p,-30*sc,-5*sc,60*sc,44*sc,c); _r(p,-24*sc,-38*sc,48*sc,34*sc,c)
	_r(p,10*sc,-30*sc,32*sc,18*sc,_dk(c,0.1))
	_r(p,-8*sc,-56*sc,16*sc,20*sc,_dk(c,0.3))
	_r(p,-20*sc,-72*sc,40*sc,18*sc,_dk(c,0.2)); _r(p,-16*sc,-68*sc,32*sc,12*sc,Color(c.r,c.g,c.b,0.6))
	_r(p,-12*sc,-64*sc,24*sc,8*sc,Color(c.r,c.g,c.b,0.8))
	_r(p,-22*sc,-76*sc,44*sc,2*sc,Color(c.r,c.g,c.b,0.3)); _r(p,-26*sc,-80*sc,52*sc,2*sc,Color(c.r,c.g,c.b,0.2))
	_r(p,-18*sc,-34*sc,10*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,-14*sc,-32*sc,5*sc,5*sc,Color(0.2,0.9,0.3))
	_r(p,8*sc,-34*sc,10*sc,8*sc,Color(0.1,0.1,0.15)); _r(p,12*sc,-32*sc,5*sc,5*sc,Color(0.2,0.9,0.3))
	_r(p,-28*sc,-32*sc,8*sc,12*sc,_dk(c,0.2))
	_r(p,-26*sc,38*sc,16*sc,16*sc,_dk(c)); _r(p,-4*sc,38*sc,16*sc,16*sc,_dk(c)); _r(p,14*sc,38*sc,16*sc,16*sc,_dk(c))
	_r(p,-34*sc,8*sc,6*sc,10*sc,_dk(c))
	_r(p,-28*sc,15*sc,56*sc,2*sc,Color(c.r,c.g,c.b,0.3)); _r(p,0*sc,-5*sc,2*sc,44*sc,Color(c.r,c.g,c.b,0.2))
	_r(p,-22*sc,-36*sc,18*sc,5*sc,Color(1,1,1,0.15))

func _draw_default(p: Node, c: Color, s: float):
	_r(p,-s/2,-s/2,s,s,c); _r(p,-s/2,-s/2,s*0.4,s*0.2,Color(1,1,1,0.2))
