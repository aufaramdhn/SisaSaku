# 📱 Product Requirements Document (PRD)

## SisaSaku — Aplikasi Pencatatan Keuangan & Pengingat Tagihan

> **Versi:** 1.0.0  
> **Status:** Draft  
> **Terakhir diperbarui:** Mei 2025  
> **Platform:** Mobile (Android & iOS)  
> **Framework:** Flutter (Dart)

---

## 1. Ringkasan Produk (Product Overview)

**SisaSaku** adalah aplikasi asisten finansial pribadi berbasis mobile yang dirancang dengan prinsip **minimalis, intuitif, dan offline-first**. Aplikasi ini membantu pengguna memantau arus kas harian (pemasukan & pengeluaran) sekaligus memastikan tidak ada tagihan yang terlewat lewat sistem notifikasi lokal — tanpa memerlukan koneksi internet.

### Target Pengguna

- Mahasiswa yang mengelola uang bulanan / uang saku
- Pekerja lepas (freelancer) yang mengelola arus kas mandiri
- Siapa pun yang ingin mencatat keuangan secara cepat dan sederhana

### Proposisi Nilai Utama

| Masalah Pengguna                  | Solusi SisaSaku                                |
| --------------------------------- | ---------------------------------------------- |
| Lupa bayar tagihan → kena denda   | Sistem notifikasi lokal yang andal             |
| Pencatatan keuangan terasa ribet  | Quick Entry 1 tap, maksimal 2 detik siap input |
| Takut kehilangan data             | Backup opsional ke Cloud (Supabase)            |
| Tidak selalu ada koneksi internet | Semua fitur inti berjalan 100% offline         |

---

## 2. Tujuan & Sasaran (Goals & Objectives)

### Tujuan Utama

Membangun asisten finansial pribadi berbasis mobile yang fokus pada:

1. **Kecepatan pencatatan** arus kas (pemasukan & pengeluaran)
2. **Keandalan pengingat tagihan** secara offline
3. **Pencegahan kebocoran finansial** dan denda keterlambatan pembayaran

### Metrik Keberhasilan (Success Metrics)

| Metrik                               | Target              |
| ------------------------------------ | ------------------- |
| Waktu buka app → siap input nominal  | ≤ 2 detik           |
| Notifikasi lokal terpicu tepat waktu | 100% reliabilitas   |
| Fungsi CRUD offline                  | 100% tanpa internet |
| Tingkat crash saat pencatatan        | 0%                  |

---

## 3. Kebutuhan Fungsional (Functional Requirements)

### 3.1 Pencatatan Kilat (Quick Entry)

- Pengguna dapat membuka formulir input **hanya dalam 1 ketukan** via Floating Action Button (FAB)
- Form input mencakup:
  - **Nominal** uang (wajib)
  - **Deskripsi / keterangan** singkat (opsional)
  - **Jenis transaksi**: Pemasukan (In) / Pengeluaran (Out)
  - **Kategori** transaksi (pilih dari daftar atau buat baru)
- Setelah disimpan, saldo di Dashboard langsung diperbarui secara real-time

### 3.2 Manajemen Kategori

- Pengguna dapat **menambah** kategori baru (nama + ikon/warna)
- Pengguna dapat **mengedit** kategori yang sudah ada
- Pengguna dapat **menghapus** kategori yang tidak digunakan
- Contoh kategori default: Makan, Kos, Transportasi, Freelance, Tagihan

### 3.3 Pengingat Tagihan (Bill Reminder)

- Pengguna dapat menjadwalkan alarm/notifikasi untuk tanggal jatuh tempo tagihan
- Data tagihan mencakup:
  - **Nama tagihan** (contoh: Langganan Internet, Kos Bulanan)
  - **Tanggal jatuh tempo**
  - **Waktu pengingat** (contoh: H-1, Hari H jam 08:00)
  - **Nominal** (opsional)
- Notifikasi harus tetap berjalan **meskipun aplikasi ditutup (killed)**
- Tap pada notifikasi → langsung membuka halaman detail tagihan terkait

### 3.4 Dashboard Ringkasan

- Menampilkan **saldo berjalan** dalam angka besar di bagian atas layar
- Menampilkan **grafik / rasio** perbandingan pemasukan vs pengeluaran bulan berjalan
- Menampilkan **daftar tagihan terdekat** (yang akan jatuh tempo dalam waktu dekat)
- Menampilkan **riwayat transaksi terbaru**

### 3.5 Login Opsional & Cloud Backup

- Pengguna **tidak diwajibkan** login untuk menggunakan semua fitur utama (mode Guest)
- Login tersedia via **Supabase Auth** (Google / Email)
- Setelah login berhasil, sistem otomatis memicu **sinkronisasi dua arah**:
  - Upload: data lokal dengan `sync_status = FALSE` → Supabase
  - Download: data terbaru dari Supabase (jika ada data dari perangkat lain)
- Login tersimpan untuk sinkronisasi berkala di latar belakang

---

## 4. Kebutuhan Non-Fungsional (Non-Functional Requirements)

| Aspek            | Ketentuan                                                                                                         |
| ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Availability** | Offline-first. Semua fitur inti (CRUD & notifikasi) berjalan 100% tanpa internet. Cloud backup bersifat opsional. |
| **Performance**  | Waktu dari buka app hingga siap input nominal: **≤ 2 detik**                                                      |
| **Reliability**  | Notifikasi lokal harus terpicu tepat waktu meskipun app di-killed                                                 |
| **Scalability**  | Data lokal mampu menampung ribuan transaksi tanpa degradasi performa                                              |
| **Security**     | Data keuangan tersimpan secara lokal; akses Cloud hanya dengan persetujuan dan autentikasi pengguna               |
| **Usability**    | Antarmuka minimalis; pengguna baru dapat mencatat transaksi pertama dalam < 30 detik tanpa tutorial               |

---

## 5. Arsitektur Sistem (System Architecture)

### 5.1 Arsitektur Penyimpanan Data

```
┌─────────────────────────────────────────────────────────┐
│                    PERANGKAT PENGGUNA                   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Isar Local Database                  │  │
│  │                                                   │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  │  │
│  │  │  Transaksi  │  │  Kategori   │  │ Tagihan  │  │  │
│  │  │             │  │             │  │          │  │  │
│  │  │ - id        │  │ - id        │  │ - id     │  │  │
│  │  │ - nominal   │  │ - nama      │  │ - nama   │  │  │
│  │  │ - jenis     │  │ - ikon      │  │ - nominal│  │  │
│  │  │ - tanggal   │  │ - warna     │  │ - jatuh  │  │  │
│  │  │ - id_kat    │  └─────────────┘  │   tempo  │  │  │
│  │  │ - deskripsi │                   │ - status │  │  │
│  │  │ - sync_stat │                   │ - sync_  │  │  │
│  │  └─────────────┘                   │   status │  │  │
│  │                                    └──────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
│                          ↕ (opsional, jika online)      │
└─────────────────────────────────────────────────────────┘
                           ↕
┌─────────────────────────────────────────────────────────┐
│                   SUPABASE (Cloud)                      │
│       PostgreSQL DB │ Auth │ File Storage               │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Skema Tabel Database Lokal

#### Tabel `transaksi`

| Kolom         | Tipe          | Keterangan                    |
| ------------- | ------------- | ----------------------------- |
| `id`          | String (UUID) | Primary key                   |
| `nominal`     | Double        | Jumlah uang                   |
| `jenis`       | Enum (in/out) | Pemasukan atau pengeluaran    |
| `tanggal`     | DateTime      | Tanggal transaksi             |
| `id_kategori` | String (FK)   | Relasi ke tabel kategori      |
| `deskripsi`   | String?       | Keterangan opsional           |
| `sync_status` | Boolean       | FALSE = belum tersinkronisasi |

#### Tabel `kategori`

| Kolom   | Tipe          | Keterangan                            |
| ------- | ------------- | ------------------------------------- |
| `id`    | String (UUID) | Primary key                           |
| `nama`  | String        | Nama kategori                         |
| `ikon`  | String        | Kode ikon (misal: material icon name) |
| `warna` | String        | Kode warna hex                        |

#### Tabel `tagihan`

| Kolom                 | Tipe          | Keterangan                    |
| --------------------- | ------------- | ----------------------------- |
| `id`                  | String (UUID) | Primary key                   |
| `nama`                | String        | Nama tagihan                  |
| `nominal`             | Double?       | Nominal opsional              |
| `tanggal_jatuh_tempo` | DateTime      | Tanggal deadline              |
| `waktu_pengingat`     | DateTime      | Kapan notifikasi dipicu       |
| `sync_status`         | Boolean       | FALSE = belum tersinkronisasi |

---

## 6. Alur Interaksi Pengguna (User Flow)

### 6.1 Alur Pencatatan Kilat (Quick Entry)

```
[Dashboard]
    → Tap FAB (+)
    → [Pop-up / Form Quick Entry]
        → Input: Nominal, Deskripsi, Jenis (In/Out), Kategori
    → Tap "Simpan"
    → [Dashboard] ← saldo otomatis diperbarui
```

### 6.2 Alur Penjadwalan Pengingat Tagihan

```
[Navigasi Utama]
    → Pilih menu "Tagihan"
    → Tap "Tambah Tagihan"
    → [Form Tagihan]
        → Input: Nama, Tanggal Jatuh Tempo, Waktu Pengingat
    → Tap "Set Pengingat"
    → [Daftar Tagihan] ← tagihan baru muncul
    → [Background: OS mendaftarkan alarm lokal]
    → [Pada waktu yang ditentukan: Notifikasi muncul di lock screen]
    → Tap notifikasi → [Detail Tagihan]
```

### 6.3 Alur Login Opsional & Sinkronisasi

```
[Mode Guest] → Semua fitur inti tersedia, data hanya di lokal
    ↓ (jika pengguna ingin backup)
[Pengaturan] → Tap "Login / Backup"
    → [Form Login: Google / Email via Supabase Auth]
    → Login berhasil
    → [Proses Sinkronisasi Otomatis]
        → Upload: data lokal (sync_status=FALSE) → Supabase
        → Download: data terbaru dari Supabase
    → [Selesai: Data lokal & Cloud selaras]
```

---

## 7. Alur Logika Sistem (System Processing Flow)

### 7.1 Kalkulasi Saldo Dashboard

```
TRIGGER: App dibuka / transaksi baru disimpan
    ↓
Query Isar DB → ambil semua transaksi bulan berjalan
    ↓
Pisahkan array: [Pemasukan] dan [Pengeluaran]
    ↓
Total_In  = SUM(nominal Pemasukan)
Total_Out = SUM(nominal Pengeluaran)
Saldo     = Total_In - Total_Out
    ↓
Render UI → perbarui angka saldo + grafik perbandingan
```

### 7.2 Eksekusi Notifikasi (Background)

```
Pengguna tap "Set Pengingat"
    ↓
Simpan data tagihan ke Isar DB
    ↓
Daftarkan alarm ke OS:
  Android → AlarmManager
  iOS     → UNUserNotificationCenter
    ↓
App ditutup / berjalan di background
    ↓
[Pada waktu yang terdaftar]
OS memicu → Local Push Notification
  Teks: "Jangan lupa bayar: [Nama Tagihan]!"
    ↓
Pengguna tap notifikasi → SisaSaku terbuka → Halaman Detail Tagihan
```

---

## 8. Desain Antarmuka (UI/UX Design)

### 8.1 Prinsip Desain

- **Minimalis**: Tidak ada elemen dekoratif yang tidak perlu
- **One-handed friendly**: Aksi utama (FAB) dapat dijangkau dengan ibu jari
- **Data-first**: Angka saldo tampil besar dan jelas sebagai fokus utama

### 8.2 Struktur Halaman

| Halaman                        | Komponen Utama                                                          |
| ------------------------------ | ----------------------------------------------------------------------- |
| **Dashboard (Beranda)**        | Saldo besar, grafik In/Out, kartu tagihan terdekat, riwayat transaksi   |
| **Quick Entry (Pop-up/Modal)** | Input nominal, deskripsi, toggle In/Out, picker kategori, tombol Simpan |
| **Daftar Tagihan**             | List tagihan + status, tombol Tambah, swipe to delete                   |
| **Manajemen Kategori**         | List kategori dengan ikon & warna, CRUD inline                          |
| **Pengaturan**                 | Tombol Login/Logout, info sinkronisasi terakhir                         |

### 8.3 Komponen UI Kunci

- **FAB (Floating Action Button)**: Ikon `+`, selalu terlihat di layar utama, memicu Quick Entry
- **Saldo Card**: Angka besar (typography 36–48sp), dengan label "Saldo Bulan Ini"
- **Bill Warning Card**: Kartu berwarna kuning/merah untuk tagihan yang H-3 atau lebih dekat
- **Grafik Donut/Bar**: Visualisasi rasio pemasukan vs pengeluaran bulan berjalan

---

## 9. Tech Stack

| Layer                | Teknologi                     | Alasan Pemilihan                                                                     |
| -------------------- | ----------------------------- | ------------------------------------------------------------------------------------ |
| **Mobile Framework** | Flutter (Dart)                | Cross-platform (Android & iOS), performa tinggi, hot reload, ekosistem offline-first |
| **Local Database**   | Isar Database                 | Lebih cepat dari SQLite, API Dart-native, NoSQL-like schema dengan kemudahan CRUD    |
| **Notifikasi Lokal** | `flutter_local_notifications` | Dukungan AlarmManager (Android) & UNUserNotification (iOS)                           |
| **Cloud Backend**    | Supabase                      | PostgreSQL + Auth + Storage, gratis tier yang generous, mudah diintegrasikan         |
| **State Management** | Riverpod / Bloc               | Reactive state untuk update saldo real-time                                          |
| **Autentikasi**      | Supabase Auth                 | Email & OAuth (Google), JWT token management otomatis                                |

---

## 10. Rencana Implementasi (Implementation Phases)

| Tahap                    | Fokus              | Output                                                              |
| ------------------------ | ------------------ | ------------------------------------------------------------------- |
| **Tahap 1**              | Infrastruktur Data | Skema Isar DB, fungsi CRUD Transaksi, Kategori, Tagihan             |
| **Tahap 2**              | Antarmuka Utama    | Dashboard statis, kerangka Quick Entry (UI saja)                    |
| **Tahap 3**              | Integrasi Logika   | UI terhubung ke DB, kalkulasi saldo dinamis, grafik berjalan        |
| **Tahap 4**              | Sistem Notifikasi  | Modul penjadwalan alarm lokal, routing notifikasi ke halaman detail |
| **Tahap 5** _(opsional)_ | Cloud Sync         | Supabase Auth, mekanisme sinkronisasi dua arah                      |

---

## 11. Rencana Pengujian (Testing Plan)

### 11.1 Black-Box Testing

| Skenario                | Input                       | Expected Output                   |
| ----------------------- | --------------------------- | --------------------------------- |
| Quick Entry Pemasukan   | Nominal: 500.000, Jenis: In | Saldo bertambah 500.000           |
| Quick Entry Pengeluaran | Nominal: 50.000, Jenis: Out | Saldo berkurang 50.000            |
| Tambah Kategori Baru    | Nama: "Belanja", Ikon: 🛒   | Kategori muncul di daftar pilihan |
| Hapus Kategori          | Swipe + konfirmasi          | Kategori hilang dari daftar       |

### 11.2 Notification Testing

| Skenario               | Langkah                            | Expected Output                         |
| ---------------------- | ---------------------------------- | --------------------------------------- |
| Notifikasi tepat waktu | Set tagihan H+1 menit, tutup app   | Notifikasi muncul dalam 1 menit         |
| Routing notifikasi     | Tap notifikasi                     | App terbuka, langsung ke detail tagihan |
| App killed             | Force-stop app, tunggu waktu alarm | Notifikasi tetap muncul                 |

### 11.3 Offline / Environment Testing

| Skenario            | Kondisi                 | Expected Output               |
| ------------------- | ----------------------- | ----------------------------- |
| CRUD tanpa internet | WiFi & data seluler OFF | Semua operasi berjalan normal |
| Dashboard offline   | WiFi & data seluler OFF | Saldo & grafik tetap akurat   |
| Notifikasi offline  | WiFi & data seluler OFF | Notifikasi tetap terpicu      |

---

## 12. Rilis & Pemeliharaan (Deployment & Maintenance)

### 12.1 Rilis Awal

- **Android**: Generate file APK (debug) atau AAB (production via Play Store)
- **iOS**: Generate file IPA melalui Xcode / Fastlane

### 12.2 Roadmap Fitur Masa Depan (v2.0+)

| Fitur                     | Prioritas | Keterangan                                              |
| ------------------------- | --------- | ------------------------------------------------------- |
| Export laporan CSV/PDF    | Tinggi    | Pengguna dapat mengekspor riwayat transaksi             |
| Anggaran bulanan (Budget) | Sedang    | Set batas pengeluaran per kategori                      |
| Widget layar beranda      | Sedang    | Lihat saldo langsung dari home screen HP                |
| Multi-currency            | Rendah    | Dukungan mata uang selain IDR                           |
| Recurring transaction     | Sedang    | Otomatis catat transaksi berulang (misal: gaji bulanan) |

---

## 13. Risiko & Mitigasi

| Risiko                                                                        | Dampak | Mitigasi                                                                |
| ----------------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------- |
| Notifikasi tidak muncul di beberapa HP Android (battery optimization agresif) | Tinggi | Panduan in-app untuk minta pengguna whitelist app di pengaturan baterai |
| Data lokal hilang jika HP direset                                             | Tinggi | Promosi fitur Cloud Backup sejak onboarding                             |
| Isar DB tidak stabil di platform tertentu                                     | Sedang | Siapkan fallback ke SQLite (via `sqflite`)                              |
| Konflik data saat sinkronisasi dua perangkat                                  | Sedang | Implementasi conflict resolution: last-write-wins berbasis timestamp    |

---

_Dokumen ini merupakan living document yang akan diperbarui seiring perkembangan proyek._

---

## 14. Struktur Folder Proyek (Clean Architecture)

Proyek SisaSaku mengikuti prinsip **Clean Architecture** — memisahkan kepentingan antara lapisan data, domain, dan presentasi. Setiap fitur berdiri mandiri di dalam foldernya sendiri agar mudah dikembangkan, diuji, dan dipelihara secara independen.

### 14.1 Gambaran Umum Struktur

```
sisasaku/
├── android/
├── ios/
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
├── lib/
│   ├── core/
│   ├── features/
│   ├── shared/
│   ├── routes/
│   └── main.dart
├── test/
└── pubspec.yaml
```

---

### 14.2 Struktur Detail `lib/`

```
lib/
│
├── core/                          # Utilitas & infrastruktur global
│   ├── constants/
│   │   ├── app_colors.dart        # Token warna dari design system
│   │   ├── app_typography.dart    # TextStyle & font scale
│   │   ├── app_spacing.dart       # Konstanta spacing (4, 8, 12, 16, ...)
│   │   └── app_strings.dart       # String statis & label UI
│   │
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exception classes
│   │   └── failures.dart          # Failure sealed class (untuk Either)
│   │
│   ├── services/
│   │   ├── notification_service.dart   # Wrapper flutter_local_notifications
│   │   ├── sync_service.dart           # Logika sinkronisasi lokal <-> Supabase
│   │   └── storage_service.dart        # SharedPreferences / secure storage
│   │
│   ├── theme/
│   │   ├── app_theme.dart         # ThemeData light & dark
│   │   └── app_text_theme.dart    # TextTheme dari Plus Jakarta Sans
│   │
│   └── utils/
│       ├── currency_formatter.dart     # Format Rp 1.500.000
│       ├── date_formatter.dart         # Format tanggal lokal (id_ID)
│       └── validators.dart             # Validasi input form
│
├── features/                      # Fitur-fitur utama (feature-first)
│   │
│   ├── dashboard/                 # Layar Beranda
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── dashboard_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── dashboard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── summary_entity.dart       # Saldo, total in, total out
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart  # Abstract class
│   │   │   └── usecases/
│   │   │       ├── get_monthly_summary.dart
│   │   │       └── get_recent_transactions.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── dashboard_page.dart
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart    # Riverpod provider
│   │       └── widgets/
│   │           ├── saldo_card.dart
│   │           ├── bill_warning_card.dart
│   │           └── quick_action_grid.dart
│   │
│   ├── transaction/               # Pencatatan Kilat (Quick Entry)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transaction_local_datasource.dart   # Isar DB
│   │   │   │   └── transaction_remote_datasource.dart  # Supabase
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart    # @collection Isar + toJson
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_transaction.dart
│   │   │       ├── delete_transaction.dart
│   │   │       ├── get_transactions_by_month.dart
│   │   │       └── update_transaction.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── transaction_list_page.dart
│   │       ├── providers/
│   │       │   └── transaction_provider.dart
│   │       └── widgets/
│   │           ├── quick_entry_sheet.dart     # Bottom sheet modal
│   │           ├── transaction_row.dart
│   │           └── type_toggle.dart           # Pemasukan <-> Pengeluaran
│   │
│   ├── bill/                      # Tagihan & Pengingat
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── bill_local_datasource.dart
│   │   │   │   └── bill_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── bill_model.dart
│   │   │   └── repositories/
│   │   │       └── bill_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── bill_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── bill_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_bill.dart
│   │   │       ├── delete_bill.dart
│   │   │       ├── get_bills.dart
│   │   │       ├── mark_bill_as_paid.dart
│   │   │       └── schedule_bill_notification.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── bill_list_page.dart
│   │       │   └── bill_detail_page.dart
│   │       ├── providers/
│   │       │   └── bill_provider.dart
│   │       └── widgets/
│   │           ├── bill_card.dart             # Card dengan border-left status
│   │           ├── bill_status_chip.dart      # Overdue / Mendekati / Lunas
│   │           └── add_bill_sheet.dart
│   │
│   ├── analytics/                 # Layar Analitik
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── analytics_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── analytics_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── daily_expense_entity.dart
│   │   │   │   └── category_breakdown_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── analytics_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_daily_expenses.dart
│   │   │       └── get_category_breakdown.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── analytics_page.dart
│   │       ├── providers/
│   │       │   └── analytics_provider.dart
│   │       └── widgets/
│   │           ├── bar_chart_card.dart
│   │           ├── category_breakdown_card.dart
│   │           └── period_selector.dart       # Minggu / Bulan / Tahun
│   │
│   ├── category/                  # Manajemen Kategori
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── category_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── category_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── category_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_category.dart
│   │   │       ├── delete_category.dart
│   │   │       └── get_categories.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── category_manage_page.dart
│   │       ├── providers/
│   │       │   └── category_provider.dart
│   │       └── widgets/
│   │           ├── category_grid_item.dart
│   │           └── category_form_sheet.dart
│   │
│   ├── auth/                      # Login Opsional & Cloud Backup
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart   # Supabase Auth
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_with_google.dart
│   │   │       ├── login_with_email.dart
│   │   │       ├── logout.dart
│   │   │       └── get_current_user.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   └── settings/                  # Layar Pengaturan
│       ├── domain/
│       │   └── usecases/
│       │       ├── export_to_csv.dart
│       │       └── export_to_pdf.dart
│       └── presentation/
│           ├── pages/
│           │   └── settings_page.dart
│           ├── providers/
│           │   └── settings_provider.dart
│           └── widgets/
│               ├── cloud_backup_card.dart
│               └── menu_item_tile.dart
│
├── shared/                        # Komponen reusable lintas fitur
│   ├── widgets/
│   │   ├── app_scaffold.dart          # Scaffold wrapper + bottom nav
│   │   ├── bottom_nav_bar.dart        # Notched bottom nav (5 item)
│   │   ├── status_badge.dart          # Badge: income/expense/warning/danger/success
│   │   ├── section_header.dart        # Judul section + aksi kanan
│   │   ├── empty_state.dart           # Empty state illustration + CTA
│   │   └── loading_indicator.dart     # Circular progress teal
│   └── extensions/
│       ├── datetime_extension.dart    # .toFormattedString(), .daysUntil()
│       ├── double_extension.dart      # .toRupiah()
│       └── string_extension.dart     # .capitalize(), .isNullOrEmpty
│
└── routes/                        # Navigasi & routing
    ├── app_router.dart            # GoRouter / auto_route config
    └── app_routes.dart            # Konstanta nama rute
```

---

### 14.3 Penjelasan Per Layer

| Layer            | Lokasi                     | Isi                                         | Dependensi                                        |
| ---------------- | -------------------------- | ------------------------------------------- | ------------------------------------------------- |
| **Presentation** | `features/*/presentation/` | Pages, Widgets, Providers (Riverpod)        | Hanya boleh ketahui Domain layer                  |
| **Domain**       | `features/*/domain/`       | Entities, Use Cases, Abstract Repositories  | Tidak boleh import Flutter atau package eksternal |
| **Data**         | `features/*/data/`         | Models (Isar), Repository Impl, Datasources | Boleh import Isar, Supabase, http                 |
| **Core**         | `lib/core/`                | Services, Utils, Constants, Theme           | Digunakan semua layer, tidak boleh import fitur   |
| **Shared**       | `lib/shared/`              | Reusable widgets & extensions lintas fitur  | Boleh import Core, tidak boleh import fitur       |

---

### 14.4 Aturan Dependensi (Dependency Rule)

```
Presentation  -->  Domain  <--  Data
      |               |
    Core            Core
      |
   Shared
```

> **Aturan utama:** Panah menunjukkan arah dependensi yang diizinkan. Layer `Domain` tidak boleh tahu keberadaan `Data` maupun `Presentation`. Layer `Core` dan `Shared` tidak boleh mengimport folder `features/`.

---

### 14.5 Konvensi Penamaan File

| Tipe                | Pola Nama                | Contoh                      |
| ------------------- | ------------------------ | --------------------------- |
| Page                | `*_page.dart`            | `dashboard_page.dart`       |
| Widget              | nama deskriptif          | `saldo_card.dart`           |
| Provider (Riverpod) | `*_provider.dart`        | `transaction_provider.dart` |
| Use Case            | verb + noun              | `add_transaction.dart`      |
| Repository abstract | `*_repository.dart`      | `bill_repository.dart`      |
| Repository impl     | `*_repository_impl.dart` | `bill_repository_impl.dart` |
| Model (Isar)        | `*_model.dart`           | `transaction_model.dart`    |
| Entity              | `*_entity.dart`          | `transaction_entity.dart`   |
