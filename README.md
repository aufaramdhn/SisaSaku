# SisaSaku

## Deskripsi

SisaSaku adalah aplikasi keuangan pribadi berbasis Flutter yang membantu pengguna mencatat pemasukan, pengeluaran, tagihan, anggaran, hutang, dan split bill. Aplikasi ini dilengkapi dengan sinkronisasi cloud melalui Supabase, notifikasi pengingat via Firebase, serta fitur ekspor laporan ke PDF/CSV.

## Prasyarat

Pastikan tools berikut sudah terinstal di sistem Anda:

| Tool | Versi Minimum | Keterangan |
|------|---------------|------------|
| Flutter SDK | ^3.11.4 | Termasuk Dart SDK |
| Java JDK | 17 | Untuk build Android |
| Android Studio | Latest | Android SDK & emulator |
| Xcode | 15+ | Untuk build iOS (macOS only) |
| CocoaPods | Latest | Dependency manager iOS |
| Git | Latest | Version control |

Verifikasi instalasi Flutter:

```bash
flutter doctor
```

## Setup & Instalasi

### 1. Clone Repository

```bash
git clone <repository-url>
cd sisasaku
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Code Generation (Isar & Riverpod)

Proyek ini menggunakan `build_runner` untuk generate kode Isar database dan Riverpod providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Untuk mode watch (auto-regenerate saat file berubah):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Konfigurasi Environment Variables

Aplikasi menggunakan `--dart-define` untuk menyuntikkan konfigurasi Supabase dan Firebase saat compile time. Lihat bagian [Konfigurasi Environment](#konfigurasi-environment) untuk detail lengkap.

## Menjalankan Aplikasi

### Mode Debug (Tanpa Cloud Services)

Untuk development lokal tanpa Supabase/Firebase:

```bash
flutter run
```

Aplikasi akan berjalan dengan fitur cloud dinonaktifkan secara otomatis.

### Mode Debug (Dengan Cloud Services)

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=FIREBASE_API_KEY=your-api-key \
  --dart-define=FIREBASE_APP_ID=your-app-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your-storage-bucket
```

### Build Release APK

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=FIREBASE_API_KEY=your-api-key \
  --dart-define=FIREBASE_APP_ID=your-app-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your-storage-bucket
```

## Menjalankan Tests

### Semua Tests

```bash
flutter test
```

### Test dengan Coverage

```bash
flutter test --coverage
```

### Test File Tertentu

```bash
flutter test test/features/transaction/data/datasources/transaction_local_datasource_test.dart
```

### Static Analysis

```bash
flutter analyze
```

## Arsitektur Proyek

Proyek ini menggunakan **Feature-Based Clean Architecture** dengan pemisahan layer yang jelas per fitur:

```
lib/
├── core/                          # Infrastruktur bersama
│   ├── constants/                 # Konfigurasi app (Supabase, Firebase, warna, spacing)
│   ├── errors/                    # Exception classes (DatabaseException, dll)
│   ├── providers/                 # Riverpod providers global
│   ├── services/                  # Services (sync, notification, preferences)
│   ├── theme/                     # App theme & typography
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Widget reusable global
├── features/                      # Fitur-fitur aplikasi
│   ├── analytics/                 # Analitik keuangan
│   ├── auth/                      # Autentikasi (Supabase Auth)
│   ├── bill/                      # Manajemen tagihan
│   ├── budget/                    # Anggaran
│   ├── category/                  # Kategori transaksi
│   ├── dashboard/                 # Halaman utama & ringkasan
│   ├── debt/                      # Pencatatan hutang
│   ├── export/                    # Ekspor laporan (PDF/CSV)
│   ├── notification/              # Notifikasi in-app
│   ├── onboarding/                # Onboarding pengguna baru
│   ├── settings/                  # Pengaturan aplikasi
│   ├── splitbill/                 # Split bill
│   └── transaction/               # Transaksi (pemasukan/pengeluaran)
├── routes/                        # Konfigurasi go_router
├── shared/                        # Kode bersama antar fitur
│   └── widgets/                   # Widget yang dipakai banyak fitur
├── firebase_options.dart          # Konfigurasi Firebase (gitignored)
└── main.dart                      # Entry point aplikasi
```

### Struktur Per Fitur

Setiap fitur mengikuti pola Clean Architecture:

```
features/{nama_fitur}/
├── data/                          # Layer Data (implementasi)
│   ├── datasources/               # Akses database (Isar lokal, Supabase remote)
│   ├── models/                    # Model data (Isar @collection, JSON serializable)
│   └── repositories/             # Implementasi repository
├── domain/                        # Layer Domain (bisnis logic)
│   ├── entities/                  # Entitas domain murni (tanpa anotasi DB)
│   ├── repositories/             # Interface repository (abstract class)
│   └── usecases/                  # Use case (satu aksi bisnis per class)
└── presentation/                  # Layer Presentasi (UI)
    ├── pages/                     # Halaman/screen
    ├── providers/                 # Riverpod providers (state management)
    └── widgets/                   # Widget spesifik fitur
```

### Teknologi Utama

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter Riverpod** | State management (dengan code generation) |
| **Isar** | Database lokal NoSQL dengan code generation |
| **Supabase** | Backend cloud (auth, realtime sync, storage) |
| **Firebase Messaging** | Push notifications |
| **go_router** | Navigasi deklaratif |
| **google_fonts** | Typography (Poppins) |
| **pdf** | Generasi laporan PDF |

## Konfigurasi Environment

Aplikasi menggunakan `--dart-define` untuk menyuntikkan konfigurasi sensitif saat compile time. Pendekatan ini memastikan API keys tidak tersimpan di source code.

### Variabel Supabase

| Variabel | Keterangan |
|----------|------------|
| `SUPABASE_URL` | URL project Supabase (contoh: `https://xxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Anonymous/public key dari Supabase |
| `REQUIRE_CLOUD_CONFIG` | Set `true` untuk wajibkan konfigurasi cloud (default: `false`) |

### Variabel Firebase

| Variabel | Keterangan |
|----------|------------|
| `FIREBASE_API_KEY` | API key dari Firebase Console |
| `FIREBASE_APP_ID` | App ID dari Firebase Console |
| `FIREBASE_MESSAGING_SENDER_ID` | Sender ID untuk push notifications |
| `FIREBASE_PROJECT_ID` | Project ID Firebase |
| `FIREBASE_STORAGE_BUCKET` | Storage bucket Firebase |
| `REQUIRE_FIREBASE_CONFIG` | Set `true` untuk wajibkan konfigurasi Firebase (default: `false`) |

### Catatan Penting

- Pada mode **debug**, aplikasi dapat berjalan tanpa konfigurasi cloud (fitur cloud akan dinonaktifkan otomatis).
- Pada mode **release**, konfigurasi cloud wajib disediakan atau build akan gagal.
- Untuk CI/CD, simpan variabel di GitHub Secrets dan pass melalui `--dart-define` di workflow.

### Contoh File `.env` (Referensi Lokal)

Buat file `.env` di root proyek sebagai referensi (jangan commit ke repository):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-storage-bucket
```

Kemudian jalankan dengan script helper:

```bash
# Linux/macOS
flutter run \
  --dart-define=SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d '=' -f2) \
  --dart-define=SUPABASE_ANON_KEY=$(grep SUPABASE_ANON_KEY .env | cut -d '=' -f2) \
  --dart-define=FIREBASE_API_KEY=$(grep FIREBASE_API_KEY .env | cut -d '=' -f2) \
  --dart-define=FIREBASE_APP_ID=$(grep FIREBASE_APP_ID .env | cut -d '=' -f2) \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$(grep FIREBASE_MESSAGING_SENDER_ID .env | cut -d '=' -f2) \
  --dart-define=FIREBASE_PROJECT_ID=$(grep FIREBASE_PROJECT_ID .env | cut -d '=' -f2) \
  --dart-define=FIREBASE_STORAGE_BUCKET=$(grep FIREBASE_STORAGE_BUCKET .env | cut -d '=' -f2)
```
