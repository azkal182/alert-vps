# VPS Telegram Alert

Bot monitoring ringan untuk VPS menggunakan shell script (sh) yang akan mengirim alert ke Telegram jika penggunaan CPU atau RAM terlalu tinggi.

## Features

- Ringan
- Tanpa Python
- Menggunakan /proc
- Auto monitoring via cron
- Support auto install 1 command
- Support parameter BOT_TOKEN & CHAT_ID
- Support input manual di terminal

---

# Install

## Auto Install (Dengan Parameter)

bash id="ml48mz" sh -c "$(curl -fsSL https://raw.githubusercontent.com/Azkal182/alert-vps/main/install.sh)" -- BOT_TOKEN CHAT_ID 

Contoh:

bash id="l10s0j" sh -c "$(curl -fsSL https://raw.githubusercontent.com/Azkal182/alert-vps/main/install.sh)" -- 123456:ABCDEF 987654321 

---

## Auto Install (Input Manual)

bash id="kjp1cq" sh -c "$(curl -fsSL https://raw.githubusercontent.com/Azkal182/alert-vps/main/install.sh)" 

Installer akan meminta:

- BOT_TOKEN
- CHAT_ID

---

# Cara Membuat Bot Telegram

## 1. Buat Bot

Chat ke:

@BotFather

Ketik:

text id="zqzvhs" /newbot 

Lalu ikuti instruksi.

Simpan BOT_TOKEN yang diberikan.

---

## 2. Ambil CHAT_ID

Kirim pesan apa saja ke bot kamu.

Lalu buka:

text id="xv8y5k" https://api.telegram.org/botBOT_TOKEN/getUpdates 

Cari:

json id="u1f8zc" "chat":{"id":123456789} 

Angka tersebut adalah CHAT_ID.

---

# Default Configuration

sh id="k1k9aa" CPU_LIMIT=90 RAM_LIMIT=90 COOLDOWN=300 

Artinya:

- Alert jika CPU >= 90%
- Alert jika RAM >= 90%
- Cooldown alert 5 menit

---

# File Location

text id="o7avm8" /root/vps-alert.sh 

---

# Edit Configuration

bash id="a7jx7i" nano /root/vps-alert.sh 

---

# Manual Test

bash id="srmbl4" /root/vps-alert.sh 

---

# Cron Check

bash id="72uhjg" crontab -l 

Default berjalan tiap 1 menit.

---

# Remove

bash id="vhixol" crontab -l | grep -v '/root/vps-alert.sh' | crontab - rm -f /root/vps-alert.sh 

---

# License

MIT License