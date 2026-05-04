extends Node2D

var selected_monster: Dictionary = {}
var grid_buttons: Array = []
var detail_labels = {}
var move_labels = []
var detail_scroll: ScrollContainer
var detail_vbox: VBoxContainer

var monsters_data = [
	{
		"id": "encryp_pup", "name": "Encryp-Pup", "number": "001",
		"type": "Data", "color": Color(0.4, 0.8, 1),
		"hp": 120, "speed": 60, "role": "Defender",
		"desc": "Dikenal sebagai penjaga data setia. Semakin sering diserang, semakin kuat pertahanannya. Mewakili konsep enkripsi end-to-end yang melindungi data dari akses tidak sah.",
		"passive": "Hardened Shell — Defense naik setiap kali menerima serangan.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Encrypt", "edu_log": "Enkripsi mengubah data menjadi ciphertext yang tidak bisa dibaca tanpa kunci."},
			{"name": "Firewall Bark", "edu_log": "Firewall memfilter traffic berbahaya sebelum masuk ke sistem."},
			{"name": "Backup Howl", "edu_log": "Backup rutin memastikan data bisa dipulihkan saat terjadi insiden."},
			{"name": "SSL Handshake", "edu_log": "SSL/TLS Handshake membangun koneksi terenkripsi antara client dan server secara aman."}
		]
	},
	{
		"id": "ping_go", "name": "Ping-Go", "number": "002",
		"type": "Connection", "color": Color(1, 0.9, 0.3),
		"hp": 90, "speed": 100, "role": "Speedster",
		"desc": "Burung puyuh digital yang bergerak pada kecepatan cahaya fiber optik. Mewakili protokol jaringan yang mengutamakan kecepatan transmisi data dan efisiensi routing.",
		"passive": "Low Latency — Selalu menyerang duluan kecuali lawan punya pasif serupa.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "Packet Dash", "edu_log": "Data dikirim dalam bentuk paket-paket kecil melalui jaringan."},
			{"name": "Traceroute", "edu_log": "Traceroute memetakan jalur data untuk menemukan titik lemah jaringan."},
			{"name": "DDoS Feathers", "edu_log": "DDoS membanjiri server dengan request sampai tidak bisa merespons."},
			{"name": "Ping Flood", "edu_log": "Ping Flood mengirim ICMP request terus-menerus untuk menghabiskan bandwidth target."}
		]
	},
	{
		"id": "biti", "name": "Biti", "number": "003",
		"type": "Malware", "color": Color(1, 0.4, 0.4),
		"hp": 95, "speed": 80, "role": "Strategist",
		"desc": "Makhluk kecil nakal yang terus bermutasi untuk menghindari deteksi. Mewakili polymorphic malware yang mengubah signature-nya agar lolos dari antivirus konvensional.",
		"passive": "Polymorphic — 30% chance serangan lawan miss karena Biti terus bermutasi.",
		"advantage": "Kuat vs Connection\nLemah vs Data",
		"moves": [
			{"name": "Mimic Byte", "edu_log": "Malware canggih bisa meniru perilaku software legitimate untuk menghindari deteksi."},
			{"name": "Inject", "edu_log": "SQL Injection menyisipkan kode berbahaya ke dalam input yang tidak divalidasi."},
			{"name": "Trojan Gift", "edu_log": "Trojan Horse menyamar sebagai software berguna sebelum mengaktifkan payload berbahaya."},
			{"name": "Rootkit Hide", "edu_log": "Rootkit menyembunyikan keberadaannya di level kernel, membuat deteksi hampir mustahil."}
		]
	},
	{
		"id": "senti_shell", "name": "Senti-Shell", "number": "004",
		"type": "Defensive", "color": Color(0.2, 0.9, 0.6),
		"hp": 150, "speed": 40, "role": "Tank",
		"desc": "The Immutable Guardian. Kura-kura mekanik dengan cangkang berlian data transparan. Mewakili integritas data yang tidak bisa diubah meski dihantam Brute Force sekalipun.",
		"passive": "Redundancy — Saat HP menyentuh 0 pertama kalinya, bertahan dengan 1 HP.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Diamond Layer", "edu_log": "Data integrity memastikan informasi tidak berubah saat transit atau penyimpanan."},
			{"name": "Shell Slam", "edu_log": "Defense in Depth menggunakan lapisan pertahanan berlapis untuk memaksimalkan perlindungan."},
			{"name": "Immutable Lock", "edu_log": "Immutable backup adalah backup yang tidak bisa dimodifikasi atau dihapus bahkan oleh ransomware."},
			{"name": "Restore Point", "edu_log": "System restore point memungkinkan pemulihan sistem ke kondisi sebelum serangan terjadi."}
		]
	},
	{
		"id": "octo_core", "name": "Octo-Core", "number": "005",
		"type": "System", "color": Color(0.6, 0.3, 1),
		"hp": 110, "speed": 70, "role": "Controller",
		"desc": "Penguasa kernel dari sistem Aether-Net. Delapan tentakelnya adalah kabel bus data berkecepatan tinggi. Berbahaya bahkan saat dikalahkan.",
		"passive": "Kernel Panic — Saat dikalahkan, mengirim 25 damage flat ke lawan.",
		"advantage": "Kuat vs Data\nLemah vs Social Engineering",
		"moves": [
			{"name": "Memory Overflow", "edu_log": "Buffer overflow terjadi saat program menulis data melebihi batas memori yang dialokasikan."},
			{"name": "Process Kill", "edu_log": "Menghentikan proses kritis bisa melumpuhkan sistem operasi secara keseluruhan."},
			{"name": "System Hijack", "edu_log": "Privilege escalation memungkinkan attacker mengambil alih kontrol sistem dengan hak akses tertinggi."},
			{"name": "Fork Bomb", "edu_log": "Fork Bomb membuat proses yang terus menggandakan diri hingga sistem kehabisan resource."}
		]
	},
	{
		"id": "chamele_auth", "name": "Chamele-Auth", "number": "006",
		"type": "Social Engineering", "color": Color(1, 0.7, 0.2),
		"hp": 95, "speed": 85, "role": "Trickster",
		"desc": "Sang ahli Impersonation. Tidak pernah membobol pintu depan — ia hanya meyakinkan pintu bahwa ia adalah pemilik kuncinya.",
		"passive": "Identity Theft — 20% chance mengubah tipenya menjadi tipe lawan saat menyerang.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Phishing Cast", "edu_log": "Phishing menipu korban agar menyerahkan kredensial dengan menyamar sebagai entitas terpercaya."},
			{"name": "Spoofed Token", "edu_log": "Token spoofing memalsukan access token untuk mendapatkan akses tidak sah ke sistem."},
			{"name": "Social Override", "edu_log": "Social engineering mengeksploitasi psikologi manusia, bukan celah teknis."},
			{"name": "Pretexting", "edu_log": "Pretexting membuat skenario palsu yang meyakinkan untuk memanipulasi korban memberikan akses."}
		]
	},
	{
		"id": "vaultex", "name": "Vaultex", "number": "007",
		"type": "Data", "color": Color(0.6, 0.85, 1),
		"hp": 130, "speed": 45, "role": "Support",
		"desc": "Diciptakan oleh perusahaan perbankan siber kuno untuk membawa data paling rahasia melintasi jaringan publik. Ia tidak akan terbuka kecuali menerima kunci hash yang tepat.",
		"passive": "Checksum — Jika HP genap di akhir turn, pulihkan 5 HP.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Hash Lock", "edu_log": "Hash function mengubah data menjadi nilai unik. Jika data berubah, hash-nya akan berbeda — deteksi manipulasi secara instan."},
			{"name": "Integrity Check", "edu_log": "Integrity check memverifikasi bahwa data tidak dimodifikasi secara tidak sah sejak terakhir kali divalidasi."},
			{"name": "Data Shred", "edu_log": "Data shredding menghapus informasi secara permanen agar tidak bisa dipulihkan oleh attacker."},
			{"name": "Mirror Backup", "edu_log": "Mirror backup menyalin data secara real-time ke lokasi kedua, memastikan ketersediaan data saat terjadi kegagalan."}
		]
	},
	{
		"id": "cipher_ray", "name": "Cipher-Ray", "number": "008",
		"type": "Data", "color": Color(0.5, 0.8, 1),
		"hp": 100, "speed": 80, "role": "Attacker",
		"desc": "Predator bagi paket data yang tidak terenkripsi. Ia terbang tinggi di lapisan Upper-Net mencari celah informasi. Ia menyerang sebelum lawan sadar bahwa data mereka telah dikunci selamanya di dalam kristal sayapnya.",
		"passive": "AES-256 — 20% chance enkripsi diri saat menyerang, kurangi damage masuk berikutnya.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Brute Decrypt", "edu_log": "Brute force attack mencoba semua kombinasi kunci secara sistematis — semakin panjang kunci enkripsi, semakin lama waktu yang dibutuhkan."},
			{"name": "Key Exchange", "edu_log": "Diffie-Hellman Key Exchange memungkinkan dua pihak berbagi kunci enkripsi secara aman meski komunikasi mereka disadap."},
			{"name": "Cipher Strike", "edu_log": "Chosen-plaintext attack mengeksploitasi kelemahan cipher dengan memilih plaintext spesifik untuk dianalisis pola enkripsinya."},
			{"name": "Zero-Knowledge", "edu_log": "Zero-Knowledge Proof membuktikan pengetahuan akan sebuah rahasia tanpa mengungkapkan rahasia itu sendiri."}
		]
	},
	{
		"id": "routerex", "name": "Routerex", "number": "009",
		"type": "Connection", "color": Color(1, 0.85, 0.2),
		"hp": 105, "speed": 65, "role": "Controller",
		"desc": "Penjaga gerbang gateway utama yang mengatur lalu lintas data di pusat kota siber. Ia memiliki insting luar biasa untuk mengetahui ke mana sebuah serangan akan diarahkan, lalu dengan cepat membelokkan serangan tersebut ke jalur buntu.",
		"passive": "BGP Route — 25% chance redirect serangan lawan ke diri sendiri dengan damage -50%.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "NAT Punch", "edu_log": "NAT Traversal memungkinkan koneksi menembus firewall dan router NAT untuk mencapai perangkat di jaringan privat."},
			{"name": "Port Scan", "edu_log": "Port scanning memetakan layanan yang aktif pada sebuah host untuk menemukan celah yang bisa dieksploitasi."},
			{"name": "Bandwidth Throttle", "edu_log": "Bandwidth throttling membatasi kecepatan koneksi secara sengaja — teknik yang digunakan ISP untuk mengontrol penggunaan jaringan."},
			{"name": "Reroute", "edu_log": "BGP hijacking membelokkan trafik internet ke jalur yang salah — salah satu serangan paling berbahaya pada infrastruktur internet."}
		]
	},
	{
		"id": "latencia", "name": "Latencia", "number": "010",
		"type": "Connection", "color": Color(1, 0.7, 0.1),
		"hp": 88, "speed": 90, "role": "Speedster",
		"desc": "Hidup di dalam kabel bawah laut digital sebagai manifestasi dari hambatan jaringan. Kehadirannya sering dianggap sebagai gangguan karena kemampuannya membuat waktu seolah berhenti bagi musuh.",
		"passive": "Jitter — 30% chance serangan menyerang dua kali dengan power separuh.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "Timeout Strike", "edu_log": "Connection timeout terjadi saat server tidak merespons dalam batas waktu yang ditentukan, sering dimanfaatkan dalam serangan DoS."},
			{"name": "Packet Loss", "edu_log": "Packet loss terjadi saat data yang dikirim tidak sampai ke tujuan — bisa akibat kongesti jaringan atau serangan yang disengaja."},
			{"name": "QoS Drain", "edu_log": "QoS mengatur prioritas trafik jaringan. Menyabotase QoS bisa melumpuhkan layanan kritis seperti VoIP."},
			{"name": "Syn Flood", "edu_log": "SYN Flood mengeksploitasi TCP handshake dengan mengirim request palsu yang membanjiri antrian koneksi server."}
		]
	},
	{
		"id": "ransom_rex", "name": "Ransom-Rex", "number": "011",
		"type": "Malware", "color": Color(1, 0.2, 0.2),
		"hp": 105, "speed": 60, "role": "Controller",
		"desc": "Monster penyandera data yang paling ditakuti. Ia tidak memakan musuhnya, melainkan mengunci sistem mereka dan menuntut imbalan besar. Setiap langkahnya menimbulkan suara dentuman besi berat yang melambangkan keputusasaan sistem yang terkunci.",
		"passive": "Encryption Lock — 25% chance lock heal lawan selama 2 turn saat menyerang.",
		"advantage": "Kuat vs Connection\nLemah vs Data",
		"moves": [
			{"name": "File Encrypt", "edu_log": "Ransomware mengenkripsi file korban dengan kunci yang hanya dimiliki attacker, memaksa korban membayar tebusan untuk mendapatkan kuncinya."},
			{"name": "Ransom Note", "edu_log": "Ransom note adalah pesan yang ditampilkan ransomware kepada korban berisi instruksi pembayaran dan ancaman penghapusan data."},
			{"name": "Double Extortion", "edu_log": "Double extortion ransomware tidak hanya mengenkripsi data, tapi juga mengancam mempublikasikan data sensitif jika tebusan tidak dibayar."},
			{"name": "Decoy Payload", "edu_log": "Decoy payload menyamarkan malware sebagai file tak berbahaya untuk melewati deteksi antivirus berbasis signature."}
		]
	},
	{
		"id": "worm_ling", "name": "Worm-Ling", "number": "012",
		"type": "Malware", "color": Color(0.8, 0.3, 0.3),
		"hp": 85, "speed": 95, "role": "Swarm",
		"desc": "Masuk melalui celah update sistem yang terlupakan. Kekuatannya terletak pada kemampuannya untuk menduplikasi diri secara eksponensial. Satu spesimen di dalam sistem adalah masalah kecil, namun seribu spesimen berarti kehancuran total.",
		"passive": "Self-Replicating — Damage ke lawan naik 5 setiap kena serangan (max 3 stack).",
		"advantage": "Kuat vs Connection\nLemah vs Data",
		"moves": [
			{"name": "Propagate", "edu_log": "Worm propagation menyebar ke sistem lain secara otomatis tanpa interaksi pengguna, berbeda dari virus yang membutuhkan host file."},
			{"name": "Network Crawl", "edu_log": "Network crawling memetakan seluruh jaringan secara sistematis untuk menemukan sistem yang rentan."},
			{"name": "Payload Deploy", "edu_log": "Payload adalah komponen berbahaya dari malware yang dieksekusi setelah infeksi berhasil."},
			{"name": "Mass Infection", "edu_log": "Mass infection campaign menggunakan botnet untuk menyebarkan malware ke jutaan perangkat secara serentak."}
		]
	},
	{
		"id": "patchwork", "name": "Patchwork", "number": "013",
		"type": "Defensive", "color": Color(0.1, 0.8, 0.5),
		"hp": 140, "speed": 50, "role": "Tank/Healer",
		"desc": "Terlahir dari jutaan perbaikan darurat yang dilakukan admin sistem selama bertahun-tahun. Meskipun terlihat berantakan, ia adalah perwujudan dari sistem lama yang terus diperbarui agar tetap tangguh.",
		"passive": "Hot Patch — Setiap menerima damage di atas 30, defense otomatis naik 1.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Patch Deploy", "edu_log": "Security patch adalah pembaruan perangkat lunak yang menutup kerentanan yang ditemukan sebelum dieksploitasi attacker."},
			{"name": "Vulnerability Scan", "edu_log": "Vulnerability scanning secara proaktif mencari kelemahan dalam sistem sebelum attacker menemukannya lebih dulu."},
			{"name": "Zero-Day Shield", "edu_log": "Zero-day vulnerability adalah celah keamanan yang belum diketahui vendor — sangat berbahaya karena belum ada patch yang tersedia."},
			{"name": "Hardened Kernel", "edu_log": "Kernel hardening memperkuat inti sistem operasi dengan menonaktifkan fitur yang tidak perlu dan menerapkan kontrol akses ketat."}
		]
	},
	{
		"id": "bastion", "name": "Bastion", "number": "014",
		"type": "Defensive", "color": Color(0.3, 1, 0.7),
		"hp": 160, "speed": 35, "role": "Pure Tank",
		"desc": "Baris pertahanan terakhir bagi mainframe pusat yang tidak pernah mundur satu langkah pun. Tubuhnya adalah manifestasi dari aturan ketat Access Control List.",
		"passive": "DMZ — Serangan di bawah 15 damage diabaikan sepenuhnya.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Perimeter Strike", "edu_log": "Perimeter security membentuk lapisan pertahanan terluar jaringan — semakin kuat perimeter, semakin besar kekuatan serangan baliknya."},
			{"name": "Access Denied", "edu_log": "Access control memastikan hanya entitas yang berwenang yang bisa mengakses sumber daya — prinsip dasar keamanan informasi."},
			{"name": "Failover", "edu_log": "Failover system secara otomatis beralih ke sistem cadangan saat sistem utama gagal — menjamin ketersediaan layanan tanpa gangguan."},
			{"name": "Iron Curtain", "edu_log": "Network segmentation memisahkan jaringan menjadi zona-zona terisolasi untuk membatasi penyebaran serangan."}
		]
	},
	{
		"id": "daemon_x", "name": "Daemon-X", "number": "015",
		"type": "System", "color": Color(0.5, 0.2, 0.9),
		"hp": 100, "speed": 75, "role": "Debuffer",
		"desc": "Proses yang berjalan secara otomatis di latar belakang semesta digital. Ia menjaga dunia tetap berputar melalui tugas-tugas kecil yang tak terlihat. Namun, ia bisa menjadi sangat mematikan ketika mengeksekusi perintah untuk menghentikan paksa proses kehidupan lawannya.",
		"passive": "Background Process — 20% chance 10 damage otomatis di akhir turn.",
		"advantage": "Kuat vs Data\nLemah vs Social Engineering",
		"moves": [
			{"name": "Process Inject", "edu_log": "Process injection menyisipkan kode berbahaya ke dalam proses yang sah untuk menghindari deteksi dan mendapatkan hak akses lebih tinggi."},
			{"name": "Kill Switch", "edu_log": "Kill switch adalah mekanisme untuk menghentikan sistem secara paksa — digunakan baik sebagai fitur keamanan maupun oleh malware."},
			{"name": "Daemon Spawn", "edu_log": "Daemon adalah program background yang berjalan terus tanpa interaksi pengguna — jika disusupi, bisa menjadi ancaman persisten."},
			{"name": "Memory Leak", "edu_log": "Memory leak terjadi saat program tidak melepas memori yang sudah tidak dipakai, menyebabkan sistem melambat hingga crash."}
		]
	},
	{
		"id": "bios_wraith", "name": "BIOS-Wraith", "number": "016",
		"type": "System", "color": Color(0.7, 0.4, 1),
		"hp": 95, "speed": 55, "role": "Controller",
		"desc": "Roh dari perangkat keras pertama yang pernah diciptakan. Ia memiliki kendali penuh atas instruksi paling dasar dari keberadaan monster lain, mampu memaksa sistem lawan untuk melakukan reboot paksa dan kembali ke pengaturan awal.",
		"passive": "Legacy Code — 15% chance lawan gagal menggunakan move karena compatibility error.",
		"advantage": "Kuat vs Data\nLemah vs Social Engineering",
		"moves": [
			{"name": "BIOS Flash", "edu_log": "BIOS flashing memperbarui firmware tingkat rendah — jika dimanipulasi attacker, bisa membuat perangkat keras tidak bisa digunakan sama sekali."},
			{"name": "Boot Loop", "edu_log": "Boot loop terjadi saat sistem gagal menyelesaikan proses startup dan terus mengulang — sering akibat malware yang merusak bootloader."},
			{"name": "Overclock", "edu_log": "Overclocking memaksa prosesor bekerja di atas spesifikasi resminya — meningkatkan performa tapi juga risiko kerusakan hardware."},
			{"name": "Firmware Lock", "edu_log": "Firmware lock mengunci konfigurasi hardware sehingga tidak bisa dimodifikasi — digunakan untuk mencegah tampering pada perangkat kritis."}
		]
	},
	{
		"id": "vish_ara", "name": "Vish-Ara", "number": "017",
		"type": "Social Engineering", "color": Color(1, 0.6, 0.1),
		"hp": 90, "speed": 80, "role": "Controller",
		"desc": "Ahli manipulasi suara yang mampu meniru identitas entitas terpercaya melalui transmisi frekuensi tinggi. Ia menyerang psikologi lawan, membuat mereka ragu apakah entitas di depan mereka adalah musuh atau kawan yang sedang meminta bantuan.",
		"passive": "Vishing — 25% chance serangan lawan menyerang diri sendiri dengan 50% damage.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Voice Spoof", "edu_log": "Vishing (voice phishing) menggunakan panggilan telepon palsu untuk menipu korban agar memberikan informasi sensitif."},
			{"name": "Hypnotic Tone", "edu_log": "Social engineering berbasis suara memanfaatkan kepercayaan dan urgensi — korban sering tidak sadar mereka sedang dimanipulasi."},
			{"name": "Caller ID Fake", "edu_log": "Caller ID spoofing memalsukan nomor penelepon agar terlihat seperti berasal dari institusi terpercaya seperti bank atau kantor pemerintah."},
			{"name": "Social Script", "edu_log": "Social script adalah skenario yang disiapkan attacker untuk membangun kepercayaan korban sebelum meminta informasi sensitif."}
		]
	},
	{
		"id": "bait_eel", "name": "Bait-Eel", "number": "018",
		"type": "Social Engineering", "color": Color(1, 0.5, 0.0),
		"hp": 92, "speed": 88, "role": "Trickster",
		"desc": "Penghuni rawa data yang memancing mangsa dengan janji-janji palsu. Ia menunggu lawan mendekat karena penasaran sebelum melepaskan gelombang kejut malware yang melumpuhkan sistem saraf digital korbannya.",
		"passive": "Honeypot — 30% chance lawan skip turn jika menggunakan move dengan power lebih dari 60.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Lure Strike", "edu_log": "Lure attack memancing lawan melakukan tindakan yang menguntungkan attacker — teknik dasar dalam social engineering dan cyber deception."},
			{"name": "Watering Hole", "edu_log": "Watering hole attack menginfeksi website yang sering dikunjungi target — menunggu korban datang sendiri daripada menyerang langsung."},
			{"name": "Click Bait", "edu_log": "Clickbait menggunakan konten menarik atau mengejutkan untuk memancing klik yang mengarah ke halaman berbahaya atau mengunduh malware."},
			{"name": "Drive-by Download", "edu_log": "Drive-by download menginfeksi perangkat hanya dengan mengunjungi halaman web tanpa interaksi apapun dari pengguna."}
		]
	},
	{
		"id": "hash_hound", "name": "Hash-Hound", "number": "019",
		"type": "Data", "color": Color(0.2, 0.8, 0.9),
		"hp": 100, "speed": 65, "role": "Scout",
		"desc": "Anjing pelacak integritas data yang tak tertandingi. Setiap perubahan sekecil apapun pada sebuah bit tidak bisa luput dari penciumannya. Ia adalah garis pertahanan pertama melawan manipulasi data diam-diam.",
		"passive": "Verificator — Accuracy naik 1 stage permanen di awal pertarungan.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Hash Bite", "edu_log": "Hashing menghasilkan nilai unik untuk setiap input — bahkan perubahan 1 bit menghasilkan hash yang sama sekali berbeda, memudahkan deteksi manipulasi."},
			{"name": "Checksum", "edu_log": "Checksum adalah nilai ringkasan data yang digunakan untuk memverifikasi integritas file setelah transmisi atau penyimpanan."},
			{"name": "Integrity Scan", "edu_log": "File integrity monitoring secara terus-menerus memverifikasi bahwa file sistem tidak dimodifikasi oleh malware atau attacker."},
			{"name": "SHA Strike", "edu_log": "SHA-256 adalah algoritma hashing kriptografis yang digunakan luas untuk memverifikasi integritas data dan menyimpan password secara aman."}
		]
	},
	{
		"id": "key_lynx", "name": "Key-Lynx", "number": "020",
		"type": "Data", "color": Color(0.4, 1.0, 0.9),
		"hp": 95, "speed": 90, "role": "Breaker",
		"desc": "Lynx liar penguasa kriptografi asimetris. Ia bergerak dengan lincah di antara kunci publik dan privat, memotong celah enkripsi lemah dengan cakarnya yang tajam seperti bilah RSA.",
		"passive": "Master Key — Kebal terhadap efek status dari tipe Social Engineering.",
		"advantage": "Kuat vs Malware\nLemah vs Connection",
		"moves": [
			{"name": "Key Exchange", "edu_log": "Diffie-Hellman Key Exchange memungkinkan dua pihak berbagi kunci enkripsi secara aman meski komunikasi mereka disadap."},
			{"name": "PKI Slash", "edu_log": "Public Key Infrastructure (PKI) mengelola sertifikat digital untuk memverifikasi identitas entitas di jaringan."},
			{"name": "Asymmetric Guard", "edu_log": "Enkripsi asimetris menggunakan pasangan kunci publik-privat — data dienkripsi dengan kunci publik, hanya bisa dibuka dengan kunci privat yang sesuai."},
			{"name": "Cipher Claw", "edu_log": "Cipher suite menentukan algoritma enkripsi yang digunakan dalam koneksi TLS — pemilihan cipher suite yang lemah bisa menjadi celah keamanan."}
		]
	},
	{
		"id": "signal_snail", "name": "Signal-Snail", "number": "021",
		"type": "Connection", "color": Color(1.0, 0.75, 0.1),
		"hp": 95, "speed": 45, "role": "Support",
		"desc": "Siput fiber optik yang lambat tapi memiliki ketahanan koneksi paling stabil di seluruh Aether-Net. Tidak ada satu pun paketnya yang pernah hilang di perjalanan, bahkan saat badai data paling dahsyat.",
		"passive": "Stable Ping — Serangan tidak pernah miss meski accuracy diturunkan.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "Fiber Tackle", "edu_log": "Fiber optik mengirimkan data sebagai pulsa cahaya, menawarkan bandwidth jauh lebih tinggi dan latensi lebih rendah dibanding kabel tembaga."},
			{"name": "Packet Preserve", "edu_log": "Error correction dalam protokol jaringan memastikan data yang rusak atau hilang bisa dideteksi dan diperbaiki secara otomatis."},
			{"name": "Latency Shell", "edu_log": "Latency adalah waktu yang dibutuhkan data untuk bepergian dari sumber ke tujuan — faktor kritis dalam performa aplikasi real-time."},
			{"name": "QoS Pulse", "edu_log": "Quality of Service (QoS) memprioritaskan jenis trafik tertentu untuk memastikan layanan kritis mendapat bandwidth yang dibutuhkan."}
		]
	},
	{
		"id": "warp_wolf", "name": "Warp-Wolf", "number": "022",
		"type": "Connection", "color": Color(1.0, 0.6, 0.0),
		"hp": 85, "speed": 110, "role": "Speedster",
		"desc": "Serigala broadband yang bergerak lebih cepat dari sinyal itu sendiri. Ia adalah manifestasi dari koneksi ultra-low-latency yang memangsa sistem lambat dengan kecepatan yang tidak bisa diantisipasi lawan.",
		"passive": "Overclock — 20% chance menyerang dua kali dalam satu giliran.",
		"advantage": "Kuat vs Data\nLemah vs Malware",
		"moves": [
			{"name": "Bandwidth Burst", "edu_log": "Burst traffic terjadi saat penggunaan bandwidth melonjak tiba-tiba melebihi kapasitas normal jaringan, menyebabkan kongesti dan penurunan performa."},
			{"name": "Warp Dash", "edu_log": "Content Delivery Network (CDN) mempercepat pengiriman konten dengan mendistribusikannya ke server yang dekat dengan pengguna."},
			{"name": "CDN Strike", "edu_log": "CDN caching menyimpan konten di tepi jaringan untuk mengurangi beban server asal dan mempercepat waktu respons secara signifikan."},
			{"name": "Protocol Override", "edu_log": "Protocol downgrade attack memaksa koneksi menggunakan protokol lama yang lebih lemah, membuka celah untuk serangan man-in-the-middle."}
		]
	},
	{
		"id": "scam_serpent", "name": "Scam-Serpent", "number": "023",
		"type": "Social Engineering", "color": Color(0.9, 0.45, 0.0),
		"hp": 92, "speed": 82, "role": "Debuffer",
		"desc": "Ular maestro disinformasi yang menguasai seni kebohongan digital. Ia tidak menyerang dengan kekuatan, melainkan dengan informasi palsu yang disebarkan dengan presisi untuk membuat lawan kebingungan sebelum terkena serangan mematikan.",
		"passive": "Disinformation — 25% chance memberikan status Confused ke lawan saat serangan mengenai.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Pretext Strike", "edu_log": "Pretexting membangun skenario palsu yang meyakinkan untuk memanipulasi korban agar menyerahkan akses atau informasi sensitif."},
			{"name": "Deepfake Venom", "edu_log": "Deepfake menggunakan AI untuk membuat media palsu yang sangat meyakinkan — ancaman baru dalam social engineering dan disinformasi."},
			{"name": "Impersonation", "edu_log": "Impersonation attack menyamar sebagai seseorang yang dipercaya korban — seorang atasan, IT support, atau institusi resmi."},
			{"name": "Serpent's Charm", "edu_log": "Influence operations menggunakan psikologi massa untuk menyebarkan narasi palsu secara luas, mengubah persepsi publik terhadap suatu isu."}
		]
	},
	{
		"id": "sentry_stinger", "name": "Sentry-Stinger", "number": "024",
		"type": "Defensive", "color": Color(0.15, 0.95, 0.45),
		"hp": 98, "speed": 78, "role": "Scout",
		"desc": "Tawon pengintai dengan ratusan lensa sensor yang mampu mendeteksi anomali sekecil perubahan satu byte dalam log sistem. Ia adalah sistem peringatan dini yang tidak pernah tidur.",
		"passive": "Deep Scan — Selalu melihat HP lawan secara akurat, accuracy naik 10% permanen.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Log Sting", "edu_log": "Security logging mencatat semua aktivitas sistem untuk analisis forensik dan deteksi ancaman — log yang baik adalah fondasi investigasi insiden."},
			{"name": "Anomaly Alert", "edu_log": "Anomaly detection menggunakan baseline perilaku normal untuk mengidentifikasi aktivitas mencurigakan yang mungkin mengindikasikan serangan."},
			{"name": "IDS Pulse", "edu_log": "Intrusion Detection System (IDS) memantau trafik jaringan dan aktivitas sistem untuk mendeteksi tanda-tanda serangan atau pelanggaran kebijakan."},
			{"name": "Threat Hunt", "edu_log": "Threat hunting adalah pendekatan proaktif mencari ancaman tersembunyi yang sudah masuk ke dalam sistem sebelum menimbulkan kerusakan."}
		]
	},
	{
		"id": "radar_rhino", "name": "Radar-Rhino", "number": "025",
		"type": "Defensive", "color": Color(0.1, 0.75, 0.35),
		"hp": 130, "speed": 50, "role": "Controller",
		"desc": "Badak raksasa dengan cula antena parabola yang mampu menangkap sinyal anomali dari seluruh penjuru jaringan. Ia adalah komandan pusat monitoring yang tak pernah melewatkan satu pun pergerakan mencurigakan.",
		"passive": "Auto-Alert — Setiap kali lawan menggunakan buff, Attack Radar-Rhino naik 1 stage.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "SIEM Sweep", "edu_log": "Security Information and Event Management (SIEM) mengumpulkan dan menganalisis log dari seluruh infrastruktur untuk memberikan visibilitas keamanan terpusat."},
			{"name": "Radar Lock", "edu_log": "Threat intelligence platform mengumpulkan, menganalisis, dan mendistribusikan informasi tentang ancaman siber untuk meningkatkan respons keamanan."},
			{"name": "Horn Charge", "edu_log": "Incident response yang cepat dan terstruktur dapat meminimalkan dampak pelanggaran keamanan dan mempercepat pemulihan sistem."},
			{"name": "Full Spectrum Scan", "edu_log": "Full-spectrum cyber monitoring mencakup pemantauan jaringan, endpoint, aplikasi, dan cloud secara bersamaan untuk deteksi ancaman komprehensif."}
		]
	},
	{
		"id": "phish_falcon", "name": "Phish-Falcon", "number": "026",
		"type": "Social Engineering", "color": Color(1.0, 0.55, 0.05),
		"hp": 88, "speed": 92, "role": "Speedster",
		"desc": "Elang pemburu yang mengincar target spesifik dengan presisi mematikan. Ia tidak membuang energi menyerang sembarang orang — setiap serangannya adalah spear phishing yang dirancang khusus untuk menembus pertahanan individu tertentu.",
		"passive": "Lure — Menurunkan Defense lawan 1 stage saat pertama kali masuk arena.",
		"advantage": "Kuat vs System\nLemah vs Connection",
		"moves": [
			{"name": "Spear Dive", "edu_log": "Spear phishing menargetkan individu spesifik dengan pesan yang dipersonalisasi menggunakan informasi yang dikumpulkan dari sumber publik."},
			{"name": "Credential Hook", "edu_log": "Credential harvesting menggunakan halaman login palsu untuk mencuri username dan password korban tanpa sepengetahuan mereka."},
			{"name": "Whaling Strike", "edu_log": "Whaling attack adalah spear phishing yang menargetkan eksekutif senior atau pejabat tinggi yang memiliki akses ke aset bernilai tinggi."},
			{"name": "Clone Attack", "edu_log": "Clone phishing menduplikasi email legitimate yang pernah diterima korban, mengganti lampiran atau link dengan versi berbahaya."}
		]
	},
	{
		"id": "brick_bear", "name": "Brick-Bear", "number": "027",
		"type": "Defensive", "color": Color(0.15, 0.45, 0.9),
		"hp": 145, "speed": 40, "role": "Tank",
		"desc": "Beruang yang tersusun dari balok-balok aturan keamanan. Setiap balok adalah satu rule firewall yang tidak bisa dilanggar. Ia menerima semua serangan dengan dada bidang dan memastikan semuanya memantul kembali.",
		"passive": "Hardened — Menerima 10% lebih sedikit damage dari semua serangan.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "Packet Filter", "edu_log": "Packet filtering memeriksa header setiap paket data dan memblokir atau mengizinkan berdasarkan aturan keamanan yang telah ditetapkan."},
			{"name": "Rule Block", "edu_log": "Firewall rules mendefinisikan trafik mana yang diizinkan atau diblokir — konfigurasi yang tepat adalah kunci keamanan perimeter."},
			{"name": "Fortify", "edu_log": "System hardening mengurangi attack surface dengan menonaktifkan layanan yang tidak perlu dan menerapkan principle of least privilege."},
			{"name": "Bear Slam", "edu_log": "Stateful packet inspection menganalisis konteks koneksi penuh, bukan hanya header paket individual, untuk deteksi ancaman yang lebih akurat."}
		]
	},
	{
		"id": "gate_gorilla", "name": "Gate-Gorilla", "number": "028",
		"type": "Defensive", "color": Color(0.1, 0.35, 0.85),
		"hp": 170, "speed": 30, "role": "Pure Tank",
		"desc": "Gorilla raksasa penjaga gerbang utama Elysium — benteng terakhir sebelum core sistem bisa disentuh. Ia adalah embodiment dari Zero Trust Architecture yang tidak mempercayai siapapun tanpa verifikasi.",
		"passive": "Port Blocker — 15% chance membatalkan serangan berikutnya lawan setelah setiap benturan.",
		"advantage": "Kuat vs Social Engineering\nLemah vs System",
		"moves": [
			{"name": "WAF Strike", "edu_log": "Web Application Firewall (WAF) memfilter dan memantau trafik HTTP untuk melindungi aplikasi web dari serangan seperti SQL injection dan XSS."},
			{"name": "Zero Trust Lock", "edu_log": "Zero Trust Security tidak mempercayai siapapun secara default, bahkan pengguna internal — setiap akses harus diverifikasi secara eksplisit."},
			{"name": "Perimeter Crush", "edu_log": "Defense in depth menggunakan lapisan pertahanan berlapis sehingga jika satu lapisan gagal, lapisan berikutnya tetap melindungi sistem."},
			{"name": "Gate Slam", "edu_log": "Network Access Control (NAC) memastikan hanya perangkat yang memenuhi kebijakan keamanan yang diizinkan masuk ke jaringan."}
		]
	}
]

func _ready():
	build_ui()
	show_monster(monsters_data[0])

func build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	for i in range(0, 1152, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)

	# Header
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.08, 0.08, 0.22)
	header_bg.size = Vector2(1152, 48)
	add_child(header_bg)

	var header_border = ColorRect.new()
	header_border.color = Color(0.4, 0.9, 1, 0.5)
	header_border.size = Vector2(1152, 2)
	header_border.position = Vector2(0, 48)
	add_child(header_border)

	var title = create_label("◈  Protocol-Link", Vector2(20, 12), 20, Color(0.4, 0.9, 1))
	add_child(title)

	var count = create_label(str(monsters_data.size()) + " Sentinels Registered", Vector2(0, 15), 13, Color(0.5, 0.5, 0.7))
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.custom_minimum_size = Vector2(1132, 20)
	add_child(count)

	# ── LEFT PANEL — sprite area (fixed) ──
	var left_bg = ColorRect.new()
	left_bg.color = Color(0.07, 0.07, 0.2, 0.95)
	left_bg.size = Vector2(480, 598)
	left_bg.position = Vector2(0, 50)
	add_child(left_bg)

	var sprite_area = ColorRect.new()
	sprite_area.color = Color(0.1, 0.1, 0.28)
	sprite_area.size = Vector2(480, 190)
	sprite_area.position = Vector2(0, 50)
	sprite_area.name = "sprite_area"
	add_child(sprite_area)

	# sprite_area tetap ada sebagai background, sprite-nya diisi oleh show_monster() via SentinelSprites

	# ── LEFT PANEL — scrollable detail ──
	var detail_scroll_container = ScrollContainer.new()
	detail_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	detail_scroll_container.position = Vector2(15, 242)
	detail_scroll_container.size = Vector2(463, 406)
	detail_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(detail_scroll_container)
	detail_scroll_container.follow_focus = true
	detail_scroll = detail_scroll_container

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.custom_minimum_size = Vector2(440, 0)
	vbox.add_theme_constant_override("separation", 6)
	detail_scroll_container.add_child(vbox)
	detail_vbox = vbox

	# Number
	detail_labels["number"] = create_label("#001", Vector2(0, 0), 13, Color(0.5, 0.5, 0.7))
	vbox.add_child(detail_labels["number"])

	# Name
	detail_labels["name"] = create_label("Encryp-Pup", Vector2(0, 0), 24, Color(0.4, 0.8, 1))
	vbox.add_child(detail_labels["name"])

	# Type + Role
	var type_role = HBoxContainer.new()
	vbox.add_child(type_role)
	detail_labels["type_badge"] = create_label("[ Data ]", Vector2(0, 0), 12, Color(0.6, 0.6, 0.9))
	type_role.add_child(detail_labels["type_badge"])
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(10, 0)
	type_role.add_child(sp)
	detail_labels["role"] = create_label("Defender", Vector2(0, 0), 12, Color(1, 0.8, 0.3))
	type_role.add_child(detail_labels["role"])

	vbox.add_child(_divider())

	# Desc
	detail_labels["desc"] = create_label("", Vector2(0, 0), 11, Color(0.75, 0.75, 0.85))
	detail_labels["desc"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["desc"].custom_minimum_size = Vector2(440, 0)
	vbox.add_child(detail_labels["desc"])

	vbox.add_child(_divider())

	# Stats
	vbox.add_child(create_label("STATS", Vector2(0, 0), 11, Color(0.5, 0.7, 1)))
	var stats_box = HBoxContainer.new()
	vbox.add_child(stats_box)
	detail_labels["hp"] = create_label("HP: 120", Vector2(0, 0), 12, Color(0.3, 1, 0.4))
	stats_box.add_child(detail_labels["hp"])
	var sp2 = Control.new()
	sp2.custom_minimum_size = Vector2(20, 0)
	stats_box.add_child(sp2)
	detail_labels["speed"] = create_label("SPD: 60", Vector2(0, 0), 12, Color(1, 0.8, 0.3))
	stats_box.add_child(detail_labels["speed"])

	vbox.add_child(_divider())

	# Passive
	vbox.add_child(create_label("PASSIVE", Vector2(0, 0), 11, Color(1, 0.8, 0.3)))
	detail_labels["passive"] = create_label("", Vector2(0, 0), 11, Color(0.9, 0.85, 0.6))
	detail_labels["passive"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["passive"].custom_minimum_size = Vector2(440, 0)
	vbox.add_child(detail_labels["passive"])

	vbox.add_child(_divider())

	# Advantage
	vbox.add_child(create_label("Domain Advantage", Vector2(0, 0), 11, Color(0.4, 1, 0.4)))
	detail_labels["advantage"] = create_label("", Vector2(0, 0), 11, Color(0.7, 1, 0.7))
	detail_labels["advantage"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["advantage"].custom_minimum_size = Vector2(440, 0)
	vbox.add_child(detail_labels["advantage"])

	# ── RIGHT PANEL ──
	var right_bg = ColorRect.new()
	right_bg.color = Color(0.06, 0.06, 0.18, 0.95)
	right_bg.size = Vector2(660, 598)
	right_bg.position = Vector2(492, 50)
	add_child(right_bg)

	var right_border = ColorRect.new()
	right_border.color = Color(0.2, 0.2, 0.4)
	right_border.size = Vector2(2, 598)
	right_border.position = Vector2(492, 50)
	add_child(right_border)

	add_child(create_label("All Sentinels", Vector2(510, 88), 13, Color(0.5, 0.6, 0.8)))

	# Grid scroll container
	var grid_scroll = ScrollContainer.new()
	grid_scroll.position = Vector2(494, 110)
	grid_scroll.size = Vector2(648, 192)
	grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	grid_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	add_child(grid_scroll)

	# Control wrapper agar ScrollContainer bisa detect ukuran konten
	var grid_wrapper = Control.new()
	grid_wrapper.custom_minimum_size = Vector2(620, 300)
	grid_scroll.add_child(grid_wrapper)

	var grid_container = Node2D.new()
	grid_wrapper.add_child(grid_container)

	build_monster_grid(grid_container)

	# Move section header — dengan background jelas
	var move_header_bg = ColorRect.new()
	move_header_bg.color = Color(0.12, 0.15, 0.3, 0.95)
	move_header_bg.size = Vector2(650, 28)
	move_header_bg.position = Vector2(494, 308)
	add_child(move_header_bg)

	var move_header_border = ColorRect.new()
	move_header_border.color = Color(0.4, 0.6, 1, 0.8)
	move_header_border.size = Vector2(650, 2)
	move_header_border.position = Vector2(494, 293)
	add_child(move_header_border)

	add_child(create_label("MOVE SET & EDU-LOG", Vector2(510, 314), 12, Color(0.6, 0.8, 1)))

	# 4 Move slots
	for i in 4:
		var move_bg = ColorRect.new()
		move_bg.color = Color(0.1, 0.12, 0.28, 0.95)
		move_bg.size = Vector2(648, 76)
		move_bg.position = Vector2(494, 338 + i * 80)
		add_child(move_bg)

		var move_accent = ColorRect.new()
		move_accent.color = Color(0.4, 0.6, 1, 0.5)
		move_accent.size = Vector2(3, 76)
		move_accent.position = Vector2(494, 323 + i * 80)
		add_child(move_accent)

		var move_name_lbl = create_label("Move " + str(i+1), Vector2(503, 329 + i * 80), 13, Color(0.85, 0.92, 1))
		move_name_lbl.name = "move_name_" + str(i)
		add_child(move_name_lbl)

		var move_edu_lbl = create_label("", Vector2(503, 347 + i * 80), 11, Color(0.55, 0.8, 0.6))
		move_edu_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		move_edu_lbl.custom_minimum_size = Vector2(630, 42)
		move_edu_lbl.name = "move_edu_" + str(i)
		add_child(move_edu_lbl)

		move_labels.append({
			"name": move_name_lbl,
			"edu": move_edu_lbl,
			"bg": move_bg,
			"accent": move_accent
		})

	# Back button — terakhir agar di atas semua
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(1022, 608)
	back_btn.size = Vector2(110, 30)

	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.25, 0.15, 0.45)
	back_style.corner_radius_top_left = 5
	back_style.corner_radius_top_right = 5
	back_style.corner_radius_bottom_left = 5
	back_style.corner_radius_bottom_right = 5
	back_style.border_color = Color(0.5, 0.3, 0.8)
	back_style.border_width_left = 1
	back_style.border_width_right = 1
	back_style.border_width_top = 1
	back_style.border_width_bottom = 1

	var back_hover = back_style.duplicate()
	back_hover.bg_color = Color(0.35, 0.2, 0.6)
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_stylebox_override("hover", back_hover)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.8, 0.7, 1))
	back_btn.pressed.connect(go_back)
	add_child(back_btn)

func _divider() -> ColorRect:
	var d = ColorRect.new()
	d.color = Color(0.3, 0.3, 0.5, 0.4)
	d.custom_minimum_size = Vector2(440, 1)
	return d

func build_monster_grid(parent: Node):
	var cols = 6
	var cell_size = Vector2(88, 88)
	var start = Vector2(5, 5)

	for i in monsters_data.size():
		var m = monsters_data[i]
		var col_idx = i % cols
		var row_idx = i / cols
		var pos = start + Vector2(col_idx * (cell_size.x + 8), row_idx * (cell_size.y + 8))

		var cell_bg = ColorRect.new()
		cell_bg.color = Color(0.1, 0.1, 0.28)
		cell_bg.size = cell_size
		cell_bg.position = pos
		parent.add_child(cell_bg)

		var cell_style = StyleBoxFlat.new()
		cell_style.bg_color = Color(0.1, 0.1, 0.28)
		cell_style.border_color = Color(m["color"].r, m["color"].g, m["color"].b, 0.4)
		cell_style.border_width_left = 1
		cell_style.border_width_right = 1
		cell_style.border_width_top = 1
		cell_style.border_width_bottom = 1
		cell_style.corner_radius_top_left = 6
		cell_style.corner_radius_top_right = 6
		cell_style.corner_radius_bottom_left = 6
		cell_style.corner_radius_bottom_right = 6

		var cell_panel = PanelContainer.new()
		cell_panel.size = cell_size
		cell_panel.position = pos
		cell_panel.add_theme_stylebox_override("panel", cell_style)
		parent.add_child(cell_panel)

		SentinelSprites.draw(parent, m["id"], pos + Vector2(44, 36), m["color"], 32)

		var num = create_label("#" + m["number"], pos + Vector2(4, 58), 9, Color(0.5, 0.5, 0.7))
		parent.add_child(num)

		var short_name = m["name"].split("-")[0]
		var name_lbl = create_label(short_name, pos + Vector2(0, 72), 10, m["color"])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.custom_minimum_size = Vector2(cell_size.x, 14)
		parent.add_child(name_lbl)

		var btn = Button.new()
		btn.size = cell_size
		btn.position = pos
		btn.flat = true
		btn.modulate = Color(1, 1, 1, 0)
		var idx = i
		btn.pressed.connect(func(): show_monster(monsters_data[idx]))
		parent.add_child(btn)

		grid_buttons.append({"panel": cell_panel, "style": cell_style, "monster": m})

func show_monster(m: Dictionary):
	selected_monster = m
	var col = m["color"]

	# Update background area color
	var area = find_child("sprite_area", true, false)
	if area: area.color = Color(col.r * 0.25, col.g * 0.25, col.b * 0.25, 1.0)

	# Hapus sprite lama, ganti dengan sprite baru dari SentinelSprites
	var old_sprite = find_child("sentinel_display", true, false)
	if old_sprite: old_sprite.queue_free()
	var new_sprite = SentinelSprites.draw(self, m["id"], Vector2(240, 148), col, 90)
	new_sprite.name = "sentinel_display"

	detail_labels["number"].text = "#" + m["number"]
	detail_labels["name"].text = m["name"]
	detail_labels["name"].add_theme_color_override("font_color", col)
	detail_labels["type_badge"].text = "[ " + m["type"] + " ]"
	detail_labels["type_badge"].add_theme_color_override("font_color", col)
	detail_labels["role"].text = m["role"]
	detail_labels["desc"].text = m["desc"]
	detail_labels["hp"].text = "HP: " + str(m["hp"])
	detail_labels["speed"].text = "SPD: " + str(m["speed"])
	detail_labels["passive"].text = m["passive"]
	detail_labels["advantage"].text = m["advantage"]

	# Update 4 moves
	for i in m["moves"].size():
		if i < move_labels.size():
			var col_accent = col
			move_labels[i]["name"].text = "▸ " + m["moves"][i]["name"]
			move_labels[i]["edu"].text = m["moves"][i]["edu_log"]
			move_labels[i]["bg"].color = Color(col.r * 0.12, col.g * 0.12, col.b * 0.18, 0.95)
			move_labels[i]["accent"].color = Color(col_accent.r, col_accent.g, col_accent.b, 0.7)

	# Scroll detail kembali ke atas
	if detail_scroll:
		detail_scroll.scroll_vertical = 0

	# Highlight grid
	for g in grid_buttons:
		var is_selected = g["monster"]["id"] == m["id"]
		g["style"].border_color = Color(
			g["monster"]["color"].r,
			g["monster"]["color"].g,
			g["monster"]["color"].b,
			1.0 if is_selected else 0.4
		)
		g["style"].border_width_left = 3 if is_selected else 1
		g["style"].border_width_right = 3 if is_selected else 1
		g["style"].border_width_top = 3 if is_selected else 1
		g["style"].border_width_bottom = 3 if is_selected else 1
		g["panel"].add_theme_stylebox_override("panel", g["style"])

func go_back():
	var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
