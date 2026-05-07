# SisaSaku — UI Design Specification
**Platform:** Mobile (Android & iOS) | **Framework:** Flutter  
**Version:** 1.0 | **Tujuan Dokumen:** Panduan desain untuk Google Stitch

---

## 1. Brand Identity

| Atribut | Nilai |
|---|---|
| **App Name** | SisaSaku |
| **Tagline** | Catat Cepat, Tagihan Terpantau |
| **Tone** | Modern · Bersih · Terpercaya · Ramah |
| **Target User** | Mahasiswa & pekerja muda (18–35 tahun) |

---

## 2. Design System

### 2.1 Color Palette

| Token | Nama | Hex | Penggunaan |
|---|---|---|---|
| `--color-primary` | Teal | `#1D9E75` | Aksen utama, tombol, active state |
| `--color-primary-light` | Teal Light | `#E1F5EE` | Background icon, highlight |
| `--color-primary-dark` | Teal Dark | `#0F6E56` | Teks di atas teal light, hover |
| `--color-warning` | Amber | `#EF9F27` | Tagihan mendekati jatuh tempo |
| `--color-warning-light` | Amber Light | `#FAEEDA` | Background warning card |
| `--color-warning-dark` | Amber Dark | `#854F0B` | Teks warning |
| `--color-danger` | Red | `#E24B4A` | Overdue, pengeluaran |
| `--color-danger-light` | Red Light | `#FCEBEB` | Background danger card |
| `--color-danger-dark` | Red Dark | `#A32D2D` | Teks danger |
| `--color-success` | Green | `#3B6D11` | Pemasukan, lunas |
| `--color-success-light` | Green Light | `#EAF3DE` | Background success |
| `--color-bg-primary` | White | `#FFFFFF` | Card, modal background |
| `--color-bg-secondary` | Light Gray | `#F4F6F8` | Screen background |
| `--color-bg-tertiary` | Soft Gray | `#EAECEF` | Toggle, input field |
| `--color-text-primary` | Near Black | `#1A1D23` | Judul, angka utama |
| `--color-text-secondary` | Gray | `#6B7280` | Label, subtitle, placeholder |
| `--color-border` | Border | `#E5E7EB` | Garis pemisah, border card |

---

### 2.2 Typography

**Font Family:** `Plus Jakarta Sans` (Google Fonts)  
**Fallback:** `system-ui, -apple-system, sans-serif`

| Style | Size | Weight | Line Height | Penggunaan |
|---|---|---|---|---|
| Display | 28px | 800 | 1.1 | Angka saldo utama |
| H1 | 22px | 700 | 1.2 | Judul halaman |
| H2 | 16px | 700 | 1.3 | Section title |
| H3 | 14px | 600 | 1.4 | Card title |
| Body | 13px | 400 | 1.5 | Teks deskripsi |
| Caption | 11px | 400 | 1.4 | Label, metadata |
| Micro | 9px | 500 | 1.3 | Badge, chip, tag |

---

### 2.3 Spacing Scale

```
4px  · xs  — gap antar icon & teks
8px  · sm  — padding dalam badge/tag
12px · md  — padding dalam card kecil
16px · lg  — padding screen horizontal (gutter)
20px · xl  — jarak antar section
24px · 2xl — padding card besar
```

---

### 2.4 Border Radius

| Nama | Value | Digunakan pada |
|---|---|---|
| `radius-sm` | 8px | Badge, chip, button kecil |
| `radius-md` | 12px | Input field, icon container |
| `radius-lg` | 16px | Card standar |
| `radius-xl` | 20px | Modal bottom sheet, saldo card |
| `radius-full` | 9999px | Avatar, FAB, toggle pill |

---

### 2.5 Shadows

| Level | Value | Digunakan pada |
|---|---|---|
| `shadow-none` | none | Default card |
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.08)` | Card saat hover |
| `shadow-md` | `0 4px 16px rgba(0,0,0,0.10)` | FAB, modal sheet |
| `shadow-lg` | `0 8px 32px rgba(0,0,0,0.14)` | Bottom sheet saat muncul |

---

## 3. Background Treatment (Decorative Layer)

> **Penting:** Setiap layar memiliki background yang tidak polos. Gunakan elemen dekoratif berupa lingkaran-lingkaran transparan yang tersebar asimetris di belakang konten, dikombinasikan dengan soft gradient subtle.

### 3.1 Global Background Pattern

**Deskripsi Visual:**
- Background dasar: `#F4F6F8` (abu-abu sangat terang)
- Di atas background, tambahkan **3–5 lingkaran dekoratif** dengan ukuran berbeda-beda yang tersebar secara acak
- Lingkaran menggunakan warna teal dengan opacity sangat rendah (5–12%)
- Tidak ada hard edge — semua lingkaran blur/soft

**Spesifikasi Lingkaran Dekoratif:**

```
Lingkaran 1:
  - Ukuran: 240px × 240px
  - Posisi: top-right, setengah terpotong layar
  - Warna: #1D9E75 dengan opacity 8%
  - Blur: 40px (soft edge)

Lingkaran 2:
  - Ukuran: 160px × 160px
  - Posisi: top-left, setengah terpotong
  - Warna: #1D9E75 dengan opacity 6%
  - Blur: 30px

Lingkaran 3:
  - Ukuran: 320px × 320px
  - Posisi: bottom-center, 2/3 terpotong ke bawah
  - Warna: #EF9F27 dengan opacity 5%
  - Blur: 60px

Lingkaran 4 (kecil):
  - Ukuran: 80px × 80px
  - Posisi: middle-left, bebas
  - Warna: #1D9E75 dengan opacity 10%
  - Blur: 20px

Lingkaran 5 (kecil):
  - Ukuran: 60px × 60px
  - Posisi: bottom-right area
  - Warna: #EF9F27 dengan opacity 8%
  - Blur: 15px
```

**Contoh CSS Implementation:**
```css
.screen-background {
  background-color: #F4F6F8;
  position: relative;
  overflow: hidden;
}

.screen-background::before {
  content: '';
  position: absolute;
  width: 240px; height: 240px;
  top: -80px; right: -60px;
  border-radius: 50%;
  background: rgba(29, 158, 117, 0.08);
  filter: blur(40px);
  pointer-events: none;
}

.screen-background::after {
  content: '';
  position: absolute;
  width: 320px; height: 320px;
  bottom: -160px; left: 50%;
  transform: translateX(-50%);
  border-radius: 50%;
  background: rgba(239, 159, 39, 0.05);
  filter: blur(60px);
  pointer-events: none;
}
```

### 3.2 Variasi per Layar

| Layar | Lingkaran Dominan | Warna Aksen Bg |
|---|---|---|
| Beranda | Kanan atas (besar) + kiri tengah (kecil) | Teal |
| Catat Transaksi (Modal) | Samar, hampir tidak terlihat — fokus ke modal | Teal sangat transparan |
| Analitik | Kiri atas + kanan bawah | Teal + sedikit Amber |
| Tagihan | Kanan atas + kiri bawah | Amber (karena konteks warning) |
| Pengaturan | Tengah bawah saja | Teal netral |

---

## 4. Component Library

### 4.1 Saldo Card (Primary Hero Card)

```
┌─────────────────────────────────────┐
│  Saldo Bulan Ini          [+2.4% ↑] │
│                                     │
│  Rp 2.450.000                       │
│                                     │
│  Pemasukan │ Pengeluaran            │
│  Rp 3,5jt  │ Rp 1,05jt             │
└─────────────────────────────────────┘
```

**Spesifikasi:**
- Background: `#1D9E75` (solid teal)
- Border radius: 20px
- Padding: 20px 18px
- Teks "Saldo Bulan Ini": 11px, white, opacity 80%
- Angka saldo: 28px, weight 800, white
- Divider antar Pemasukan/Pengeluaran: garis vertikal 1px, white opacity 25%
- **Elemen dekoratif di dalam card:** 2 lingkaran besar, posisi kanan atas, putih opacity 8-12%, tidak blur (crisp circle)
- Contoh: lingkaran 90px di pojok kanan atas (−30px offset), lingkaran 50px sedikit ke kiri dari yang pertama

---

### 4.2 Center FAB — Catat Transaksi

> **Catatan:** FAB tidak lagi berdiri sendiri di bottom-right. FAB sekarang terintegrasi sebagai item tengah Bottom Navigation Bar dengan gaya *notched elevated button*.

```
        ╭──╮
        │ + │  ← 52px × 52px, menonjol di atas nav bar
        ╰──╯
       Catat
```

**Spesifikasi:**
- Size: 52px × 52px
- Background: `#1D9E75`
- Icon: Plus (+), putih, 24px
- Border radius: 50% (lingkaran penuh)
- Shadow: `0 4px 16px rgba(29,158,117,0.35)`
- Posisi: tengah bottom nav, melayang ke atas dengan notch kurva pada nav bar
- Label: "Catat", 9px, di bawah posisi FAB dalam nav bar

---

### 4.3 Status Tag / Badge

**Tipe dan Style:**

| Tipe | Background | Teks | Border |
|---|---|---|---|
| `income` (pemasukan) | `#EAF3DE` | `#3B6D11` | none |
| `expense` (pengeluaran) | `#FCEBEB` | `#A32D2D` | none |
| `warning` (mendekati) | `#FAEEDA` | `#854F0B` | none |
| `danger` (overdue) | `#FCEBEB` | `#A32D2D` | none |
| `success` (lunas) | `#E1F5EE` | `#0F6E56` | none |

**Dimensi:** padding 3px 8px, border-radius 20px, font-size 9px, font-weight 600

---

### 4.4 Bill Warning Card

```
┌╴━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┐  ← border-left 3px amber
│  🔔 Tagihan Terdekat           │
│     Kos Bulanan · H-2    Rp800rb│
└──────────────────────────────────┘
```

**Spesifikasi:**
- Background: `#FAEEDA`
- Border-left: 3px solid `#EF9F27`
- Border radius: 12px (kiri atas & kiri bawah = 0px karena ada border-left)
- Padding: 10px 12px

---

### 4.5 Transaction Row

```
╭──────╮  Nama Transaksi           +Rp 500rb
│ icon │  Waktu · Kategori
╰──────╯
```

**Spesifikasi:**
- Icon container: 32px × 32px, border-radius 10px
- Warna icon container: sesuai jenis (teal=income, red=expense, blue=transport, amber=bills)
- Angka positif: `#3B6D11`, diawali "+"
- Angka negatif: `#A32D2D`, diawali "−"
- Separator antar row: 1px `#E5E7EB`

---

### 4.6 Bottom Navigation Bar

```
┌───────────────────────────────────────────────────┐
│                      ╭──╮                         │
│                      │ + │  ← Catat (FAB tengah)  │
│  ╭──╮    ╭──╮   ╭────╯  ╰────╮   ╭──╮    ╭──╮   │
│  🏠       📊                    🧾        ⚙️      │
│ Beranda Analitik   [notch]   Tagihan Pengaturan   │
└───────────────────────────────────────────────────┘
```

> **Perubahan dari v1 awal:** FAB terpisah (posisi bottom-right) dihilangkan. Diganti dengan tombol Catat yang terintegrasi di tengah bottom nav dengan gaya *notched center FAB* — mengikuti pola seperti referensi desain.

**Spesifikasi:**
- Height: 64px (+ safe area padding untuk iPhone)
- Background: white `#FFFFFF`
- Border top: 0.5px `#E5E7EB`
- Icon size: 20px
- Label size: 9px
- **Active state:** icon + label berubah ke `#1D9E75`
- **Active indicator:** dot kecil 4px bulat di bawah icon, warna `#1D9E75`

**Center FAB (Catat):**
- Size: 52px × 52px
- Background: `#1D9E75`
- Icon: Plus (+), putih, 24px
- Border radius: 50% (lingkaran penuh)
- Shadow: `0 4px 16px rgba(29,158,117,0.35)`
- Posisi: melayang di atas tengah nav bar, sebagian menonjol ke atas
- Label: "Catat", 9px, ditampilkan di bawah area notch

**Notch (lekukan kurva di nav bar):**
- Shape: kurva Bezier halus (lebar ±108px, kedalaman ±24px)
- Warna notch mengikuti background layar (`#F4F6F8`)
- Border kurva: 0.5px `#E5E7EB` mengikuti kontur notch

**Urutan item (kiri → kanan):**

| Posisi | Label | Icon |
|---|---|---|
| 1 (kiri) | Beranda | `ti-home` |
| 2 | Analitik | `ti-chart-bar` |
| 3 (tengah) | Catat | `ti-plus` — FAB elevated |
| 4 | Tagihan | `ti-receipt` |
| 5 (kanan) | Pengaturan | `ti-settings` |

---

### 4.7 Bottom Sheet Modal (Quick Entry)

**Spesifikasi:**
- Background: white
- Border radius: 24px 24px 0 0 (hanya sudut atas)
- Handle bar: 36px × 4px, `#D1D5DB`, center top, margin-top 12px
- Shadow: `0 -8px 32px rgba(0,0,0,0.14)`
- Overlay di belakang: `rgba(0,0,0,0.45)` blur backdrop
- Animasi muncul: slide-up dari bawah, 300ms ease-out

---

### 4.8 Input Field

**Spesifikasi:**
- Height: 48px
- Border: 1px `#E5E7EB`
- Border radius: 12px
- Padding: 12px 14px
- Font: 13px
- **Focus state:** border berubah ke `#1D9E75`, background `#E1F5EE` sangat terang
- **Active/filled (nominal):** background `#E1F5EE`, border `#1D9E75`, font-size 20px, weight 800, warna `#0F6E56`

---

### 4.9 Toggle Segment (Pemasukan / Pengeluaran)

```
╭─────────────────────────────────────╮
│ ╭──────────────────╮                │  ← container: bg #EAECEF, radius 12px
│ │  ↓ Pemasukan     │  ↑ Pengeluaran │  ← active: white card
│ ╰──────────────────╯                │
╰─────────────────────────────────────╯
```

**Spesifikasi:**
- Container: `#EAECEF`, padding 3px, border-radius 12px
- Active tab: white background, border 0.5px `#E5E7EB`, border-radius 10px, shadow-sm
- Active teks: `#3B6D11` untuk Pemasukan, `#A32D2D` untuk Pengeluaran
- Inactive teks: `#6B7280`

---

### 4.10 Category Grid Item

```
╭──────╮
│      │  ← 44px × 44px, radius 12px
│  🍽️  │
╰──────╯
  Makan   ← 9px
```

**Spesifikasi:**
- Size: 44px × 44px
- Border radius: 12px
- Default: background `#F4F6F8`, icon color `#6B7280`
- **Selected:** background sesuai warna kategori (teal/amber/etc), border 2px warna dark variant, icon color dark variant
- Label: 9px, center, truncate jika panjang

---

### 4.11 Progress Bar (Kategori Breakdown)

```
Kos / Sewa                 Rp 500rb  48%
━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░░░
```

**Spesifikasi:**
- Track height: 5px, border-radius 3px, background `#EAECEF`
- Fill height: 5px, border-radius 3px, warna sesuai kategori
- Label baris atas: font 10px, kiri=nama kategori, kanan=nominal + persentase
- Jarak antara label & bar: 5px

---

## 5. Screen Specifications

### Screen 1: Beranda (Dashboard)

**Layout Struktur (atas ke bawah):**

```
[Status Bar: 9:41 ·  · ]
─────────────────────────────
[Header]
  · Kiri: "Selamat pagi," (caption) + "Andi Pratama 👋" (H2)
  · Kanan: Bell icon dalam lingkaran teal light 32px
─────────────────────────────
[Saldo Card] — full width - 32px gutter
  · Rp 2.450.000 (Display)
  · Pemasukan | Pengeluaran (Caption + Body)
  · Lingkaran dekoratif putih di kanan atas
─────────────────────────────
[Bill Warning Card]
  · Border kiri amber
  · "Tagihan Terdekat · Kos Bulanan · H-2 · Rp 800rb"
─────────────────────────────
[Scroll Area]
  ├── Section: "Aksi Cepat"
  │     Grid 4 kolom: Catat, Tagihan, Analitik, Kategori
  │     Setiap item: icon container 40px + label 9px
  │
  └── Section: "Transaksi Terbaru"
        Card dengan 3 transaction rows
        Lihat Semua → (link teal kanan)
─────────────────────────────
[Bottom Nav] — Beranda aktif (FAB Catat terintegrasi di tengah nav)
```

**Background:** Lingkaran teal besar (240px) di kanan atas, lingkaran kecil (80px) di kiri tengah

---

### Screen 2: Catat Transaksi (Bottom Sheet Modal)

**Layout Struktur:**

```
[Overlay Background: rgba(0,0,0,0.45)]
  ↓ (konten dashboard terlihat samar di balik overlay)
─────────────────────────────
[Bottom Sheet — muncul dari bawah]
  ┌── Handle Bar (center) ──┐
  │
  │ Judul: "Catat Transaksi" (H2)
  │
  │ [Toggle: Pemasukan ↔ Pengeluaran]
  │
  │ [Input Nominal]
  │    Label: "Nominal"
  │    Placeholder: "Rp 0"
  │    Saat diisi: teal bg + teks besar 20px
  │
  │ [Input Keterangan]
  │    Label: "Keterangan (opsional)"
  │    Placeholder: "Tambah catatan..."
  │
  │ [Kategori Grid — 4 kolom, 2 baris]
  │    Freelance | Makan | Kos | Transport
  │    Kuliah    | Hiburan | Lainnya | + Baru
  │
  │ [Tombol "Simpan Transaksi"]
  │    Full width, background #1D9E75, white text
  └──────────────────────────┘
```

**Catatan Interaksi:**
- Saat nominal diketik, angka berubah besar (20px bold teal)
- Kategori yang dipilih: border highlight + background teal light
- Tombol Simpan: disabled state = opacity 40%, warna abu

---

### Screen 3: Analitik

**Layout Struktur (atas ke bawah):**

```
[Status Bar]
─────────────────────────────
[Header]
  · Kiri: "Analitik" (H1)
  · Kanan: Download icon (untuk ekspor)
─────────────────────────────
[Period Selector — Segment]
  Minggu | Bulan (aktif) | Tahun
─────────────────────────────
[Scroll Area]
  ├── [Summary Cards — 2 kolom]
  │     Kiri: Pemasukan (teal, +12%)
  │     Kanan: Pengeluaran (red, -5%)
  │
  ├── [Bar Chart Card]
  │     Judul: "Pengeluaran Harian"
  │     Bar chart 7 hari (Sen–Min)
  │     Bar teal solid = nilai tinggi
  │     Bar teal light = nilai rendah
  │     Highlight bar tertinggi dengan warna solid lebih terang
  │
  └── [Breakdown Card]
        Judul: "Rincian Kategori"
        Tiap row: dot warna + nama + nominal + % + progress bar
        Contoh:
        ● Kos/Sewa      Rp 500rb  48%  ████████░░░░
        ● Makan         Rp 280rb  27%  █████░░░░░░░
        ● Transport     Rp 120rb  11%  ██░░░░░░░░░░
        ● Lainnya       Rp 150rb  14%  ███░░░░░░░░░
─────────────────────────────
[Bottom Nav] — Analitik aktif
```

**Background:** Lingkaran teal (180px) kiri atas + lingkaran amber (200px) kanan bawah

---

### Screen 4: Tagihan (Bills)

**Layout Struktur (atas ke bawah):**

```
[Status Bar]
─────────────────────────────
[Header]
  · Kiri: "Tagihan" (H1)
  · Kanan: Tombol "+ Tambah" (teal, border-radius 8px)
─────────────────────────────
[Summary Chips — horizontal row]
  [🚨 1 Overdue]  [⏰ 2 Mendekati]  [✅ 1 Lunas]
─────────────────────────────
[Scroll Area]
  ├── [Section Header: "Jatuh Tempo Terlewat" — merah]
  │     Bill Card (border-left merah):
  │     · Icon: WiFi dalam lingkaran merah light
  │     · Nama: Langganan Internet
  │     · Tanggal: "3 Mei · Overdue 4 hari" (badge merah)
  │     · Nominal: Rp 249.000
  │
  ├── [Section Header: "Mendekati Jatuh Tempo" — amber]
  │     Bill Card (border-left amber):
  │     · Kos Bulanan — 10 Mei · H-2 — Rp 800.000
  │
  │     Bill Card (border-left amber):
  │     · Paket Data Telkomsel — 12 Mei · H-4 — Rp 99.000
  │
  └── [Section Header: "Sudah Lunas" — teal]
        Bill Card (opacity 55%, teks strikethrough):
        · Listrik PLN — Lunas 1 Mei — Rp 150.000
─────────────────────────────
[Bottom Nav] — Tagihan aktif
```

**Background:** Lingkaran amber (200px) kanan atas + lingkaran teal (160px) kiri bawah

---

### Screen 5: Pengaturan (Settings)

**Layout Struktur (atas ke bawah):**

```
[Status Bar]
─────────────────────────────
[Scroll Area]
  ├── [Profile Section — center align]
  │     Avatar: lingkaran 64px, border teal 2px
  │       Isi: inisial "AP" atau foto profil
  │     Nama: "Andi Pratama" (H2)
  │     Status: "Mode: Tamu (belum login)" (caption gray)
  │     Tombol: "☁ Login & Backup Cloud" (teal, pill shape)
  │
  ├── [Cloud Backup Warning Card]
  │     Background amber light, border amber
  │     Icon: cloud-off (24px, amber)
  │     Judul: "Backup belum aktif"
  │     Sub: "Login untuk aktifkan sinkronisasi Cloud"
  │
  ├── [Section: "Preferensi"]
  │     Menu Card (grouped):
  │     ┌─ Kelola Kategori            › ─┐
  │     ├─ Pengaturan Notifikasi      › ─┤
  │     └─ Tema Tampilan     Terang   › ─┘
  │     Setiap item: icon container 30px + label + chevron
  │
  └── [Section: "Data & Ekspor"]
        Menu Card (grouped):
        ┌─ Ekspor ke CSV  (riwayat lengkap)  ↓ ─┐
        └─ Ekspor ke PDF  (laporan bulanan)  ↓ ─┘

        App Branding (center):
        "SisaSaku" — teal, 16px bold
        "v1.0.0 · Offline-First · Flutter" — caption gray
─────────────────────────────
[Bottom Nav] — Pengaturan aktif
```

**Background:** Lingkaran teal besar (280px) tengah bawah, sangat transparan (5%)

---

## 6. Status Bar

**Komponen selalu muncul di semua layar:**
```
9:41                    [WiFi] [Battery]
```
- Height: 44px (iOS) / 24px (Android)
- Background: transparent (mengikuti layar)
- Teks: warna default sesuai mode (hitam di light mode)

---

## 7. Navigation & Transitions

| Navigasi | Animasi |
|---|---|
| Tap bottom nav | Crossfade halus, 200ms |
| Buka Quick Entry (FAB) | Bottom sheet slide-up, 300ms ease-out |
| Tutup Quick Entry | Slide-down, 250ms ease-in |
| Navigasi ke detail | Slide from right, 250ms |
| Kembali ke sebelumnya | Slide to right, 200ms |

---

## 8. Dark Mode Variant

> Siapkan varian Dark Mode dengan token warna berikut:

| Token | Light Mode | Dark Mode |
|---|---|---|
| `--color-bg-primary` | `#FFFFFF` | `#1A1D23` |
| `--color-bg-secondary` | `#F4F6F8` | `#22262E` |
| `--color-bg-tertiary` | `#EAECEF` | `#2C313C` |
| `--color-text-primary` | `#1A1D23` | `#F8FAFC` |
| `--color-text-secondary` | `#6B7280` | `#9CA3AF` |
| `--color-border` | `#E5E7EB` | `#374151` |
| `--color-primary` | `#1D9E75` | `#2EBD8E` |
| `--color-primary-light` | `#E1F5EE` | `rgba(29,158,117,0.15)` |

**Background Dark Mode:**
- Sama seperti light mode tetapi lingkaran dekoratif menggunakan opacity sedikit lebih tinggi (10–15%) karena latar sudah gelap
- Warna lingkaran: gunakan `#2EBD8E` (teal lebih terang) agar terlihat di dark bg

---

## 9. Empty States

### Tidak ada transaksi
```
     ╭──────────────╮
     │   📋 kosong  │
     ╰──────────────╯
  Belum ada transaksi
  Tap tombol + untuk mulai mencatat
  [Catat Sekarang] ← tombol teal
```

### Tidak ada tagihan
```
     ╭──────────────╮
     │   🔔 aman    │
     ╰──────────────╯
  Tidak ada tagihan aktif
  Semua tagihan sudah terkelola!
```

---

## 10. Accessibility Notes

- Semua tombol interaktif minimum 44×44px touch target
- Kontras warna minimum 4.5:1 (WCAG AA)
- Teks pada background teal card harus putih (rasio kontras ≥ 7:1)
- Icon penting harus disertai label teks
- Focus ring: 2px solid `#1D9E75` dengan offset 2px

---

## 11. Asset Checklist untuk Google Stitch

Berikut daftar elemen yang perlu di-generate per layar:

- [ ] Layar 1 — Beranda (light mode)
- [ ] Layar 1 — Beranda (dark mode)
- [ ] Layar 2 — Quick Entry Modal
- [ ] Layar 3 — Analitik (dengan chart)
- [ ] Layar 4 — Tagihan (dengan semua status)
- [ ] Layar 5 — Pengaturan
- [ ] Component Sheet — semua komponen terisolasi
- [ ] Color Palette Board
- [ ] Typography Scale

---

*Dokumen ini adalah spesifikasi desain SisaSaku v1.0 — dibuat untuk digunakan bersama Google Stitch.*
