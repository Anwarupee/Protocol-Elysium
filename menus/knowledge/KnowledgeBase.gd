extends Node2D

# ══════════════════════════════════════════════
#  KnowledgeBase.gd
#  Wiki-style artikel teknis keamanan siber
#  Letakkan di: res://menus/knowledge/KnowledgeBase.gd
# ══════════════════════════════════════════════

var selected_article: Dictionary = {}
var article_btns: Array = []
var content_labels = {}
var content_scroll: ScrollContainer
var time: float = 0.0

var articles = [
	{
		"id": "malware",
		"title": "Malware",
		"category": "ANCAMAN",
		"color": Color(1.0, 0.35, 0.35),
		"summary": "Perangkat lunak berbahaya yang dirancang untuk merusak, mencuri, atau mengambil alih sistem tanpa izin pengguna.",
		"body": [
			{"type": "h2", "text": "Apa itu Malware?"},
			{"type": "p", "text": "Malware (malicious software) adalah istilah umum untuk semua jenis perangkat lunak yang sengaja dibuat untuk merugikan sistem, jaringan, atau penggunanya. Malware bisa berbentuk file, program, skrip, atau bahkan kode yang tersembunyi di dalam dokumen biasa."},
			{"type": "h2", "text": "Jenis-Jenis Malware"},
			{"type": "tag", "text": "VIRUS"},
			{"type": "p", "text": "Menempel pada file lain dan menyebar saat file tersebut dijalankan. Virus membutuhkan tindakan manusia untuk menyebar — biasanya dengan membuka file yang terinfeksi."},
			{"type": "tag", "text": "WORM"},
			{"type": "p", "text": "Seperti virus, tapi bisa menyebar sendiri melalui jaringan tanpa interaksi pengguna. Worm terkenal seperti Stuxnet menghancurkan sentrifugal nuklir Iran pada 2010."},
			{"type": "tag", "text": "TROJAN"},
			{"type": "p", "text": "Menyamar sebagai software yang berguna, tapi menyembunyikan fungsi berbahaya di dalamnya. Namanya diambil dari Kuda Troya dalam mitologi Yunani."},
			{"type": "tag", "text": "RANSOMWARE"},
			{"type": "p", "text": "Mengenkripsi file korban dan meminta tebusan untuk mendapatkan kunci dekripsinya. WannaCry (2017) menginfeksi lebih dari 200.000 komputer di 150 negara dalam 24 jam."},
			{"type": "tag", "text": "SPYWARE"},
			{"type": "p", "text": "Diam-diam memantau aktivitas pengguna — keystroke, screenshot, data browsing — dan mengirimkannya ke pihak ketiga tanpa sepengetahuan korban."},
			{"type": "h2", "text": "Cara Kerja Malware"},
			{"type": "p", "text": "Malware masuk ke sistem melalui vektor serangan: email phishing, unduhan dari situs tidak terpercaya, USB drive yang terinfeksi, atau kerentanan software yang belum di-patch. Setelah masuk, malware menjalankan payload-nya — bisa langsung, bisa menunggu trigger tertentu."},
			{"type": "h2", "text": "Pertahanan"},
			{"type": "p", "text": "Antivirus dengan definisi terbaru, firewall aktif, patch system rutin, dan — yang paling penting — kehati-hatian pengguna dalam membuka file atau mengklik link yang tidak dikenal."},
		]
	},
	{
		"id": "firewall",
		"title": "Firewall",
		"category": "PERTAHANAN",
		"color": Color(0.2, 0.6, 1.0),
		"summary": "Sistem keamanan yang memantau dan mengontrol trafik jaringan berdasarkan aturan yang telah ditetapkan.",
		"body": [
			{"type": "h2", "text": "Apa itu Firewall?"},
			{"type": "p", "text": "Firewall adalah garis pertahanan pertama dalam arsitektur keamanan jaringan. Bayangkan sebagai penjaga gerbang yang memeriksa setiap orang (paket data) yang masuk dan keluar — hanya yang punya izin yang boleh lewat."},
			{"type": "h2", "text": "Jenis Firewall"},
			{"type": "tag", "text": "PACKET FILTERING"},
			{"type": "p", "text": "Memeriksa header setiap paket (IP sumber, IP tujuan, port, protokol) dan memblokir atau mengizinkan berdasarkan ruleset. Cepat, tapi tidak melihat konteks koneksi."},
			{"type": "tag", "text": "STATEFUL INSPECTION"},
			{"type": "p", "text": "Melacak state koneksi aktif. Tahu bahwa paket ini adalah bagian dari koneksi yang sudah diizinkan sebelumnya, bukan serangan baru yang menyamar."},
			{"type": "tag", "text": "APPLICATION LAYER (WAF)"},
			{"type": "p", "text": "Memahami protokol aplikasi seperti HTTP, FTP, DNS. Web Application Firewall (WAF) bisa mendeteksi SQL injection dan XSS yang lolos dari firewall biasa."},
			{"type": "tag", "text": "NEXT-GENERATION (NGFW)"},
			{"type": "p", "text": "Menggabungkan semua di atas plus deep packet inspection, intrusion prevention, dan threat intelligence real-time. Standar enterprise modern."},
			{"type": "h2", "text": "Konsep Penting"},
			{"type": "p", "text": "Default-deny: tolak semua, izinkan hanya yang eksplisit dibolehkan. Ini kebalikan dari default-allow yang berbahaya. Zero Trust memperluas prinsip ini ke semua aspek keamanan — tidak ada yang dipercaya secara otomatis, bahkan dari dalam jaringan."},
		]
	},
	{
		"id": "encryption",
		"title": "Enkripsi",
		"category": "KRIPTOGRAFI",
		"color": Color(0.4, 0.85, 1.0),
		"summary": "Proses mengubah data menjadi format yang tidak bisa dibaca tanpa kunci dekripsi yang tepat.",
		"body": [
			{"type": "h2", "text": "Mengapa Enkripsi Penting?"},
			{"type": "p", "text": "Setiap detik, miliaran byte data melintas jaringan publik. Tanpa enkripsi, siapapun yang bisa menyadap koneksimu bisa membaca password, pesan, data kartu kredit — semuanya. Enkripsi mengubah data itu menjadi noise yang tidak bermakna tanpa kunci yang tepat."},
			{"type": "h2", "text": "Simetris vs Asimetris"},
			{"type": "tag", "text": "SYMMETRIC (AES)"},
			{"type": "p", "text": "Satu kunci yang sama digunakan untuk enkripsi dan dekripsi. Sangat cepat, ideal untuk enkripsi data besar. AES-256 adalah standar gold — tidak ada komputer saat ini yang bisa memecahnya dengan brute force dalam waktu yang wajar."},
			{"type": "tag", "text": "ASYMMETRIC (RSA / ECC)"},
			{"type": "p", "text": "Dua kunci: public key untuk enkripsi, private key untuk dekripsi. Siapapun bisa mengenkripsi pesan untukmu, hanya kamu yang bisa membukanya. Lambat untuk data besar, tapi sempurna untuk pertukaran kunci."},
			{"type": "h2", "text": "TLS — HTTPS yang Kamu Kenal"},
			{"type": "p", "text": "TLS (Transport Layer Security) menggabungkan keduanya: asimetris untuk pertukaran kunci session, simetris untuk enkripsi data aktual. Itulah kenapa HTTPS bisa aman dan cepat sekaligus. Saat kamu melihat kunci gembok di browser, TLS sedang bekerja."},
			{"type": "h2", "text": "Hashing — Bukan Enkripsi"},
			{"type": "p", "text": "Hash (SHA-256, bcrypt) adalah one-way — tidak bisa di-decrypt. Digunakan untuk verifikasi integritas dan penyimpanan password. Jika passwordmu di-hash dengan benar, bahkan database yang bocor tidak memberimu akses langsung ke akun pengguna."},
		]
	},
	{
		"id": "social_eng",
		"title": "Social Engineering",
		"category": "ANCAMAN",
		"color": Color(1.0, 0.65, 0.1),
		"summary": "Serangan yang mengeksploitasi psikologi manusia daripada celah teknis sistem.",
		"body": [
			{"type": "h2", "text": "Manusia adalah Celah Terbesar"},
			{"type": "p", "text": "Sistem paling aman di dunia bisa ditembus hanya dengan satu telepon yang meyakinkan. Social engineering tidak membutuhkan keahlian hacking — hanya kemampuan untuk berbohong dengan meyakinkan. Itulah mengapa ia sering disebut 'hacking the human'."},
			{"type": "h2", "text": "Teknik Utama"},
			{"type": "tag", "text": "PHISHING"},
			{"type": "p", "text": "Email atau pesan yang menyamar sebagai entitas terpercaya (bank, IT support, rekan kerja) untuk mencuri kredensial atau menginstal malware. Spear phishing menargetkan individu spesifik dengan pesan yang dipersonalisasi."},
			{"type": "tag", "text": "VISHING"},
			{"type": "p", "text": "Voice phishing — penipuan via telepon. Penyerang menyamar sebagai bank atau teknisi IT, menciptakan urgensi palsu ('akun Anda sedang dibobol!') untuk membuat korban bertindak tanpa berpikir."},
			{"type": "tag", "text": "PRETEXTING"},
			{"type": "p", "text": "Membangun skenario palsu yang elaborat. Contoh: berpura-pura sebagai auditor yang membutuhkan akses 'mendesak' ke sistem untuk pemeriksaan rutin."},
			{"type": "tag", "text": "BAITING"},
			{"type": "p", "text": "Memanfaatkan rasa ingin tahu. USB drive berlabel 'Gaji Karyawan Q4' yang sengaja ditinggal di parkiran kantor — siapa yang tidak penasaran?"},
			{"type": "h2", "text": "Pertahanan Terbaik"},
			{"type": "p", "text": "Verifikasi identitas melalui saluran terpisah sebelum memberikan akses atau informasi. Curiga terhadap permintaan yang mendesak atau tidak biasa. Ingat: tidak ada sistem keamanan yang bisa melindungimu dari dirimu sendiri yang dengan sukarela memberikan akses."},
		]
	},
	{
		"id": "zero_trust",
		"title": "Zero Trust",
		"category": "ARSITEKTUR",
		"color": Color(0.4, 1.0, 0.6),
		"summary": "Model keamanan yang tidak mempercayai siapapun secara default — verifikasi eksplisit diperlukan untuk setiap akses.",
		"body": [
			{"type": "h2", "text": "Jangan Percaya Siapapun"},
			{"type": "p", "text": "Dulu, keamanan jaringan berasumsi: di dalam perimeter = aman, di luar = berbahaya. Zero Trust menolak asumsi ini. Dengan work-from-home, cloud, dan insider threat yang nyata, tidak ada lagi 'dalam' dan 'luar' yang jelas."},
			{"type": "h2", "text": "Tiga Prinsip Inti"},
			{"type": "tag", "text": "VERIFY EXPLICITLY"},
			{"type": "p", "text": "Autentikasi dan otorisasi berdasarkan semua data yang tersedia: identitas, lokasi, perangkat, layanan, workload, dan perilaku. Multi-factor authentication adalah minimum."},
			{"type": "tag", "text": "LEAST PRIVILEGE ACCESS"},
			{"type": "p", "text": "Berikan akses sesedikit mungkin yang dibutuhkan untuk tugas tersebut. Akun admin tidak boleh digunakan untuk browsing. Jika akun tersebut dikompromis, dampaknya minimal."},
			{"type": "tag", "text": "ASSUME BREACH"},
			{"type": "p", "text": "Asumsikan penyerang sudah ada di dalam jaringan. Segmentasi, enkripsi end-to-end, monitoring aktif, dan respons insiden yang terlatih menjadi wajib, bukan opsional."},
			{"type": "h2", "text": "Implementasi Nyata"},
			{"type": "p", "text": "Zero Trust bukan produk yang bisa dibeli — ini adalah filosofi yang diimplementasikan secara bertahap. Mulai dengan identitas (siapa yang mengakses), lalu perangkat (dari mana), lalu jaringan (jalur apa), lalu aplikasi dan data."},
		]
	},
	{
		"id": "incident_response",
		"title": "Incident Response",
		"category": "PROSEDUR",
		"color": Color(1.0, 0.4, 0.7),
		"summary": "Prosedur terstruktur untuk mendeteksi, mengisolasi, dan memulihkan sistem dari insiden keamanan.",
		"body": [
			{"type": "h2", "text": "Ketika Pertahanan Gagal"},
			{"type": "p", "text": "Tidak ada sistem yang 100% tidak bisa ditembus. Pertanyaannya bukan 'apakah' terjadi breach, tapi 'kapan'. Incident Response Plan (IRP) adalah perbedaan antara insiden yang terkontrol dan bencana yang melumpuhkan organisasi."},
			{"type": "h2", "text": "6 Fase NIST"},
			{"type": "tag", "text": "1. PREPARATION"},
			{"type": "p", "text": "Latih tim, siapkan tool, dokumentasikan prosedur sebelum insiden terjadi. Insiden bukan waktunya belajar."},
			{"type": "tag", "text": "2. IDENTIFICATION"},
			{"type": "p", "text": "Deteksi dan konfirmasi bahwa insiden benar terjadi. Bedakan antara false positive dan ancaman nyata. Catat waktu deteksi — ini penting untuk forensik."},
			{"type": "tag", "text": "3. CONTAINMENT"},
			{"type": "p", "text": "Isolasi sistem yang terinfeksi untuk mencegah penyebaran. Short-term (disconnect dari jaringan) dan long-term (patch, hardening) containment."},
			{"type": "tag", "text": "4. ERADICATION"},
			{"type": "p", "text": "Hapus malware, tutup celah yang dieksploitasi, perkuat sistem. Pastikan tidak ada backdoor yang tertinggal."},
			{"type": "tag", "text": "5. RECOVERY"},
			{"type": "p", "text": "Kembalikan sistem ke operasi normal secara bertahap. Monitor ketat untuk memastikan ancaman benar-benar sudah hilang."},
			{"type": "tag", "text": "6. LESSONS LEARNED"},
			{"type": "p", "text": "Analisis insiden secara menyeluruh. Apa yang gagal? Apa yang berhasil? Perbarui prosedur. Insiden yang tidak dipelajari akan terulang."},
		]
	},
	{
		"id": "network_basics",
		"title": "Jaringan & Protokol",
		"category": "FUNDAMENTAL",
		"color": Color(1.0, 0.9, 0.2),
		"summary": "Dasar-dasar bagaimana data bergerak melalui internet dan protokol yang mengatur komunikasi digital.",
		"body": [
			{"type": "h2", "text": "Internet Adalah Sebuah Ilusi"},
			{"type": "p", "text": "Internet tidak memiliki satu jalur tunggal. Saat kamu mengirim pesan, data dipecah menjadi paket-paket kecil, setiap paket mengambil jalur berbeda melalui jaringan global, dan dirakit kembali di tujuan. Ini yang membuat internet resilient — dan kompleks."},
			{"type": "h2", "text": "Protokol Penting"},
			{"type": "tag", "text": "IP — INTERNET PROTOCOL"},
			{"type": "p", "text": "Memberikan alamat unik ke setiap perangkat. IPv4 (32-bit, ~4 miliar alamat) sudah hampir habis, mendorong migrasi ke IPv6 (128-bit, alamat hampir tak terbatas)."},
			{"type": "tag", "text": "TCP vs UDP"},
			{"type": "p", "text": "TCP memastikan setiap paket sampai dan terurut — lebih lambat tapi reliable. UDP lebih cepat tapi tidak menjamin pengiriman — ideal untuk streaming video dan gaming real-time."},
			{"type": "tag", "text": "DNS — BUKU TELEPON INTERNET"},
			{"type": "p", "text": "Menerjemahkan domain (google.com) ke alamat IP. DNS poisoning bisa mengarahkan pengguna ke situs palsu — itulah mengapa DNSSEC dan DNS-over-HTTPS penting."},
			{"type": "tag", "text": "HTTP/HTTPS"},
			{"type": "p", "text": "Protokol transfer konten web. HTTP mengirim segalanya dalam plaintext — siapapun di jaringan yang sama bisa membacanya. HTTPS mengenkripsi koneksi via TLS."},
			{"type": "h2", "text": "Port & Layanan"},
			{"type": "p", "text": "Port adalah 'pintu' spesifik di perangkat untuk layanan berbeda. Port 80 = HTTP, 443 = HTTPS, 22 = SSH, 3306 = MySQL. Port yang terbuka tapi tidak digunakan adalah attack surface yang tidak perlu."},
		]
	},
	{
		"id": "authentication",
		"title": "Autentikasi & Identitas",
		"category": "AKSES",
		"color": Color(0.7, 0.4, 1.0),
		"summary": "Cara sistem memverifikasi bahwa pengguna adalah siapa yang mereka klaim.",
		"body": [
			{"type": "h2", "text": "Siapa Kamu, Sebenarnya?"},
			{"type": "p", "text": "Autentikasi adalah proses membuktikan identitas. Otorisasi adalah proses memverifikasi apa yang boleh kamu lakukan setelah identitasmu dikonfirmasi. Keduanya berbeda dan sama-sama kritis."},
			{"type": "h2", "text": "Faktor Autentikasi"},
			{"type": "tag", "text": "SOMETHING YOU KNOW"},
			{"type": "p", "text": "Password, PIN, jawaban pertanyaan keamanan. Faktor paling umum tapi paling lemah — bisa dicuri, ditebak, atau di-phish."},
			{"type": "tag", "text": "SOMETHING YOU HAVE"},
			{"type": "p", "text": "Smartphone (OTP via SMS/authenticator app), hardware token (YubiKey), smart card. Jauh lebih kuat — penyerang harus mencuri perangkat fisikmu."},
			{"type": "tag", "text": "SOMETHING YOU ARE"},
			{"type": "p", "text": "Biometrik: sidik jari, face recognition, iris scan. Nyaman tapi tidak bisa diubah jika dikompromis — kamu tidak bisa mengganti sidik jarimu."},
			{"type": "h2", "text": "Multi-Factor Authentication (MFA)"},
			{"type": "p", "text": "Menggabungkan dua atau lebih faktor. Bahkan jika passwordmu bocor, penyerang masih butuh akses ke ponselmu. MFA mengurangi risiko account takeover hingga 99.9% menurut Microsoft."},
			{"type": "h2", "text": "Password yang Baik"},
			{"type": "p", "text": "Panjang > kompleksitas. '!Tr0ub4dor&3' lebih mudah ditebak dari 'correct horse battery staple'. Gunakan password manager, jangan pernah reuse password, dan aktifkan MFA di mana pun tersedia."},
		]
	},
]

func _ready():
	build_ui()
	if articles.size() > 0:
		show_article(articles[0])

func _process(delta):
	time += delta

func build_ui():
	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.04)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	for i in range(0, 1152, 48):
		var vl = ColorRect.new()
		vl.color = Color(0.2, 1.0, 0.4, 0.012)
		vl.size = Vector2(1, 648)
		vl.position = Vector2(i, 0)
		add_child(vl)
	for i in range(0, 648, 48):
		var hl = ColorRect.new()
		hl.color = Color(0.2, 1.0, 0.4, 0.012)
		hl.size = Vector2(1152, 1)
		hl.position = Vector2(0, i)
		add_child(hl)

	# Scanlines
	for i in range(0, 648, 3):
		var sl = ColorRect.new()
		sl.color = Color(0, 0, 0, 0.035)
		sl.size = Vector2(1152, 1)
		sl.position = Vector2(0, i)
		add_child(sl)

	# ── HEADER ──
	var hdr = ColorRect.new()
	hdr.color = Color(0.05, 0.08, 0.05, 0.98)
	hdr.size = Vector2(1152, 50)
	add_child(hdr)
	var hdr_line = ColorRect.new()
	hdr_line.color = Color(0.3, 0.9, 0.4, 0.6)
	hdr_line.size = Vector2(1152, 1)
	hdr_line.position = Vector2(0, 50)
	add_child(hdr_line)

	var title = _mk_label("◉  KNOWLEDGE BASE", Vector2(20, 12), 22, Color(0.4, 1.0, 0.55))
	add_child(title)
	var sub = _mk_label("CYBER INTELLIGENCE  //  AETHER-NET TECHNICAL REPOSITORY", Vector2(240, 18), 10, Color(0.3, 0.6, 0.35))
	add_child(sub)

	# Back button
	var back_btn = _make_back_btn()
	add_child(back_btn)

	# ── LEFT: Article List ──
	var list_bg = ColorRect.new()
	list_bg.color = Color(0.04, 0.07, 0.045, 0.98)
	list_bg.size = Vector2(280, 598)
	list_bg.position = Vector2(0, 50)
	add_child(list_bg)
	var list_border = ColorRect.new()
	list_border.color = Color(0.2, 0.5, 0.25, 0.5)
	list_border.size = Vector2(1, 598)
	list_border.position = Vector2(280, 50)
	add_child(list_border)

	var list_header = ColorRect.new()
	list_header.color = Color(0.06, 0.12, 0.07)
	list_header.size = Vector2(280, 32)
	list_header.position = Vector2(0, 50)
	add_child(list_header)
	add_child(_mk_label("  ARTIKEL  (" + str(articles.size()) + ")", Vector2(8, 58), 10, Color(0.4, 0.8, 0.45)))

	var list_scroll = ScrollContainer.new()
	list_scroll.position = Vector2(0, 82)
	list_scroll.size = Vector2(280, 566)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(list_scroll)

	var list_vbox = VBoxContainer.new()
	list_vbox.custom_minimum_size = Vector2(270, 0)
	list_vbox.add_theme_constant_override("separation", 2)
	list_scroll.add_child(list_vbox)

	for i in articles.size():
		var a = articles[i]
		var entry = _build_article_entry(a, i)
		list_vbox.add_child(entry)
		article_btns.append(entry)

	# ── RIGHT: Article Content ──
	var content_bg = ColorRect.new()
	content_bg.color = Color(0.04, 0.07, 0.045, 0.96)
	content_bg.size = Vector2(868, 598)
	content_bg.position = Vector2(284, 50)
	add_child(content_bg)

	content_scroll = ScrollContainer.new()
	content_scroll.position = Vector2(300, 58)
	content_scroll.size = Vector2(840, 582)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(content_scroll)

	var content_vbox = VBoxContainer.new()
	content_vbox.custom_minimum_size = Vector2(810, 0)
	content_vbox.add_theme_constant_override("separation", 8)
	content_scroll.add_child(content_vbox)

	# Placeholder
	content_labels["vbox"] = content_vbox

func _build_article_entry(a: Dictionary, idx: int) -> PanelContainer:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.09, 0.055)
	style.border_color = Color(a["color"].r, a["color"].g, a["color"].b, 0.0)
	style.border_width_left = 3
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(270, 56)
	panel.name = "entry_" + a["id"]

	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 2)

	var cat_lbl = _mk_label("  " + a["category"], Vector2(0, 0), 9, Color(a["color"].r, a["color"].g, a["color"].b, 0.7))
	inner.add_child(cat_lbl)

	var title_lbl = _mk_label("  " + a["title"], Vector2(0, 0), 13, Color(0.85, 0.92, 0.87))
	inner.add_child(title_lbl)

	panel.add_child(inner)

	var btn = Button.new()
	btn.flat = true
	btn.modulate = Color(1, 1, 1, 0)
	btn.custom_minimum_size = Vector2(270, 56)
	var a_ref = a
	var style_ref = style
	btn.mouse_entered.connect(func():
		style_ref.bg_color = Color(0.08, 0.14, 0.09)
		style_ref.border_color = Color(a_ref["color"].r, a_ref["color"].g, a_ref["color"].b, 0.6)
		panel.add_theme_stylebox_override("panel", style_ref)
	)
	btn.mouse_exited.connect(func():
		style_ref.bg_color = Color(0.05, 0.09, 0.055)
		style_ref.border_color = Color(a_ref["color"].r, a_ref["color"].g, a_ref["color"].b, 0.0)
		panel.add_theme_stylebox_override("panel", style_ref)
	)
	btn.pressed.connect(func(): show_article(a_ref))
	panel.add_child(btn)

	return panel

func show_article(a: Dictionary):
	selected_article = a
	var vbox = content_labels["vbox"]

	# Clear existing
	for child in vbox.get_children():
		child.queue_free()

	# Rebuild content
	var col = a["color"]

	# Article header
	var art_header = ColorRect.new()
	art_header.color = Color(col.r * 0.08, col.g * 0.08, col.b * 0.08)
	art_header.custom_minimum_size = Vector2(810, 80)
	vbox.add_child(art_header)

	var cat_top = _mk_label(a["category"] + "  //  AETHER-NET KNOWLEDGE BASE", Vector2(0, 0), 10, Color(col.r, col.g, col.b, 0.7))
	cat_top.custom_minimum_size = Vector2(810, 20)
	vbox.add_child(cat_top)

	var art_title = _mk_label(a["title"], Vector2(0, 0), 28, Color(0.9, 0.95, 1.0))
	art_title.custom_minimum_size = Vector2(810, 40)
	vbox.add_child(art_title)

	var summary_bg = ColorRect.new()
	summary_bg.color = Color(col.r * 0.1, col.g * 0.1, col.b * 0.15)
	summary_bg.custom_minimum_size = Vector2(810, 4)
	vbox.add_child(summary_bg)

	var accent = ColorRect.new()
	accent.color = col
	accent.custom_minimum_size = Vector2(810, 2)
	vbox.add_child(accent)

	var summary_lbl = _mk_label(a["summary"], Vector2(0, 0), 12, Color(col.r * 0.9, col.g * 0.9, col.b * 0.9))
	summary_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	summary_lbl.custom_minimum_size = Vector2(810, 0)
	vbox.add_child(summary_lbl)

	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer_top)

	# Render body blocks
	for block in a["body"]:
		match block["type"]:
			"h2":
				var h_spacer = Control.new()
				h_spacer.custom_minimum_size = Vector2(0, 6)
				vbox.add_child(h_spacer)
				var h2 = _mk_label(block["text"], Vector2(0, 0), 16, Color(col.r, col.g, col.b))
				h2.custom_minimum_size = Vector2(810, 24)
				vbox.add_child(h2)
				var h2_line = ColorRect.new()
				h2_line.color = Color(col.r, col.g, col.b, 0.3)
				h2_line.custom_minimum_size = Vector2(810, 1)
				vbox.add_child(h2_line)
			"p":
				var p = _mk_label(block["text"], Vector2(0, 0), 11, Color(0.72, 0.78, 0.74))
				p.autowrap_mode = TextServer.AUTOWRAP_WORD
				p.custom_minimum_size = Vector2(810, 0)
				vbox.add_child(p)
			"tag":
				var tag_row = HBoxContainer.new()
				var tag_accent = ColorRect.new()
				tag_accent.color = col
				tag_accent.custom_minimum_size = Vector2(3, 20)
				tag_row.add_child(tag_accent)
				var tag_sp = Control.new()
				tag_sp.custom_minimum_size = Vector2(6, 0)
				tag_row.add_child(tag_sp)
				var tag_lbl = _mk_label(block["text"], Vector2(0, 0), 10, Color(col.r, col.g, col.b, 0.9))
				tag_row.add_child(tag_lbl)
				vbox.add_child(tag_row)

	# Spacer bawah
	var end_spacer = Control.new()
	end_spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(end_spacer)

	if content_scroll:
		content_scroll.scroll_vertical = 0

func _make_back_btn() -> Button:
	var back_btn = Button.new()
	back_btn.text = "← ARCHIVE"
	back_btn.position = Vector2(1022, 10)
	back_btn.size = Vector2(110, 30)
	var bs = StyleBoxFlat.new()
	bs.bg_color = Color(0.08, 0.12, 0.09)
	bs.border_color = Color(0.3, 0.6, 0.35, 0.5)
	bs.border_width_left = 1; bs.border_width_right = 1
	bs.border_width_top = 1; bs.border_width_bottom = 1
	bs.corner_radius_top_left = 4; bs.corner_radius_top_right = 4
	bs.corner_radius_bottom_left = 4; bs.corner_radius_bottom_right = 4
	back_btn.add_theme_stylebox_override("normal", bs)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.5, 0.9, 0.55))
	back_btn.pressed.connect(go_back)
	return back_btn

func go_back():
	var scene = load("res://menus/archive/TheArchive.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func _mk_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l
