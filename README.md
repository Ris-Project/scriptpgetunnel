# ScriptPGetunnel — Versi REPO PRIVATE (GitHub Token)

Versi ini dimodifikasi agar **seluruh script bisa berjalan dari repo GitHub PRIVATE**
menggunakan **Personal Access Token (PAT)**. Semua pengambilan file dari repo
(`raw.githubusercontent.com`) otomatis menyertakan header:

```
Authorization: token <GH_TOKEN>
```

> ⚠️ **PENTING — SEBELUM DIGUNAKAN**
> File lama sempat menyimpan token GitHub secara hardcoded di dalam script
> registrasi (`literegis`, dll). Token tersebut sudah dihapus dari script ini,
> tetapi karena pernah terekspose, **segera REVOKE/HAPUS token lama** di
> GitHub → Settings → Developer settings → Personal access tokens, lalu buat
> token baru. Token bot Telegram yang lama juga disarankan di-rotasi lewat
> @BotFather bila pernah tersebar.

---

## 1. Siapkan Repo Private

1. Buat repo **private** di GitHub, contoh: `usernameanda/scriptpgetunnel`.
2. Upload **seluruh isi** zip ini ke repo (root repo harus berisi
   `install.sh`, `update.sh`, `udepe.sh`, folder `menu/`, `bot/`, `config/`,
   `files/`, `ping/`, `ip`, `ip-bot`, `udp.zip`, dst — struktur sama persis
   dengan zip ini).
3. Cabang default: `main`.

## 2. Buat Personal Access Token (PAT)

**Cara disarankan — Fine-grained token:**
1. GitHub → Settings → Developer settings → Personal access tokens →
   **Fine-grained tokens** → Generate new token.
2. **Repository access**: pilih *Only select repositories* → repo private Anda.
3. **Permissions → Contents**: **Read and write**
   (Read untuk install/update, Write untuk registrasi IP via script `lite*`).
4. Expiration: sesuai kebutuhan (mis. 1 tahun).
5. Salin token (format `github_pat_...`).

**Alternatif — Classic token:**
- Settings → Developer settings → Tokens (classic) → Generate new token,
  centang scope **`repo`** (full control of private repositories).

> Satu token dipakai bersama: VPS utama (registrasi/push) dan VPS reseller
> (install/update/read). Kunci akses tetap dibatasi oleh daftar IP di file `ip`.

## 3. Install di VPS (Pemasangan Tahap 1 & 2)

Tahap 1 — persiapan & reboot:
```
apt update -y && apt upgrade -y --fix-missing && apt install -y xxd bzip2 wget curl sudo lsof socat net-tools bc coreutils build-essential bsdmainutils screen dos2unix && update-grub && apt dist-upgrade -y && sleep 2 && reboot
```

Tahap 2 — install script dari repo private:
```
export GH_USER="usernameanda"
export GH_REPO="scriptpgetunnel"
export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

wget -q --header="Authorization: token $GH_TOKEN" \
  "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/install.sh" \
  -O install.sh && chmod +x install.sh && \
GH_TOKEN=$GH_TOKEN GH_USER=$GH_USER GH_REPO=$GH_REPO \
  screen -S setup-session bash -c "./install.sh; read -p 'Tekan enter untuk keluar...'"
```

Keterangan:
- `install.sh` **meminta token otomatis** bila tidak diberikan lewat env
  (input tersembunyi), lalu **memvalidasi token** ke repo sebelum melanjutkan
  (HTTP 200 = token & repo OK).
- Setelah install selesai, kredensial disimpan di `/etc/gh-token.conf`
  (permission `600`, root-only) agar semua menu di VPS tetap bisa mengakses
  repo tanpa perlu export manual lagi.

Resume bila terputus saat install:
```
screen -r -d setup
```

### Tampilan Installer Baru (UI)

Installer kini memakai tampilan baru bertema warna **neon cyan → violet**:

| Bagian | Tampilan |
| --- | --- |
| Pembuka | Banner ASCII `PIX` gradasi warna + tagline `PGTUNNEL · Autoscript Installer` |
| Token | Panel `REPO PRIVATE — GITHUB TOKEN DIBUTUHKAN`, input tersembunyi, spinner animasi saat validasi token |
| Token salah | Box error rapi berisi arti HTTP 404/403 dan izin PAT yang dibutuhkan |
| Cek izin IP | Spinner `Mendeteksi IP publik server` + `Mengecek izin akses di repo`, hasil ✔/✘ berwarna |
| Cek sistem | Panel `IP SERVER / ARSITEKTUR / SISTEM OPERASI / REPO TARGET` dengan tanda ✔ didukung |
| Proses install | Bar progres `[████░░░░] 05/25 ▸ Memasang Nginx...` untuk tiap langkah, lalu `✔ ... berhasil dipasang` |
| Menu domain | Panel pilihan `[01] domain sendiri / [02] domain bawaan` |
| Layar akhir | Banner + panel ringkasan: durasi install, IP, domain, OS, RAM |

Logika instalasi, alur token (`GH_TOKEN` env → prompt → validasi → `/etc/gh-token.conf`),
dan seluruh wrapper repo private **tidak berubah** — hanya tampilan.

## 4. Update Script

```
export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
wget -q --header="Authorization: token $GH_TOKEN" \
  "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/update.sh" \
  -O update.sh && chmod +x update.sh && GH_TOKEN=$GH_TOKEN ./update.sh && rm -f update.sh
```
(`update.sh` juga otomatis membaca `/etc/gh-token.conf`, jadi di VPS yang sudah
terinstall cukup jalankan `update` dari menu.)

## 5. UDP Custom

```
export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
wget -q --header="Authorization: token $GH_TOKEN" \
  "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/udepe.sh" \
  -O udepe.sh && chmod +x udepe.sh && GH_TOKEN=$GH_TOKEN ./udepe.sh && rm -f udepe.sh
```

## 6. Cara Kerja Perubahan Ini

| Komponen | Perilaku baru |
| --- | --- |
| `curl` / `wget` di semua script | Dibungkus fungsi: URL repo → otomatis + header `Authorization: token $GH_TOKEN`. URL lain (speedtest, cek IP, xray installer, dll) tidak tersentuh. |
| Owner/repo/branch | Dinamis via `GH_USER`, `GH_REPO`, `GH_BRANCH` (default `Ris-Project/scriptpgetunnel/main`). Ganti dengan export env bila repo Anda beda nama. |
| Token sumber | 1) env `GH_TOKEN` → 2) `/etc/gh-token.conf`. |
| `install.sh` | Prompt token (hidden input) + validasi HTTP + simpan `/etc/gh-token.conf` (chmod 600). |
| Script registrasi `lite*` (regis/extend/ubah/delete) | `git clone` & `git push` memakai `https://$GH_USER:$GH_TOKEN@github.com/...` — token tidak lagi hardcoded. |
| Bot Python (`daftarip.py`, bot private) | `requests.get` ke file `ip` menyertakan header token (env atau `/etc/gh-token.conf`). |
| Instruksi install yang dikirim bot ke reseller | Sudah disisipkan `--header='Authorization: token ...'` otomatis (token tercetak di pesan — pastikan chat bot hanya untuk admin). |

File yang diubah: 58 script bash + 2 script python, mencakup `install.sh`,
`update.sh`, `udepe.sh`, `config/limiter.sh`, seluruh isi `menu/` (menu.zip),
`bot/bot-vps-info` (bot.zip), `vermilion/` (vermilion.zip), `api-lite/`
(api-lite.zip), dan bot private (private.zip).

## 7. Daftar IP & Expired (file `ip` dan `ip-bot`)

Format baris: `### <nama> <tanggal-exp YYYY-MM-DD> <ip>` — `lifetime` sebagai
tanggal berarti tanpa batas. Pendaftaran tetap lewat menu `m-regis` /
script `lite*` (push otomatis pakai token), atau edit manual `ip` / `ip-bot`
lalu commit & push ke repo private.

## 8. Troubleshooting

| Gejala | Penyebab & solusi |
| --- | --- |
| `GH_TOKEN belum di-set!` | Token tidak ada di env & `/etc/gh-token.conf` tidak ada. `export GH_TOKEN=...` dulu. |
| `Repo tidak bisa diakses (HTTP 404)` | Token salah/kedaluwarsa, ATAU `GH_USER`/`GH_REPO`/`GH_BRANCH` tidak cocok, ATAU file tidak ada di branch `main`. |
| `Repo tidak bisa diakses (HTTP 403)` | Rate limit / akses ditolak. Tunggu atau cek izin token. |
| Registrasi IP gagal push | PAT tidak punya izin **Contents: Read and write** (classic: scope `repo`). |
| Menu normal tapi bot tidak bisa ambil data IP | Bot dijalankan systemd — pastikan `/etc/gh-token.conf` ada (dibuat saat install) atau tambahkan `Environment=GH_TOKEN=...` di unit service. |

## 9. Catatan Keamanan

- `/etc/gh-token.conf` permission `600` (root-only). Jangan di-commit ke repo!
  (File ini dibuat DI VPS, bukan bagian dari repo.)
- Token pada pesan instruksi bot: pesan install yang dikirim ke reseller
  memuat token agar copy-paste bisa jalan. Batasi akses chat bot.
- PAT fine-grained hanya pada 1 repo membatasi kerusakan bila token bocor.
- Revoke + buat token baru cukup dengan update `/etc/gh-token.conf` di setiap
  VPS (`GH_TOKEN=... export` ulang), tanpa perlu install ulang.

---

## LAMPIRAN — Panduan Rebuild OS (dari README asli)

```
echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p
```

### Rebuild via reinstall.sh (bin456789)

debian 10:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 10 && reboot
```
debian 11:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 11 && reboot
```
debian 12:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 12 && reboot
```
debian 13:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh debian 13 && reboot
```
ubuntu 20.04:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 20.04 && reboot
```
ubuntu 22.04:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 22.04 && reboot
```
ubuntu 24.04:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 24.04 && reboot
```
ubuntu 25.04:
```
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh && bash reinstall.sh ubuntu 25.04 && reboot
```
