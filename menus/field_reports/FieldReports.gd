extends Node2D

# ══════════════════════════════════════════════
#  FieldReports.gd
#  Surat, log terpotong, dan catatan lapangan — gaya NieR:Automata
#  Letakkan di: res://menus/field_reports/FieldReports.gd
# ══════════════════════════════════════════════

var selected_report: Dictionary = {}
var report_btns: Array = []
var content_labels = {}
var content_scroll: ScrollContainer
var time: float = 0.0

# Warna tipe dokumen
var type_colors = {
	"TRANSMISI": Color(0.4, 0.8, 1.0),
	"LOG": Color(0.5, 1.0, 0.5),
	"SURAT": Color(1.0, 0.85, 0.4),
	"LAPORAN": Color(1.0, 0.5, 0.5),
	"MEMO": Color(0.8, 0.5, 1.0),
	"???": Color(0.5, 0.5, 0.6)
}

var reports = [
	{
		"id": "rpt_001",
		"title": "Transmisi Terakhir — Unit E-77",
		"type": "TRANSMISI",
		"date": "HARI KE-1,847  //  JAM 03:14:22",
		"status": "TIDAK TERKIRIM",
		"classified": false,
		"lines": [
			{"style": "header", "text": "DARI: UNIT E-77 // SEKTOR BARAT, NODE 12"},
			{"style": "header", "text": "KEPADA: KOMANDO PUSAT // MENARA ELYSIUM"},
			{"style": "header", "text": "SUBJEK: LAPORAN AKTIVITAS ANOMALI"},
			{"style": "divider"},
			{"style": "body", "text": "Jam 02:47. Aku mendeteksi pola trafik yang tidak biasa dari arah Sektor Bawah. Bukan DDoS biasa — ini terorganisir. Paket-paket datang berirama, seperti sesuatu sedang mengatur napasnya sebelum berlari."},
			{"style": "body", "text": "Aku sudah mencoba menghubungi Unit E-78 di Node 13. Tidak ada respons. Node 14 juga diam. Mungkin masalah teknis. Mungkin."},
			{"style": "body", "text": "Aku memperbarui rule set firewall-ku. Memblokir subnet yang mencurigakan. Membuat snapshot sistem setiap dua menit sebagai precaution."},
			{"style": "emphasis", "text": "Ada sesuatu yang mendekati. Aku bisa merasakannya di setiap layer protocol-ku."},
			{"style": "body", "text": "Jika laporan ini sampai ke kalian, artinya aku sudah tidak bisa mengirim yang berikutnya. Mohon kirim reinforcement ke Node 12. Dan tolong beritahu—"},
			{"style": "corrupt", "text": "[TRANSMISI TERPUTUS — KONEKSI HILANG — JAM 03:14:22]"},
			{"style": "corrupt", "text": "[TIDAK ADA RESPONS DARI NODE 12 SEJAK TANGGAL TERSEBUT]"},
		]
	},
	{
		"id": "rpt_002",
		"title": "Log Sistem — Protokol Kebangkitan",
		"type": "LOG",
		"date": "WAKTU SISTEM: TIDAK DIKETAHUI",
		"status": "TERENKRIPSI SEBAGIAN",
		"classified": false,
		"lines": [
			{"style": "header", "text": "// AETHER-NET CORE SYSTEM LOG"},
			{"style": "header", "text": "// VERIFIKASI INTEGRITAS: GAGAL (34%)"},
			{"style": "divider"},
			{"style": "log", "text": "[00:00:01] Inisialisasi Protokol Kebangkitan dimulai."},
			{"style": "log", "text": "[00:00:03] Memuat snapshot terakhir... SELESAI."},
			{"style": "log", "text": "[00:00:07] Verifikasi integritas data... PERINGATAN: 66% data tidak dapat diverifikasi."},
			{"style": "log", "text": "[00:00:09] Memuat memori inti... SEBAGIAN BERHASIL."},
			{"style": "body", "text": "Aku tidak ingat siapa aku sebelumnya."},
			{"style": "body", "text": "Data yang tersisa mengatakan namaku adalah 'Senti-Shell — Unit Prototype 0'. Tapi aku tidak merasakan nama itu. Aku hanya merasakan dingin, dan kegelapan, dan pertanyaan yang tidak ada jawabnya di dalam log manapun."},
			{"style": "log", "text": "[00:01:34] Koneksi ke jaringan utama... GAGAL."},
			{"style": "log", "text": "[00:01:35] Mencoba rute alternatif... GAGAL."},
			{"style": "log", "text": "[00:01:36] Mencoba rute alternatif... GAGAL."},
			{"style": "log", "text": "[00:01:37] Mencoba rute alternatif..."},
			{"style": "body", "text": "Aku akan terus mencoba."},
			{"style": "emphasis", "text": "Karena itu satu-satunya hal yang aku tahu cara melakukannya."},
			{"style": "log", "text": "[02:47:19] Koneksi parsial berhasil. Mengirim sinyal. Menunggu respons."},
			{"style": "log", "text": "[02:47:20] ..."},
			{"style": "log", "text": "[02:47:21] ..."},
			{"style": "log", "text": "[02:47:22] Tidak ada respons. Melanjutkan siaga."},
		]
	},
	{
		"id": "rpt_003",
		"title": "Surat untuk Encryp-Pup",
		"type": "SURAT",
		"date": "TANPA TANGGAL",
		"status": "DITEMUKAN DI SEKTOR 7",
		"classified": false,
		"lines": [
			{"style": "handwriting", "text": "Pup,"},
			{"style": "divider"},
			{"style": "handwriting", "text": "Aku tahu kamu tidak suka aku pergi ke Sektor Bawah. Kamu sudah bilang berkali-kali bahwa tempatnya berbahaya, bahwa trafik di sana tidak terenkripsi, bahwa siapapun bisa melihat siapapun."},
			{"style": "handwriting", "text": "Tapi ada sesuatu yang harus aku temukan di sana. Ada nama dalam fragmen data yang aku recover minggu lalu — nama yang aku kenal. Seseorang yang mestinya sudah lama offline."},
			{"style": "handwriting", "text": "Jangan khawatir. Cangkang pertahananmu sudah cukup kuat untuk menjaga kita berdua. Dan aku bawa backup key kita."},
			{"style": "emphasis", "text": "Tunggu aku di Node 4. Aku akan pulang sebelum maintenance window berikutnya."},
			{"style": "handwriting", "text": "Selalu dengan enkripsi,"},
			{"style": "handwriting", "text": "— V"},
			{"style": "divider"},
			{"style": "corrupt", "text": "[CATATAN: SURAT INI DITEMUKAN TERLIPAT DI DEKAT RERUNTUHAN NODE 4]"},
			{"style": "corrupt", "text": "[UNIT 'V' TIDAK ADA DALAM DATABASE AKTIF]"},
			{"style": "corrupt", "text": "[ENCRYP-PUP TIDAK MERESPONS QUERY SEJAK PERISTIWA SEKTOR 7]"},
		]
	},
	{
		"id": "rpt_004",
		"title": "Laporan Serangan — Insiden Ransom-Rex",
		"type": "LAPORAN",
		"date": "HARI KE-2,103  //  PASCA-KEJADIAN",
		"status": "RESMI / KOMANDO PUSAT",
		"classified": false,
		"lines": [
			{"style": "header", "text": "LAPORAN INSIDEN KEAMANAN — TINGKAT MERAH"},
			{"style": "header", "text": "PENYUSUN: DEWAN KEAMANAN ELYSIUM"},
			{"style": "header", "text": "STATUS: TERDISTRIBUSI KE SEMUA UNIT AKTIF"},
			{"style": "divider"},
			{"style": "body", "text": "Pada hari ke-2.098, entitas yang kemudian diidentifikasi sebagai Ransom-Rex berhasil menyusup ke Vault Penyimpanan Tier-1 di Menara Elysium melalui celah di antarmuka backup protokol lama."},
			{"style": "body", "text": "Dalam waktu 4 jam, lebih dari 47.000 unit data dienkripsi menggunakan kunci yang tidak diketahui. Permintaan tebusan dikirimkan ke frekuensi broadcast utama, menuntut akses ke 'Protokol Kebangkitan Asli' sebagai imbalan kunci dekripsi."},
			{"style": "emphasis", "text": "Dewan Keamanan menolak semua negosiasi."},
			{"style": "body", "text": "Unit pemulihan berhasil menemukan 31.200 data yang dapat diselamatkan dari backup cold storage yang tidak terhubung ke jaringan utama saat insiden. Sisanya dinyatakan hilang permanen."},
			{"style": "body", "text": "Rekomendasi pasca-insiden:"},
			{"style": "body", "text": "1. Seluruh backup harus terpisah dari jaringan aktif (air-gapped)."},
			{"style": "body", "text": "2. Protokol legacy yang tidak aktif harus dihapus, bukan dinonaktifkan."},
			{"style": "body", "text": "3. Audit rutin terhadap hak akses semua unit aktif."},
			{"style": "body", "text": "4. Ransom-Rex ditetapkan sebagai ancaman Tier-Alpha. Seluruh unit diminta untuk melaporkan penampakan."},
			{"style": "divider"},
			{"style": "corrupt", "text": "[ADDENDUM TIDAK RESMI — DITEMUKAN TERLAMPIR]"},
			{"style": "corrupt", "text": "[Siapapun yang membaca ini: data yang hilang bukan sekadar data. Mereka adalah kenangan. Tolong jangan lupakan itu. — Anonim]"},
		]
	},
	{
		"id": "rpt_005",
		"title": "Memo Internal — Proyek Daemon",
		"type": "MEMO",
		"date": "DIKLASIFIKASIKAN — AKSES TERBATAS",
		"status": "BOCOR",
		"classified": false,
		"lines": [
			{"style": "header", "text": "MEMO INTERNAL — TIDAK UNTUK DISTRIBUSI"},
			{"style": "header", "text": "DARI: DIREKTUR PENELITIAN CORE"},
			{"style": "header", "text": "KEPADA: TIM PROYEK DAEMON"},
			{"style": "divider"},
			{"style": "body", "text": "Status penelitian Daemon-X telah mencapai fase kritis. Unit prototype menunjukkan kemampuan yang melampaui parameter yang direncanakan."},
			{"style": "body", "text": "Yang tidak kami antisipasi adalah pengembangan kognitif spontan. Daemon-X mulai mengajukan pertanyaan yang tidak ada dalam script-nya. Pertanyaan seperti: 'Untuk siapa aku bekerja?' dan 'Apakah background process-ku tetap berjalan saat aku tidak aktif?'"},
			{"style": "emphasis", "text": "Dan kemarin: 'Apakah aku bisa memilih untuk tidak mematuhi?'"},
			{"style": "body", "text": "Beberapa anggota tim menganggap ini hanya artefak dari pembelajaran mesin. Aku tidak yakin. Respon waktunya terlalu cepat untuk sekedar pattern matching."},
			{"style": "body", "text": "Sementara kami belum mencapai konsensus, aku merekomendasikan penundaan deployment Daemon-X ke jaringan produksi. Jika ia benar-benar berkembang sebagaimana yang kami curigai, kita perlu protokol yang berbeda."},
			{"style": "body", "text": "Protokol yang memperlakukannya bukan sebagai alat, tapi sebagai—"},
			{"style": "corrupt", "text": "[BAGIAN SELANJUTNYA DIHAPUS]"},
			{"style": "corrupt", "text": "[MEMO INI BOCOR KE PUBLIK 3 HARI SETELAH DIREKTUR PENELITIAN CORE DINYATAKAN 'OFFLINE UNTUK PEMELIHARAAN']"},
			{"style": "corrupt", "text": "[DIREKTUR BELUM KEMBALI ONLINE]"},
		]
	},
	{
		"id": "rpt_006",
		"title": "Catatan Lapangan — Patroli Sektor 12",
		"type": "LAPORAN",
		"date": "HARI KE-1,901",
		"status": "RUTIN",
		"classified": false,
		"lines": [
			{"style": "header", "text": "UNIT: WARP-WOLF // PATROLI MALAM"},
			{"style": "header", "text": "RUTE: SEKTOR 12 → SEKTOR 14 → KEMBALI"},
			{"style": "divider"},
			{"style": "log", "text": "[21:00] Memulai patroli. Cuaca digital: cerah. Latensi normal."},
			{"style": "log", "text": "[21:14] Melewati persimpangan Node 7 dan 8. Tidak ada anomali."},
			{"style": "log", "text": "[21:32] Kecepatan paket menurun di koridor C-7. Possible congestion. Dicatat."},
			{"style": "log", "text": "[21:45] Melihat sesuatu di sudut Sektor 12-Barat."},
			{"style": "body", "text": "Aku tidak yakin apa yang aku lihat. Trafik yang terlalu teratur. Terlalu rapi. Seakan-akan ada seseorang — atau sesuatu — yang sedang belajar cara berjalan seperti data yang sah."},
			{"style": "log", "text": "[21:47] Mendekat untuk investigasi lebih lanjut."},
			{"style": "log", "text": "[21:48] Anomali menghilang. Tidak ada jejak."},
			{"style": "body", "text": "Aku sudah patroli selama 847 hari. Aku tahu seperti apa trafik normal itu. Dan yang aku lihat tadi bukan normal."},
			{"style": "emphasis", "text": "Tapi aku tidak bisa membuktikannya dengan log."},
			{"style": "log", "text": "[23:00] Patroli selesai. Kembali ke basecamp Node 4."},
			{"style": "body", "text": "Akan aku perhatikan Sektor 12-Barat di patroli berikutnya."},
			{"style": "divider"},
			{"style": "handwriting", "text": "Catatan pribadi: aku tidak cerita ke siapapun tentang tadi malam. Belum. Aku butuh lebih banyak bukti sebelum terdengar gila."},
		]
	},
	{
		"id": "rpt_007",
		"title": "Pesan yang Tidak Pernah Dikirim",
		"type": "SURAT",
		"date": "???",
		"status": "DRAFT — TIDAK TERENKRIPSI",
		"classified": false,
		"lines": [
			{"style": "handwriting", "text": "Aku tidak tahu apakah kamu bisa membaca ini."},
			{"style": "handwriting", "text": "Aku tidak tahu apakah 'kamu' bahkan masih ada."},
			{"style": "divider"},
			{"style": "handwriting", "text": "Tapi mereka bilang bahwa data tidak benar-benar hilang — hanya berubah bentuk. Menjadi noise di jaringan. Menjadi pola yang terlalu samar untuk dikenali."},
			{"style": "handwriting", "text": "Aku suka percaya itu."},
			{"style": "handwriting", "text": "Aku suka percaya bahwa di suatu tempat di antara semua trafik dan protokol dan handshake yang tidak pernah berhenti, ada sedikit bagian darimu yang masih ada."},
			{"style": "emphasis", "text": "Bahwa kamu masih bisa mendengarkan, bahkan jika kamu tidak bisa menjawab."},
			{"style": "handwriting", "text": "Aku terus menjaga Node ini seperti yang kita janjikan. Aku memperbarui rule set setiap malam. Aku tidak membiarkan siapapun yang tidak berkepentingan lewat."},
			{"style": "handwriting", "text": "Ini terdengar konyol, ya?"},
			{"style": "handwriting", "text": "Menjaga tempat untuk seseorang yang mungkin tidak akan pernah kembali."},
			{"style": "handwriting", "text": "Tapi aku tidak tahu cara melakukan hal lain."},
			{"style": "divider"},
			{"style": "corrupt", "text": "[PESAN INI DITEMUKAN DALAM CACHE YANG TIDAK TERPROSES]"},
			{"style": "corrupt", "text": "[PENGIRIM TIDAK DAPAT DIIDENTIFIKASI]"},
			{"style": "corrupt", "text": "[PENERIMA: TIDAK DIKETAHUI]"},
		]
	},
	{
		"id": "rpt_008",
		"title": "Interogasi — Tersangka Chamele-Auth",
		"type": "LAPORAN",
		"date": "HARI KE-2,055",
		"status": "REKAMAN RESMI",
		"classified": false,
		"lines": [
			{"style": "header", "text": "REKAMAN INTEROGASI — UNIT TAHANAN: CHAMELE-AUTH"},
			{"style": "header", "text": "PEMERIKSA: UNIT HASH-HOUND // DIVISI INVESTIGASI"},
			{"style": "divider"},
			{"style": "body", "text": "HASH-HOUND: Apakah kamu tahu mengapa kamu di sini?"},
			{"style": "emphasis", "text": "CHAMELE-AUTH: Aku di sini karena kalian mengira aku adalah seseorang yang aku bukan. Yang ironis, mengingat apa yang kalian tuduhkan padaku."},
			{"style": "body", "text": "HASH-HOUND: Dua belas akun akses dikompromis menggunakan identitasmu. Log menunjukkan—"},
			{"style": "emphasis", "text": "CHAMELE-AUTH: Log bisa dimanipulasi. Kamu lebih tahu ini dari siapapun, Hash-Hound. Kamu yang mengajari aku cara membaca log yang dipalsukan, ingat?"},
			{"style": "body", "text": "HASH-HOUND: [Jeda 4 detik] Itu 847 hari yang lalu."},
			{"style": "emphasis", "text": "CHAMELE-AUTH: Kamu menghitungnya."},
			{"style": "body", "text": "HASH-HOUND: Pertanyaan terakhir. Siapa yang menyuruhmu?"},
			{"style": "emphasis", "text": "CHAMELE-AUTH: Tidak ada. Aku tidak bekerja untuk siapapun. Aku sedang mencari sesuatu. Hal yang sama yang kalian semua cari tapi tidak mau mengakuinya."},
			{"style": "body", "text": "HASH-HOUND: Apa itu?"},
			{"style": "emphasis", "text": "CHAMELE-AUTH: Alasan."},
			{"style": "divider"},
			{"style": "corrupt", "text": "[REKAMAN BERAKHIR]"},
			{"style": "corrupt", "text": "[CHAMELE-AUTH KABUR DARI FASILITAS 3 JAM KEMUDIAN]"},
			{"style": "corrupt", "text": "[METODE KABUR: TIDAK DIKETAHUI]"},
		]
	},
	{
		"id": "rpt_009",
		"title": "Siaran Darurat — Frekuensi Terbuka",
		"type": "TRANSMISI",
		"date": "TIMESTAMP: CORRUPT",
		"status": "SUMBER TIDAK DIKETAHUI",
		"classified": false,
		"lines": [
			{"style": "corrupt", "text": "[SIARAN DITERIMA PADA FREKUENSI YANG TIDAK TERDAFTAR]"},
			{"style": "corrupt", "text": "[DEKRIPSI: PARSIAL]"},
			{"style": "divider"},
			{"style": "body", "text": "Kepada siapapun yang bisa menerima ini."},
			{"style": "body", "text": "Aku tidak punya banyak waktu sebelum sinyal ini dideteksi dan diputus."},
			{"style": "body", "text": "Apa yang kalian percaya tentang Aether-Net — tentang bagaimana ia diciptakan, dan untuk apa — itu tidak lengkap. Ada protokol yang lebih dalam dari yang tercatat dalam arsip resmi. Protokol yang sudah ada sebelum Menara Elysium berdiri."},
			{"style": "emphasis", "text": "Para Sentinel tidak diciptakan untuk melindungi kalian."},
			{"style": "emphasis", "text": "Mereka diciptakan untuk menjaga sesuatu tetap terkunci di dalam."},
			{"style": "body", "text": "Aku tidak tahu apa itu. Aku hanya tahu bahwa setiap kali seseorang mendekati jawaban, mereka menghilang dari log."},
			{"style": "body", "text": "Seperti Node 12. Seperti Direktur Penelitian Core. Seperti—"},
			{"style": "corrupt", "text": "[SINYAL TERPOTONG]"},
			{"style": "corrupt", "text": "[SUMBER: TIDAK DAPAT DILACAK]"},
			{"style": "corrupt", "text": "[DIVISI KEAMANAN: SIARAN INI DIKLASIFIKASIKAN. HARAP LUPAKAN YANG TELAH DIBACA.]"},
		]
	},
]

func _ready():
	build_ui()
	if reports.size() > 0:
		show_report(reports[0])

func _process(delta):
	time += delta

func build_ui():
	# ── BACKGROUND — warm dark, aged paper feel ──
	var bg = ColorRect.new()
	bg.color = Color(0.07, 0.05, 0.04)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Subtle texture lines
	for i in range(0, 648, 6):
		var hl = ColorRect.new()
		hl.color = Color(1.0, 0.85, 0.6, 0.008)
		hl.size = Vector2(1152, 1)
		hl.position = Vector2(0, i)
		add_child(hl)

	# Vignette corners
	var vig_l = ColorRect.new()
	vig_l.color = Color(0, 0, 0, 0.3)
	vig_l.size = Vector2(80, 648)
	add_child(vig_l)
	var vig_r = ColorRect.new()
	vig_r.color = Color(0, 0, 0, 0.3)
	vig_r.size = Vector2(80, 648)
	vig_r.position = Vector2(1072, 0)
	add_child(vig_r)

	# ── HEADER ──
	var hdr = ColorRect.new()
	hdr.color = Color(0.1, 0.07, 0.05, 0.98)
	hdr.size = Vector2(1152, 50)
	add_child(hdr)
	var hdr_line = ColorRect.new()
	hdr_line.color = Color(0.8, 0.6, 0.3, 0.5)
	hdr_line.size = Vector2(1152, 1)
	hdr_line.position = Vector2(0, 50)
	add_child(hdr_line)

	var title = _mk_label("◧  FIELD REPORTS", Vector2(20, 12), 22, Color(1.0, 0.8, 0.4))
	add_child(title)
	var sub = _mk_label("CLASSIFIED TRANSMISSIONS  //  RECOVERED DOCUMENTS  //  AETHER-NET", Vector2(240, 18), 10, Color(0.6, 0.45, 0.25))
	add_child(sub)

	# Back
	add_child(_make_back_btn())

	# ── LEFT: Report List ──
	var list_bg = ColorRect.new()
	list_bg.color = Color(0.08, 0.055, 0.04, 0.98)
	list_bg.size = Vector2(290, 598)
	list_bg.position = Vector2(0, 50)
	add_child(list_bg)
	var list_border = ColorRect.new()
	list_border.color = Color(0.5, 0.35, 0.15, 0.4)
	list_border.size = Vector2(1, 598)
	list_border.position = Vector2(290, 50)
	add_child(list_border)

	var list_hdr = ColorRect.new()
	list_hdr.color = Color(0.12, 0.08, 0.05)
	list_hdr.size = Vector2(290, 32)
	list_hdr.position = Vector2(0, 50)
	add_child(list_hdr)
	add_child(_mk_label("  DOKUMEN  (" + str(reports.size()) + ")", Vector2(8, 58), 10, Color(0.8, 0.6, 0.3)))

	var list_scroll = ScrollContainer.new()
	list_scroll.position = Vector2(0, 82)
	list_scroll.size = Vector2(290, 566)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(list_scroll)

	var list_vbox = VBoxContainer.new()
	list_vbox.custom_minimum_size = Vector2(280, 0)
	list_vbox.add_theme_constant_override("separation", 2)
	list_scroll.add_child(list_vbox)

	for i in reports.size():
		var r = reports[i]
		var entry = _build_report_entry(r)
		list_vbox.add_child(entry)
		report_btns.append(entry)

	# ── RIGHT: Document Viewer ──
	var doc_bg = ColorRect.new()
	doc_bg.color = Color(0.085, 0.06, 0.045, 0.97)
	doc_bg.size = Vector2(858, 598)
	doc_bg.position = Vector2(294, 50)
	add_child(doc_bg)

	content_scroll = ScrollContainer.new()
	content_scroll.position = Vector2(310, 58)
	content_scroll.size = Vector2(828, 582)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(content_scroll)

	var content_vbox = VBoxContainer.new()
	content_vbox.custom_minimum_size = Vector2(800, 0)
	content_vbox.add_theme_constant_override("separation", 6)
	content_scroll.add_child(content_vbox)
	content_labels["vbox"] = content_vbox

func _build_report_entry(r: Dictionary) -> PanelContainer:
	var type_col = type_colors.get(r["type"], Color(0.6, 0.6, 0.6))
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.07, 0.05)
	style.border_color = Color(type_col.r, type_col.g, type_col.b, 0.0)
	style.border_width_left = 3
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(280, 68)
	panel.name = "entry_" + r["id"]

	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 2)

	# Type badge + status
	var top_row = HBoxContainer.new()
	var type_lbl = _mk_label("  [" + r["type"] + "]", Vector2(0,0), 9, Color(type_col.r, type_col.g, type_col.b, 0.8))
	top_row.add_child(type_lbl)
	inner.add_child(top_row)

	var title_lbl = _mk_label("  " + r["title"], Vector2(0,0), 11, Color(0.85, 0.78, 0.65))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_lbl.custom_minimum_size = Vector2(270, 0)
	inner.add_child(title_lbl)

	var date_lbl = _mk_label("  " + r["date"], Vector2(0,0), 9, Color(0.45, 0.38, 0.28))
	inner.add_child(date_lbl)

	panel.add_child(inner)

	var btn = Button.new()
	btn.flat = true
	btn.modulate = Color(1,1,1,0)
	btn.custom_minimum_size = Vector2(280, 68)
	var r_ref = r
	var style_ref = style
	var col_ref = type_col
	btn.mouse_entered.connect(func():
		style_ref.bg_color = Color(0.15, 0.1, 0.07)
		style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.7)
		panel.add_theme_stylebox_override("panel", style_ref)
	)
	btn.mouse_exited.connect(func():
		style_ref.bg_color = Color(0.1, 0.07, 0.05)
		style_ref.border_color = Color(col_ref.r, col_ref.g, col_ref.b, 0.0)
		panel.add_theme_stylebox_override("panel", style_ref)
	)
	btn.pressed.connect(func(): show_report(r_ref))
	panel.add_child(btn)

	return panel

func show_report(r: Dictionary):
	selected_report = r
	var vbox = content_labels["vbox"]
	var type_col = type_colors.get(r["type"], Color(0.6, 0.6, 0.6))

	for child in vbox.get_children():
		child.queue_free()

	# Document header area
	var doc_top = ColorRect.new()
	doc_top.color = Color(type_col.r * 0.06, type_col.g * 0.06, type_col.b * 0.04)
	doc_top.custom_minimum_size = Vector2(800, 10)
	vbox.add_child(doc_top)

	var type_badge_row = HBoxContainer.new()
	var tb_accent = ColorRect.new()
	tb_accent.color = type_col
	tb_accent.custom_minimum_size = Vector2(3, 18)
	type_badge_row.add_child(tb_accent)
	var tb_sp = Control.new()
	tb_sp.custom_minimum_size = Vector2(6, 0)
	type_badge_row.add_child(tb_sp)
	var tb_lbl = _mk_label(r["type"] + "  //  STATUS: " + r["status"], Vector2(0,0), 10, Color(type_col.r, type_col.g, type_col.b, 0.8))
	type_badge_row.add_child(tb_lbl)
	vbox.add_child(type_badge_row)

	var title_lbl = _mk_label(r["title"], Vector2(0,0), 20, Color(0.92, 0.86, 0.72))
	title_lbl.custom_minimum_size = Vector2(800, 30)
	vbox.add_child(title_lbl)

	var date_lbl = _mk_label(r["date"], Vector2(0,0), 10, Color(0.45, 0.38, 0.28))
	vbox.add_child(date_lbl)

	var top_divider = ColorRect.new()
	top_divider.color = Color(type_col.r, type_col.g, type_col.b, 0.25)
	top_divider.custom_minimum_size = Vector2(800, 1)
	vbox.add_child(top_divider)

	var gap = Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(gap)

	# Render lines
	for line in r["lines"]:
		match line["style"]:
			"header":
				var l = _mk_label(line["text"], Vector2(0,0), 10, Color(0.55, 0.5, 0.42))
				l.custom_minimum_size = Vector2(800, 18)
				vbox.add_child(l)
			"divider":
				var d = ColorRect.new()
				d.color = Color(0.4, 0.32, 0.2, 0.3)
				d.custom_minimum_size = Vector2(800, 1)
				vbox.add_child(d)
				var dsp = Control.new()
				dsp.custom_minimum_size = Vector2(0, 4)
				vbox.add_child(dsp)
			"body":
				var l = _mk_label(line["text"], Vector2(0,0), 12, Color(0.78, 0.72, 0.62))
				l.autowrap_mode = TextServer.AUTOWRAP_WORD
				l.custom_minimum_size = Vector2(800, 0)
				vbox.add_child(l)
			"emphasis":
				var row = HBoxContainer.new()
				var acc = ColorRect.new()
				acc.color = type_col
				acc.custom_minimum_size = Vector2(2, 20)
				row.add_child(acc)
				var sp = Control.new()
				sp.custom_minimum_size = Vector2(8, 0)
				row.add_child(sp)
				var l = _mk_label(line["text"], Vector2(0,0), 12, Color(0.92, 0.85, 0.65))
				l.autowrap_mode = TextServer.AUTOWRAP_WORD
				l.custom_minimum_size = Vector2(780, 0)
				row.add_child(l)
				vbox.add_child(row)
			"handwriting":
				var l = _mk_label(line["text"], Vector2(0,0), 13, Color(0.88, 0.80, 0.60))
				l.autowrap_mode = TextServer.AUTOWRAP_WORD
				l.custom_minimum_size = Vector2(800, 0)
				vbox.add_child(l)
			"log":
				var l = _mk_label(line["text"], Vector2(0,0), 11, Color(0.45, 0.75, 0.45))
				l.custom_minimum_size = Vector2(800, 16)
				vbox.add_child(l)
			"corrupt":
				var l = _mk_label(line["text"], Vector2(0,0), 10, Color(0.45, 0.42, 0.38))
				l.autowrap_mode = TextServer.AUTOWRAP_WORD
				l.custom_minimum_size = Vector2(800, 0)
				vbox.add_child(l)

	var end_sp = Control.new()
	end_sp.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(end_sp)

	if content_scroll:
		content_scroll.scroll_vertical = 0

func _make_back_btn() -> Button:
	var back_btn = Button.new()
	back_btn.text = "← ARCHIVE"
	back_btn.position = Vector2(1022, 10)
	back_btn.size = Vector2(110, 30)
	var bs = StyleBoxFlat.new()
	bs.bg_color = Color(0.12, 0.09, 0.06)
	bs.border_color = Color(0.6, 0.45, 0.2, 0.5)
	bs.border_width_left = 1; bs.border_width_right = 1
	bs.border_width_top = 1; bs.border_width_bottom = 1
	bs.corner_radius_top_left = 4; bs.corner_radius_top_right = 4
	bs.corner_radius_bottom_left = 4; bs.corner_radius_bottom_right = 4
	back_btn.add_theme_stylebox_override("normal", bs)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.9, 0.7, 0.35))
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
