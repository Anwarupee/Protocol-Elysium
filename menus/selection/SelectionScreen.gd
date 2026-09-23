extends Node2D

var selected_monster: String = ""
var active_tab: String = "Crypto"
var card_nodes = []
var tab_buttons = {}
var cards_container: Node2D
var confirm_btn: Button
var map_btn: Button
var detail_labels = {}
var detail_panel: Node2D
var particles: Array = []
var time: float = 0.0
var card_w = 220  # Disesuaikan agar 5 kartu pas di sebelah kiri detail panel

var monsters_info = [
	# ── CRYPTO ──
	{
		"id": "encryp_pup", "name": "ENCRYP-PUP", "type": "Crypto",
		"color": Color(0.3, 0.9, 1.0), "hp": 120, "speed": 60, "role": "Defender",
		"desc": "Anjing gembok yang tangguh. Makin kuat saat diserang.",
		"moves": ["Encrypt", "Firewall Bark", "Backup Howl", "SSL Handshake"]
	},
	{
		"id": "vaultex", "name": "VAULTEX", "type": "Crypto",
		"color": Color(0.5, 0.85, 1), "hp": 130, "speed": 45, "role": "Support",
		"desc": "Brankas digital berjalan. Tidak akan terbuka kecuali menerima hash key yang tepat.",
		"moves": ["Hash Lock", "Integrity Check", "Data Shred", "Mirror Backup"]
	},
	{
		"id": "cipher_ray", "name": "CIPHER-RAY", "type": "Crypto",
		"color": Color(0.6, 0.9, 1), "hp": 100, "speed": 80, "role": "Attacker",
		"desc": "Elang kristal predator data tak terenkripsi di lapisan Upper-Net.",
		"moves": ["Brute Decrypt", "Key Exchange", "Cipher Strike", "Zero-Knowledge"]
	},
	{
		"id": "hash_hound", "name": "HASH-HOUND", "type": "Crypto",
		"color": Color(0.2, 0.8, 0.9), "hp": 100, "speed": 65, "role": "Scout",
		"desc": "Anjing pelacak integritas data. Ia mengendus setiap perubahan bit yang mencurigakan.",
		"moves": ["Hash Bite", "Checksum", "Integrity Scan", "SHA Strike"]
	},
	{
		"id": "key_lynx", "name": "KEY-LYNX", "type": "Crypto",
		"color": Color(0.4, 1.0, 0.9), "hp": 95, "speed": 90, "role": "Breaker",
		"desc": "Lynx liar penjaga kunci asimetris. Serangan kriptografisnya menembus pertahanan identitas.",
		"moves": ["Key Exchange", "PKI Slash", "Asymmetric Guard", "Cipher Claw"]
	},
	# ── NETWORK ──
	{
		"id": "ping_go", "name": "PING-GO", "type": "Network",
		"color": Color(1, 0.9, 0.3), "hp": 90, "speed": 100, "role": "Speedster",
		"desc": "Burung puyuh super cepat. Selalu menyerang duluan.",
		"moves": ["Packet Dash", "Traceroute", "DDoS Feathers", "Ping Flood"]
	},
	{
		"id": "routerex", "name": "ROUTEREX", "type": "Network",
		"color": Color(1, 0.85, 0.2), "hp": 105, "speed": 65, "role": "Controller",
		"desc": "Dinosaurus gateway yang membelokkan serangan ke jalur buntu.",
		"moves": ["NAT Punch", "Port Scan", "Bandwidth Throttle", "Reroute"]
	},
	{
		"id": "latencia", "name": "LATENCIA", "type": "Network",
		"color": Color(1, 0.7, 0.1), "hp": 88, "speed": 90, "role": "Speedster",
		"desc": "Ubur-ubur serat optik manifestasi lag jaringan.",
		"moves": ["Timeout Strike", "Packet Loss", "QoS Drain", "Syn Flood"]
	},
	{
		"id": "signal_snail", "name": "SIGNAL-SNAIL", "type": "Network",
		"color": Color(1.0, 0.75, 0.1), "hp": 95, "speed": 45, "role": "Support",
		"desc": "Siput fiber optik yang lambat tapi stabil. Tidak ada paketnya yang pernah hilang di perjalanan.",
		"moves": ["Fiber Tackle", "Packet Preserve", "Latency Shell", "QoS Pulse"]
	},
	{
		"id": "warp_wolf", "name": "WARP-WOLF", "type": "Network",
		"color": Color(1.0, 0.6, 0.0), "hp": 85, "speed": 110, "role": "Speedster",
		"desc": "Serigala broadband yang bergerak lebih cepat dari sinyal itu sendiri.",
		"moves": ["Bandwidth Burst", "Warp Dash", "CDN Strike", "Protocol Override"]
	},
	# ── MALWARE ──
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
		"id": "bios_wraith", "name": "BIOS-WRAITH", "type": "Malware",
		"color": Color(0.7, 0.2, 0.3), "hp": 95, "speed": 55, "role": "Controller",
		"desc": "Roh motherboard kuno pengontrol instruksi paling dasar.",
		"moves": ["BIOS Flash", "Boot Loop", "Overclock", "Firmware Lock"]
	},
	{
		"id": "logic_leech", "name": "LOGIC-LEECH", "type": "Malware",
		"color": Color(0.7, 0.1, 0.3), "hp": 90, "speed": 75, "role": "Drainer",
		"desc": "Lintah kode yang menyedot resource sistem perlahan-lahan tanpa terdeteksi.",
		"moves": ["Logic Drain", "Resource Siphon", "Memory Leech", "System Leech"]
	},
	{
		"id": "trojan_taurus", "name": "TROJAN-TAURUS", "type": "Malware",
		"color": Color(0.9, 0.1, 0.15), "hp": 115, "speed": 55, "role": "Breaker",
		"desc": "Banteng mekanik yang menyembunyikan payload destruktif di balik wujud yang tidak berbahaya.",
		"moves": ["Trojan Charge", "Supply Chain Attack", "Backdoor Install", "Payload Detonate"]
	},
	# ── FIREWALL ──
	{
		"id": "biti", "name": "BITI", "type": "Firewall",
		"color": Color(0.2, 0.5, 1.0), "hp": 95, "speed": 80, "role": "Strategist",
		"desc": "Unit terkecil dari pertahanan Elysium. Ribuan Biti bersatu membentuk dinding yang tak tertembus.",
		"moves": ["Mimic Byte", "Inject", "Trojan Gift", "Rootkit Hide"]
	},
	{
		"id": "octo_core", "name": "OCTO-CORE", "type": "Firewall",
		"color": Color(0.3, 0.4, 1.0), "hp": 110, "speed": 70, "role": "Controller",
		"desc": "Gurita CPU yang menguasai kernel. Berbahaya bahkan saat kalah.",
		"moves": ["Memory Overflow", "Process Kill", "System Hijack", "Fork Bomb"]
	},
	{
		"id": "bastion", "name": "BASTION", "type": "Firewall",
		"color": Color(0.15, 0.4, 1.0), "hp": 160, "speed": 35, "role": "Pure Tank",
		"desc": "Ksatria firewall baris pertahanan terakhir mainframe.",
		"moves": ["Perimeter Strike", "Access Denied", "Failover", "Iron Curtain"]
	},
	{
		"id": "brick_bear", "name": "BRICK-BEAR", "type": "Firewall",
		"color": Color(0.15, 0.45, 0.9), "hp": 145, "speed": 40, "role": "Tank",
		"desc": "Beruang yang tersusun dari balok-balok aturan keamanan. Setiap balok adalah satu rule yang tidak boleh dilanggar.",
		"moves": ["Packet Filter", "Rule Block", "Fortify", "Bear Slam"]
	},
	{
		"id": "gate_gorilla", "name": "GATE-GORILLA", "type": "Firewall",
		"color": Color(0.1, 0.35, 0.85), "hp": 170, "speed": 30, "role": "Pure Tank",
		"desc": "Gorilla raksasa penjaga gerbang utama Elysium. Benteng terakhir sebelum core sistem tersentuh.",
		"moves": ["WAF Strike", "Zero Trust Lock", "Perimeter Crush", "Gate Slam"]
	},
	# ── SOCIAL ENGINEERING ──
	{
		"id": "chamele_auth", "name": "CHAMELE-AUTH", "type": "Social Engineering",
		"color": Color(1, 0.7, 0.2), "hp": 95, "speed": 85, "role": "Trickster",
		"desc": "Bunglon piksel yang mencuri identitas. Tidak pernah menyerang langsung.",
		"moves": ["Phishing Cast", "Spoofed Token", "Social Override", "Pretexting"]
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
	},
	{
		"id": "phish_falcon", "name": "PHISH-FALCON", "type": "Social Engineering",
		"color": Color(1.0, 0.55, 0.05), "hp": 88, "speed": 92, "role": "Speedster",
		"desc": "Elang phishing yang mengincar target spesifik dengan presisi mematikan.",
		"moves": ["Spear Dive", "Credential Hook", "Whaling Strike", "Clone Attack"]
	},
	{
		"id": "scam_serpent", "name": "SCAM-SERPENT", "type": "Social Engineering",
		"color": Color(0.9, 0.45, 0.0), "hp": 92, "speed": 82, "role": "Debuffer",
		"desc": "Ular penipu maestro disinformasi yang membuat lawan kebingungan sebelum menyerang.",
		"moves": ["Pretext Strike", "Deepfake Venom", "Impersonation", "Serpent's Charm"]
	},
	# ── MONITOR ──
	{
		"id": "senti_shell", "name": "SENTI-SHELL", "type": "Monitor",
		"color": Color(0.2, 0.9, 0.5), "hp": 150, "speed": 40, "role": "Watcher",
		"desc": "Kura-kura penjaga yang selalu mengawasi. Tidak ada ancaman yang lolos dari pandangannya.",
		"moves": ["Diamond Layer", "Shell Slam", "Immutable Lock", "Restore Point"]
	},
	{
		"id": "patchwork", "name": "PATCHWORK", "type": "Monitor",
		"color": Color(0.1, 0.8, 0.5), "hp": 140, "speed": 50, "role": "Analyst",
		"desc": "Beruang tambalan digital yang menemukan celah sebelum orang lain melihatnya.",
		"moves": ["Patch Deploy", "Vulnerability Scan", "Zero-Day Shield", "Hardened Kernel"]
	},
	{
		"id": "daemon_x", "name": "DAEMON-X", "type": "Monitor",
		"color": Color(0.3, 0.85, 0.4), "hp": 100, "speed": 75, "role": "Analyst",
		"desc": "Entitas background yang memantau setiap proses. Tidak ada anomali yang tersembunyi darinya.",
		"moves": ["Process Inject", "Kill Switch", "Daemon Spawn", "Memory Leak"]
	},
	{
		"id": "sentry_stinger", "name": "SENTRY-STINGER", "type": "Monitor",
		"color": Color(0.15, 0.95, 0.45), "hp": 98, "speed": 78, "role": "Scout",
		"desc": "Tawon pengintai dengan ratusan lensa sensor. Ia mencatat setiap log aktivitas sistem.",
		"moves": ["Log Sting", "Anomaly Alert", "IDS Pulse", "Threat Hunt"]
	},
	{
		"id": "radar_rhino", "name": "RADAR-RHINO", "type": "Monitor",
		"color": Color(0.1, 0.75, 0.35), "hp": 130, "speed": 50, "role": "Controller",
		"desc": "Badak dengan cula antena parabola. Tidak ada sinyal anomali yang luput dari radarnya.",
		"moves": ["SIEM Sweep", "Radar Lock", "Horn Charge", "Full Spectrum Scan"]
	}
]

var type_colors = {
	"Crypto":             Color(0.3, 0.9, 1.0),
	"Network":            Color(1.0, 0.9, 0.2),
	"Malware":            Color(1.0, 0.3, 0.3),
	"Firewall":           Color(0.2, 0.5, 1.0),
	"Social Engineering": Color(1.0, 0.6, 0.1),
	"Monitor":            Color(0.2, 0.9, 0.4)
}

var passive_texts = {
	"encryp_pup":    "Hardened Shell\nDefense naik tiap kena serangan",
	"ping_go":       "Low Latency\nSelalu menyerang duluan",
	"biti":          "Polymorphic\n30% chance serangan lawan miss",
	"senti_shell":   "Redundancy\nBertahan di 1 HP saat pertama kali KO",
	"octo_core":     "Kernel Panic\nDeal 25 damage saat dikalahkan",
	"chamele_auth":  "Identity Theft\n20% chance salin tipe lawan",
	"vaultex":       "Checksum\nJika HP genap di akhir turn, pulihkan 5 HP",
	"cipher_ray":    "AES-256\n20% chance enkripsi diri, kurangi damage masuk",
	"routerex":      "BGP Route\n25% chance redirect serangan lawan -50% damage",
	"latencia":      "Jitter\n30% chance serangan hit dua kali dengan power separuh",
	"ransom_rex":    "Encryption Lock\n25% chance lock heal lawan 2 turn saat menyerang",
	"worm_ling":     "Self-Replicating\nDamage naik 5 tiap kena serangan (max 3 stack)",
	"patchwork":     "Hot Patch\nDamage > 30 masuk, defense naik 1 otomatis",
	"bastion":       "DMZ\nSerangan di bawah 15 damage diabaikan",
	"daemon_x":      "Background Process\n20% chance 10 damage otomatis tiap akhir turn",
	"bios_wraith":   "Legacy Code\n15% chance lawan gagal gunakan move",
	"vish_ara":      "Vishing\n25% chance serangan lawan menyerang diri sendiri",
	"bait_eel":      "Honeypot\n30% chance lawan skip turn jika pakai move power > 60",
	"hash_hound":    "Verificator\nAccuracy naik 1 stage permanen di awal pertarungan",
	"key_lynx":      "Master Key\nKebal terhadap efek status dari tipe Social Engineering",
	"signal_snail":  "Stable Ping\nSerangan tidak pernah miss meski accuracy diturunkan",
	"warp_wolf":     "Overclock\n20% chance menyerang dua kali dalam satu giliran",
	"logic_leech":   "Drainer\nSetiap serangan menyerap 5 HP dari lawan",
	"trojan_taurus": "Last Payload\nSaat dikalahkan, memberikan 30 damage ke lawan",
	"brick_bear":    "Hardened\nMenerima 10% lebih sedikit damage dari semua serangan",
	"gate_gorilla":  "Port Blocker\n15% chance membatalkan serangan berikutnya lawan",
	"phish_falcon":  "Lure\nMenurunkan Defense lawan 1 stage saat pertama masuk arena",
	"scam_serpent":  "Disinformation\n25% chance memberikan status Confused saat serangan mengenai",
	"sentry_stinger":"Deep Scan\nSelalu melihat HP musuh akurat, accuracy +10% permanen",
	"radar_rhino":   "Auto-Alert\nSetiap kali lawan buff, Attack Radar-Rhino naik 1 stage"
}

var advantage_texts = {
	"encryp_pup":    "⚡ Kuat vs Malware\n⚠ Lemah vs Network",
	"vaultex":       "⚡ Kuat vs Malware\n⚠ Lemah vs Network",
	"cipher_ray":    "⚡ Kuat vs Malware\n⚠ Lemah vs Network",
	"hash_hound":    "⚡ Kuat vs Malware\n⚠ Lemah vs Network",
	"key_lynx":      "⚡ Kuat vs Malware\n⚠ Lemah vs Network",
	"ping_go":       "⚡ Kuat vs Crypto\n⚠ Lemah vs Firewall",
	"routerex":      "⚡ Kuat vs Crypto\n⚠ Lemah vs Firewall",
	"latencia":      "⚡ Kuat vs Crypto\n⚠ Lemah vs Firewall",
	"signal_snail":  "⚡ Kuat vs Crypto\n⚠ Lemah vs Firewall",
	"warp_wolf":     "⚡ Kuat vs Crypto\n⚠ Lemah vs Firewall",
	"ransom_rex":    "⚡ Kuat vs Firewall\n⚠ Lemah vs Crypto",
	"worm_ling":     "⚡ Kuat vs Firewall\n⚠ Lemah vs Crypto",
	"bios_wraith":   "⚡ Kuat vs Firewall\n⚠ Lemah vs Crypto",
	"logic_leech":   "⚡ Kuat vs Firewall\n⚠ Lemah vs Crypto",
	"trojan_taurus": "⚡ Kuat vs Firewall\n⚠ Lemah vs Crypto",
	"biti":          "⚡ Kuat vs Network\n⚠ Lemah vs Malware",
	"octo_core":     "⚡ Kuat vs Network\n⚠ Lemah vs Malware",
	"bastion":       "⚡ Kuat vs Network\n⚠ Lemah vs Malware",
	"brick_bear":    "⚡ Kuat vs Network\n⚠ Lemah vs Malware",
	"gate_gorilla":  "⚡ Kuat vs Network\n⚠ Lemah vs Malware",
	"chamele_auth":  "⚡ Kuat vs Crypto\n⚠ Lemah vs Monitor",
	"vish_ara":      "⚡ Kuat vs Crypto\n⚠ Lemah vs Monitor",
	"bait_eel":      "⚡ Kuat vs Crypto\n⚠ Lemah vs Monitor",
	"phish_falcon":  "⚡ Kuat vs Crypto\n⚠ Lemah vs Monitor",
	"scam_serpent":  "⚡ Kuat vs Crypto\n⚠ Lemah vs Monitor",
	"senti_shell":   "⚡ Kuat vs Social Engineering\n⚠ Lemah vs Malware",
	"patchwork":     "⚡ Kuat vs Social Engineering\n⚠ Lemah vs Malware",
	"daemon_x":      "⚡ Kuat vs Social Engineering\n⚠ Lemah vs Malware",
	"sentry_stinger":"⚡ Kuat vs Social Engineering\n⚠ Lemah vs Malware",
	"radar_rhino":   "⚡ Kuat vs Social Engineering\n⚠ Lemah vs Malware"
}

var tips_map = {
	"encryp_pup":    "Biarkan lawan menyerang dulu untuk stack defense, lalu balas dengan SSL Handshake saat sudah terbuff.",
	"ping_go":       "Manfaatkan speed untuk debuff lawan duluan, lalu Ping Flood saat lawan sudah melambat.",
	"biti":          "Gunakan Rootkit Hide untuk menghindari serangan besar, lalu Inject saat lawan sudah terdebuff.",
	"senti_shell":   "Passive Redundancy memberimu satu nyawa ekstra. Jangan takut bermain agresif di akhir.",
	"octo_core":     "Fork Bomb sangat efektif untuk menghabiskan giliran lawan. Biarkan Kernel Panic jadi senjata terakhir.",
	"chamele_auth":  "Gunakan Pretexting untuk guaranteed hit, lalu ikuti dengan Social Override yang menembus defense.",
	"vaultex":       "Jaga HP tetap genap untuk trigger Checksum heal. Mirror Backup bisa mencuri defense buff lawan.",
	"cipher_ray":    "Key Exchange + Cipher Strike adalah combo mematikan vs lawan yang suka buffing defense.",
	"routerex":      "Reroute sangat powerful untuk membalikkan debuff lawan. Gunakan saat sudah kena speed debuff.",
	"latencia":      "Jitter passive bisa trigger double hit saat HP lawan kritis. QoS Drain sangat menyebalkan untuk lawan cepat.",
	"ransom_rex":    "File Encrypt + Ransom Note memastikan lawan tidak bisa heal sambil kena DoT. Mematikan vs tank.",
	"worm_ling":     "Biarkan lawan menyerang untuk stack Self-Replicating. Mass Infection di stack 3 sangat mematikan.",
	"patchwork":     "Zero-Day Shield adalah counter sempurna untuk serangan besar. Simpan untuk momen kritis.",
	"bastion":       "DMZ passive mengabaikan damage kecil. Lawan multi-hit seperti Worm-Ling tidak akan efektif.",
	"daemon_x":      "Kill Switch bisa one-shot di bawah 20% HP. Set up dengan Memory Leak + Daemon Spawn untuk DoT.",
	"bios_wraith":   "BIOS Flash bisa reset semua buff saat lawan sudah stack tinggi. Timing adalah segalanya.",
	"vish_ara":      "Vishing passive bisa membalikkan serangan besar lawan. Hypnotic Tone + Social Script untuk full control.",
	"bait_eel":      "Honeypot passive punish lawan yang pakai move besar. Drive-by Download bypass defense sepenuhnya.",
	"hash_hound":    "Verificator passive naikan accuracy di awal — mulai dengan Integrity Scan untuk debuff, lalu SHA Strike.",
	"key_lynx":      "Master Key passive sangat kuat melawan Social Engineering. Pasangkan dengan Cipher Claw untuk burst damage.",
	"signal_snail":  "Stable Ping passive memastikan seranganmu selalu kena. Latency Shell + QoS Pulse untuk full control.",
	"warp_wolf":     "Overclock passive bisa trigger double hit. Bandwidth Burst + Protocol Override adalah combo mematikan.",
	"logic_leech":   "Drainer passive terus menyedot HP. Set up Logic Drain DoT dulu, lalu biarkan passive bekerja sendiri.",
	"trojan_taurus": "Last Payload passive bisa berbalik situasi. Jangan takut mati — ledakan terakhirmu bisa mengejutkan lawan.",
	"brick_bear":    "Hardened passive mengurangi semua damage. Stack Rule Block dengan Fortify untuk pertahanan maksimal.",
	"gate_gorilla":  "Port Blocker passive bisa cancel serangan lawan. Gate Slam + Zero Trust Lock adalah combo tank terkuat.",
	"phish_falcon":  "Lure passive langsung debuff defense lawan. Ikuti dengan Spear Dive dan Credential Hook untuk combo cepat.",
	"scam_serpent":  "Disinformation passive bisa Confuse lawan. Deepfake Venom + Impersonation untuk full control di awal.",
	"sentry_stinger":"Deep Scan passive tingkatkan accuracy. Anomaly Alert + Threat Hunt untuk build damage yang konsisten.",
	"radar_rhino":   "Auto-Alert passive counter lawan yang suka buff. Biarkan lawan buff duluan, lalu serang dengan Horn Charge."
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
	bg.size = Vector2(1920, 1080)
	add_child(bg)

	for i in range(0, 1080, 100):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1920, 1)
		line.position = Vector2(0, i)
		add_child(line)
	for i in range(0, 1920, 100):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1, 1080)
		line.position = Vector2(i, 0)
		add_child(line)

	# ── HEADER (Dipersempit tinggi Y nya menjadi 85px) ──
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.06, 0.06, 0.18, 0.95)
	header_bg.size = Vector2(1920, 85)
	add_child(header_bg)

	var header_border = ColorRect.new()
	header_border.color = Color(0.3, 0.5, 0.9, 0.5)
	header_border.size = Vector2(1920, 3)
	header_border.position = Vector2(0, 85)
	add_child(header_border)

	var title = create_label("SELECT YOUR SENTINEL", Vector2(0, 12), 36, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1920, 40)
	add_child(title)

	var subtitle = create_label("Pilih domain lalu pilih Sentinel untuk melawan ancaman siber!", Vector2(0, 52), 16, Color(0.5, 0.6, 0.8))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1920, 25)
	add_child(subtitle)

	# ── TABS ──
	build_tabs()

	# ── CARDS AREA ──
	cards_container = Node2D.new()
	cards_container.position = Vector2(0, 150)
	add_child(cards_container)

	# ── DETAIL PANEL ──
	detail_panel = build_detail_panel()
	add_child(detail_panel)
	detail_panel.visible = false

	# ── BOTTOM BAR ──
	var bottom_bg = ColorRect.new()
	bottom_bg.color = Color(0.05, 0.05, 0.16, 0.97)
	bottom_bg.size = Vector2(1920, 95)
	bottom_bg.position = Vector2(0, 955)
	add_child(bottom_bg)

	var bottom_border = ColorRect.new()
	bottom_border.color = Color(0.3, 0.5, 0.9, 0.4)
	bottom_border.size = Vector2(1920, 2)
	bottom_border.position = Vector2(0, 955)
	add_child(bottom_border)

	# Tombol Kiri Bottom Bar
	var back_btn = _make_bottom_btn("← BACK", Vector2(30, 973), Vector2(160, 58), Color(0.12, 0.12, 0.28))
	back_btn.pressed.connect(func():
		SceneManager.goto_menu("res://menus/main_menu/MainMenu.tscn")
	)
	add_child(back_btn)

	var inv_btn = _make_bottom_btn("🎒 INVENTORY", Vector2(205, 973), Vector2(200, 58), Color(0.15, 0.35, 0.55))
	inv_btn.pressed.connect(func():
		GlobalData.inventory_return_path = "res://menus/selection/SelectionScreen.tscn"
		SceneManager.goto_menu("res://menus/inventory/InventoryMenu.tscn")
	)
	add_child(inv_btn)

	# Tombol Aksi Utama
	confirm_btn = create_styled_button("⚔ START BATTLE!", Vector2(700, 970), Vector2(380, 60), Color(0.08, 0.4, 0.15))
	confirm_btn.pressed.connect(start_battle)
	confirm_btn.visible = false
	add_child(confirm_btn)

	map_btn = create_styled_button("🗺 ENTER MAP", Vector2(1100, 970), Vector2(380, 60), Color(0.1, 0.3, 0.5))
	map_btn.pressed.connect(enter_map)
	map_btn.visible = false
	add_child(map_btn)

	show_tab("Crypto")

func build_tabs():
	var types = ["Crypto", "Network", "Malware", "Firewall", "Social Engineering", "Monitor"]
	var tab_width = 190
	var spacing = 8
	var total_w = types.size() * tab_width + (types.size() - 1) * spacing
	var start_x = (1920 - total_w) / 2

	for i in types.size():
		var t = types[i]
		var col = type_colors[t]
		var x = start_x + i * (tab_width + spacing)

		var tab_bg = ColorRect.new()
		tab_bg.size = Vector2(tab_width, 42)
		tab_bg.position = Vector2(x, 95)
		tab_bg.color = Color(col.r, col.g, col.b, 0.1)
		tab_bg.name = "tab_bg_" + t
		add_child(tab_bg)

		var tab_accent = ColorRect.new()
		tab_accent.size = Vector2(tab_width, 3)
		tab_accent.position = Vector2(x, 134)
		tab_accent.color = Color(col.r, col.g, col.b, 0.3)
		tab_accent.name = "tab_border_" + t
		add_child(tab_accent)

		var btn = Button.new()
		btn.text = t
		btn.size = Vector2(tab_width, 42)
		btn.position = Vector2(x, 95)
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 17)
		btn.add_theme_color_override("font_color", col)
		btn.pressed.connect(func(): show_tab(t))
		add_child(btn)

		tab_buttons[t] = {"bg": tab_bg, "border": tab_accent, "btn": btn, "color": col}

	var divider = ColorRect.new()
	divider.color = Color(0.2, 0.2, 0.4, 0.5)
	divider.size = Vector2(1920, 2)
	divider.position = Vector2(0, 142)
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

	var adv_map = {
		"Crypto":             "⚡ Kuat vs Malware   ⚠ Lemah vs Network",
		"Network":            "⚡ Kuat vs Crypto   ⚠ Lemah vs Firewall",
		"Malware":            "⚡ Kuat vs Firewall   ⚠ Lemah vs Crypto",
		"Firewall":           "⚡ Kuat vs Network   ⚠ Lemah vs Malware",
		"Social Engineering": "⚡ Kuat vs Crypto   ⚠ Lemah vs Monitor",
		"Monitor":            "⚡ Kuat vs Social Engineering   ⚠ Lemah vs Malware"
	}

	# Banner Domain
	var domain_bar = ColorRect.new()
	domain_bar.color = Color(type_col.r, type_col.g, type_col.b, 0.08)
	domain_bar.size = Vector2(1270, 45)
	domain_bar.position = Vector2(25, 0)
	cards_container.add_child(domain_bar)

	var domain_accent = ColorRect.new()
	domain_accent.color = Color(type_col.r, type_col.g, type_col.b, 0.8)
	domain_accent.size = Vector2(6, 45)
	domain_accent.position = Vector2(25, 0)
	cards_container.add_child(domain_accent)

	var header = create_label(type_name.to_upper() + " DOMAIN  —  " + str(filtered.size()) + " Sentinels", Vector2(40, 12), 16, type_col)
	cards_container.add_child(header)

	var adv_label = create_label(adv_map[type_name], Vector2(500, 13), 13, Color(type_col.r, type_col.g, type_col.b, 0.9))
	adv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	adv_label.custom_minimum_size = Vector2(780, 25)
	cards_container.add_child(adv_label)

	# Menata 5 kartu hanya di sisi kiri (X: 30 hingga 1280) agar tidak menimpa detail panel
	var available_width = 1250
	var spacing = 25
	var start_x = 30

	for i in filtered.size():
		var card_x = start_x + i * (card_w + spacing)
		var card = build_monster_card(filtered[i], Vector2(card_x, 60))
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

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.2, 0.95)
	style.border_color = Color(col.r, col.g, col.b, 0.5)
	style.set_border_width_all(3)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	# Tinggi kartu diperbaiki menjadi 720px secara teratur
	var card_h = 720
	var panel = PanelContainer.new()
	panel.size = Vector2(card_w, card_h)
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)

	# 1. Sprite Area (0 - 150)
	var sprite_bg = ColorRect.new()
	sprite_bg.color = Color(col.r * 0.15, col.g * 0.15, col.b * 0.2)
	sprite_bg.size = Vector2(card_w, 150)
	card.add_child(sprite_bg)

	var top_accent = ColorRect.new()
	top_accent.color = col
	top_accent.size = Vector2(card_w, 4)
	card.add_child(top_accent)

	SentinelSprites.draw(card, info["id"], Vector2(card_w / 2, 75), col, 55)

	# 2. Role Area (155 - 180)
	var role_bg = ColorRect.new()
	role_bg.color = Color(col.r * 0.3, col.g * 0.3, col.b * 0.3)
	role_bg.size = Vector2(card_w, 24)
	role_bg.position = Vector2(0, 155)
	card.add_child(role_bg)

	var role_lbl = create_label(info["role"].to_upper(), Vector2(0, 158), 11, col)
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.custom_minimum_size = Vector2(card_w, 20)
	card.add_child(role_lbl)

	# 3. Name Area (185 - 225)
	var name_lbl = create_label(info["name"], Vector2(0, 190), 15, col)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.custom_minimum_size = Vector2(card_w, 25)
	card.add_child(name_lbl)

	var div = ColorRect.new()
	div.color = Color(col.r, col.g, col.b, 0.25)
	div.size = Vector2(card_w - 30, 1)
	div.position = Vector2(15, 225)
	card.add_child(div)

	# 4. Stats Area (235 - 310)
	# HP Stat
	var hp_label = create_label("HP", Vector2(15, 238), 10, Color(0.5, 0.7, 0.5))
	card.add_child(hp_label)

	var hp_bar_bg = ColorRect.new()
	hp_bar_bg.color = Color(0.1, 0.1, 0.1)
	hp_bar_bg.size = Vector2(card_w - 85, 8)
	hp_bar_bg.position = Vector2(45, 244)
	card.add_child(hp_bar_bg)

	var hp_fill = ColorRect.new()
	hp_fill.color = Color(0.2, 0.8, 0.3)
	hp_fill.size = Vector2((card_w - 85) * (info["hp"] / 170.0), 8)
	hp_fill.position = Vector2(45, 244)
	card.add_child(hp_fill)

	var hp_val = create_label(str(info["hp"]), Vector2(card_w - 35, 238), 10, Color(0.6, 0.9, 0.6))
	card.add_child(hp_val)

	# Speed Stat
	var spd_label = create_label("SPD", Vector2(15, 268), 10, Color(0.7, 0.6, 0.3))
	card.add_child(spd_label)

	var spd_bar_bg = ColorRect.new()
	spd_bar_bg.color = Color(0.1, 0.1, 0.1)
	spd_bar_bg.size = Vector2(card_w - 85, 8)
	spd_bar_bg.position = Vector2(45, 274)
	card.add_child(spd_bar_bg)

	var spd_fill = ColorRect.new()
	spd_fill.color = Color(0.9, 0.7, 0.2)
	spd_fill.size = Vector2((card_w - 85) * (info["speed"] / 110.0), 8)
	spd_fill.position = Vector2(45, 274)
	card.add_child(spd_fill)

	var spd_val = create_label(str(info["speed"]), Vector2(card_w - 35, 268), 10, Color(0.9, 0.8, 0.4))
	card.add_child(spd_val)

	var div2 = ColorRect.new()
	div2.color = Color(col.r, col.g, col.b, 0.2)
	div2.size = Vector2(card_w - 30, 1)
	div2.position = Vector2(15, 300)
	card.add_child(div2)

	# 5. Moves Area (310 - 700)
	var moves_header = create_label("MOVES", Vector2(15, 310), 10, Color(0.5, 0.7, 0.9))
	card.add_child(moves_header)

	for j in info["moves"].size():
		var move_y = 335 + j * 32

		var m_bg = ColorRect.new()
		m_bg.color = Color(col.r * 0.1, col.g * 0.1, col.b * 0.15)
		m_bg.size = Vector2(card_w - 30, 26)
		m_bg.position = Vector2(15, move_y)
		card.add_child(m_bg)

		var move_dot = ColorRect.new()
		move_dot.color = col
		move_dot.size = Vector2(6, 6)
		move_dot.position = Vector2(23, move_y + 10)
		card.add_child(move_dot)

		var m = create_label(info["moves"][j], Vector2(36, move_y + 4), 11, Color(0.85, 0.9, 1.0))
		card.add_child(m)

	# Clickable Overlay Button
	var btn = Button.new()
	btn.size = Vector2(card_w, card_h)
	btn.flat = true
	btn.modulate = Color(1, 1, 1, 0)
	btn.pressed.connect(func(): select_monster(card, info))
	card.add_child(btn)

	return card

func build_detail_panel() -> Node2D:
	var panel = Node2D.new()
	panel.position = Vector2(1320, 150) # Diposisikan rapi di sisi kanan (X: 1320 hingga 1890)

	var bg = ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.2, 0.97)
	bg.size = Vector2(570, 780)
	panel.add_child(bg)

	var border_top = ColorRect.new()
	border_top.color = Color(0.4, 0.6, 1)
	border_top.size = Vector2(570, 5)
	panel.add_child(border_top)

	var border_left = ColorRect.new()
	border_left.color = Color(0.4, 0.6, 1, 0.4)
	border_left.size = Vector2(5, 780)
	panel.add_child(border_left)

	var selected_title = create_label("— SELECTED SENTINEL —", Vector2(0, 18), 12, Color(0.5, 0.6, 0.8))
	selected_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_title.custom_minimum_size = Vector2(570, 25)
	panel.add_child(selected_title)

	detail_labels["title"] = create_label("???", Vector2(0, 48), 22, Color(0.4, 0.9, 1))
	detail_labels["title"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_labels["title"].custom_minimum_size = Vector2(570, 35)
	panel.add_child(detail_labels["title"])

	detail_labels["desc"] = create_label("", Vector2(25, 95), 12, Color(0.75, 0.75, 0.85))
	detail_labels["desc"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["desc"].custom_minimum_size = Vector2(520, 80)
	panel.add_child(detail_labels["desc"])

	var div1 = ColorRect.new()
	div1.color = Color(0.3, 0.3, 0.5, 0.4)
	div1.size = Vector2(520, 2)
	div1.position = Vector2(25, 190)
	panel.add_child(div1)

	panel.add_child(create_label("PASSIVE", Vector2(25, 205), 12, Color(1, 0.8, 0.3)))
	detail_labels["passive"] = create_label("", Vector2(25, 235), 12, Color(0.9, 0.85, 0.6))
	detail_labels["passive"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["passive"].custom_minimum_size = Vector2(520, 80)
	panel.add_child(detail_labels["passive"])

	var div2 = ColorRect.new()
	div2.color = Color(0.3, 0.3, 0.5, 0.4)
	div2.size = Vector2(520, 2)
	div2.position = Vector2(25, 330)
	panel.add_child(div2)

	panel.add_child(create_label("DOMAIN ADVANTAGE", Vector2(25, 345), 12, Color(0.4, 1, 0.4)))
	detail_labels["advantage"] = create_label("", Vector2(25, 375), 13, Color(0.7, 1, 0.7))
	detail_labels["advantage"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["advantage"].custom_minimum_size = Vector2(520, 70)
	panel.add_child(detail_labels["advantage"])

	var div3 = ColorRect.new()
	div3.color = Color(0.3, 0.3, 0.5, 0.4)
	div3.size = Vector2(520, 2)
	div3.position = Vector2(25, 460)
	panel.add_child(div3)

	panel.add_child(create_label("TIPS", Vector2(25, 475), 12, Color(0.5, 0.7, 1)))
	detail_labels["tips"] = create_label("", Vector2(25, 505), 12, Color(0.6, 0.7, 0.8))
	detail_labels["tips"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["tips"].custom_minimum_size = Vector2(520, 160)
	panel.add_child(detail_labels["tips"])

	return panel

func select_monster(card: Node2D, info: Dictionary):
	selected_monster = info["id"]

	for c in card_nodes:
		var p = c.get_child(0)
		var s = p.get_theme_stylebox("panel").duplicate()
		s.set_border_width_all(3)
		s.border_color = Color(info["color"].r, info["color"].g, info["color"].b, 0.5)
		p.add_theme_stylebox_override("panel", s)

	var sel_panel = card.get_child(0)
	var sel_style = sel_panel.get_theme_stylebox("panel").duplicate()
	sel_style.set_border_width_all(6)
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
	map_btn.visible = false
	confirm_btn.text = "⚔ Battle with " + info["name"] + "!"

func start_battle():
	if selected_monster == "":
		return
	GlobalData.set_active_team([selected_monster])
	GlobalData.save_current_slot()
	GlobalData.pending_sentinel = selected_monster

	if GlobalData.is_first_time:
		GlobalData.mark_played()
		SceneManager.goto_menu("res://battle/TutorialBattle.tscn")
	else:
		GlobalData.clear_encounter()
		SceneManager.goto_menu("res://battle/Battle.tscn")

func enter_map():
	if selected_monster == "":
		return
	GlobalData.set_active_team([selected_monster])
	GlobalData.clear_encounter()
	SceneManager.load_map(GlobalData.current_map)

func spawn_particles():
	for i in 50:
		var p = ColorRect.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sz = randf_range(2.0, 5.0)
		p.size = Vector2(sz, sz)
		p.position = Vector2(randf_range(0, 1920), randf_range(0, 1080))
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
			p["node"].position.y = 1090
			p["node"].position.x = randf_range(0, 1920)
		if p["node"].position.x < -10:  p["node"].position.x = 1930
		if p["node"].position.x > 1930: p["node"].position.x = -10
		var alpha = p["base_alpha"] + sin(time * 2.0 + p["phase"]) * 0.15
		p["node"].color.a = clamp(alpha, 0.05, 0.8)

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _make_bottom_btn(text: String, pos: Vector2, sz: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = sz
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = 8; s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8; s.corner_radius_bottom_right = 8
	s.border_color = Color(0.3, 0.3, 0.6, 0.5)
	s.set_border_width_all(1)
	btn.add_theme_stylebox_override("normal", s)
	var h = s.duplicate(); h.bg_color = color.lightened(0.2)
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	return btn

func create_styled_button(text: String, pos: Vector2, size: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = size

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_color = Color(0.3, 0.8, 0.4, 0.5)
	style.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.border_color = Color(0.4, 1, 0.5, 0.8)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
