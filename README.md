# Protocol: Elysium
> Cybersecurity Battle Simulator — Godot 4 Prototype

![Godot](https://img.shields.io/badge/Godot-4.x-blue) 

---

## Tentang Game

<img width="1100" height="650" alt="Screenshot 2026-03-12 131440" src="https://github.com/user-attachments/assets/0cdb2b10-2e9f-4783-8233-812e7d2a62a5" />
---
<img width="1100" height="645" alt="Screenshot 2026-03-12 131508" src="https://github.com/user-attachments/assets/d2a70f1c-4946-4d1d-932d-6b61f8174faa" />
---
<img width="1100" height="653" alt="Screenshot 2026-03-12 131544" src="https://github.com/user-attachments/assets/9a55649b-3357-40ed-9fba-fd71d40e451f" />
---
**Protocol: Elysium** adalah game battle simulator berbasis giliran (turn-based) bertemakan keamanan siber. Setiap karakter dalam game disebut **Sentinel** dan mereka merepresentasikan konsep nyata dalam dunia cybersecurity, mulai dari enkripsi, malware, social engineering, hingga sistem pertahanan jaringan.

Game ini dirancang sebagai media pembelajaran interaktif yang membuat konsep keamanan siber lebih mudah dipahami melalui gameplay.

---

## Fitur

- ⚔️ **Turn-based battle system** dengan 4 move per Sentinel
- 🛡️ **18 Sentinel** unik dengan passive ability dan move set berbeda
- 🌐 **6 Domain** (tipe) dengan sistem keunggulan tipe (type advantage)
- 📖 **EDU-LOG** — setiap move menampilkan penjelasan konsep cybersecurity
- 📡 **Protocol-Link** — ensiklopedia lengkap semua Sentinel beserta edu-log move
- 🎵 **Sound effects** procedural (generated via AudioStreamGenerator)
- ✨ **Animasi** — battle intro, particles, title fade-in
- 🎨 **Battle scene** dengan platform dan depth perspektif

---

## Domain & Type Advantage

| Domain | Kuat vs | Lemah vs |
|---|---|---|
| Data | Malware | Connection |
| Connection | Data | Malware |
| Malware | Connection | Data |
| Defensive | Social Engineering | System |
| System | Data | Social Engineering |
| Social Engineering | System | Connection |

---

## Daftar Sentinel

### Data Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 001 | Encryp-Pup | Defender | Hardened Shell |
| 007 | Vaultex | Support | Checksum |
| 008 | Cipher-Ray | Attacker | AES-256 |

### Connection Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 002 | Ping-Go | Speedster | Low Latency |
| 009 | Routerex | Controller | BGP Route |
| 010 | Latencia | Speedster | Jitter |

### Malware Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 003 | Biti | Strategist | Polymorphic |
| 011 | Ransom-Rex | Controller | Encryption Lock |
| 012 | Worm-Ling | Swarm | Self-Replicating |

### Defensive Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 004 | Senti-Shell | Tank | Redundancy |
| 013 | Patchwork | Tank/Healer | Hot Patch |
| 014 | Bastion | Pure Tank | DMZ |

### System Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 005 | Octo-Core | Controller | Kernel Panic |
| 015 | Daemon-X | Debuffer | Background Process |
| 016 | BIOS-Wraith | Controller | Legacy Code |

### Social Engineering Domain
| # | Nama | Role | Passive |
|---|---|---|---|
| 006 | Chamele-Auth | Trickster | Identity Theft |
| 017 | Vish-Ara | Controller | Vishing |
| 018 | Bait-Eel | Trickster | Honeypot |

---

## Struktur Project

```
res://
├── battle/
│   ├── Battle.tscn
│   ├── Battle.gd          # UI battle + animasi
│   ├── BattleManager.gd   # Logic turn, alur battle, signals
│   ├── MoveEffects.gd     # Semua efek move (static functions)
│   └── SoundManager.gd    # Sound effects procedural
├── menus/
│   ├── main_menu/
│   │   ├── MainMenu.tscn
│   │   └── MainMenu.gd
│   ├── selection/
│   │   ├── SelectionScreen.tscn
│   │   └── SelectionScreen.gd
│   ├── result/
│   │   ├── ResultScreen.tscn
│   │   └── ResultScreen.gd
│   └── cyberdex/
│       ├── CyberDex.tscn
│       └── CyberDex.gd    # Protocol-Link encyclopedia
├── entities/
│   └── Monster.gd         # Data class Sentinel (class_name Monster)
├── data/
│   └── monsters.json      # Data semua 18 Sentinel
└── assets/
    └── (sprites, sounds — planned)
```

---

## Cara Menjalankan

1. Install **Godot 4.x** dari [godotengine.org](https://godotengine.org)
2. Clone repo ini
3. Buka Godot → Import Project → pilih folder repo
4. Tekan **F5** atau tombol Play

---

## Battle System

### Alur Battle
1. Player memilih Sentinel di Selection Screen
2. Enemy Sentinel dipilih secara random
3. Giliran ditentukan oleh stat **Speed** — Sentinel lebih cepat menyerang duluan
4. Setiap move memiliki **power**, **effect**, dan **cooldown**
5. Battle berakhir saat salah satu Sentinel kehabisan HP

### Sistem Cooldown
- Move dengan efek kuat memiliki cooldown 1–4 turn
- Tombol move yang sedang cooldown ditampilkan sebagai `[COOLDOWN]`

### Status Effects
- **Speed Debuff** — kecepatan berkurang 50%
- **Block** — skip 1 turn
- **Heal Lock** — tidak bisa menggunakan heal move
- **Firmware Lock** — tidak bisa menggunakan utility move
- **DoT** — damage over time per turn
- **Zero-Day Shield** — block 1 serangan sepenuhnya
- **Confuse** — 40% chance skip turn

---

## Konsep Cybersecurity yang Diajarkan

Game ini mencakup konsep-konsep berikut melalui EDU-LOG setiap move:

- Enkripsi (AES, SSL/TLS, Zero-Knowledge Proof)
- Network security (BGP, NAT, Port Scanning, DDoS, SYN Flood)
- Malware (Ransomware, Worm, Trojan, Rootkit, Polymorphic)
- Defensive security (Patch Management, Zero-Day, DMZ, Firewall)
- System security (Buffer Overflow, Process Injection, BIOS/Firmware)
- Social Engineering (Phishing, Vishing, Pretexting, Honeypot)

---

## Development

**Engine:** Godot 4.x  
**Language:** GDScript  
**Status:** Prototype v0.2

### Planned Features
- [ ] Custom sprite art untuk semua 18 Sentinel
- [ ] Team battle (pilih 2–3 Sentinel)
- [ ] Difficulty system (AI lebih pintar)
- [ ] BGM procedural
- [ ] More Sentinels

---

## Credits

Dibuat menggunakan **Godot Engine 4**  
Konsep cybersecurity berdasarkan materi keamanan informasi standar industri
