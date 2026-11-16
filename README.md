# Arsora Mobile

Arsora Mobile merupakan aplikasi berbasis Flutter yang dikembangkan sebagai platform katalog dan penjualan lukisan. Aplikasi ini memungkinkan pengguna untuk melihat berbagai koleksi lukisan, mencari produk, mengelola keranjang belanja, serta mengelola profil pengguna.

## Teknologi yang Digunakan

- **Flutter** – Framework untuk membangun aplikasi mobile.
- **Dart** – Bahasa pemrograman yang digunakan.
- **HTTP** – Untuk komunikasi dengan REST API.
- **Shared Preferences** – Untuk menyimpan token autentikasi.
- **Image Picker** – Untuk memilih gambar dari galeri perangkat.
- **Intl** – Untuk membantu format tanggal dan angka.

## Fitur Aplikasi

- Registrasi akun pengguna.
- Login dan autentikasi pengguna.
- Menampilkan daftar produk lukisan.
- Menampilkan kategori lukisan.
- Melihat detail produk.
- Menambahkan produk ke keranjang belanja.
- Mengelola produk lukisan.
- Mengunggah gambar produk.
- Mengedit data profil pengguna.
- Mengunggah foto profil.
- Logout dari akun pengguna.

## Struktur Project

```text
arsora_mobile/
├── android/
├── assets/
├── ios/
├── linux/
├── macos/
├── windows/
├── lib/
│   ├── pages/
│   ├── service/
│   ├── theme/
│   ├── widgets/
│   └── main.dart
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## Instalasi

1. Clone repository:

```bash
git clone URL_REPOSITORY
```

2. Masuk ke folder project:

```bash
cd arsora_mobile
```

3. Install dependencies:

```bash
flutter pub get
```

4. Jalankan aplikasi:

```bash
flutter run
```

## Koneksi API

Arsora Mobile menggunakan REST API dari Arsora Backend untuk melakukan komunikasi dan pengelolaan data aplikasi.

Konfigurasi API terdapat pada file:

```text
lib/service/api.dart
```

Pastikan server backend sudah berjalan dan alamat API telah disesuaikan dengan lingkungan pengembangan.

## Backend Repository

Arsora Mobile terhubung dengan Arsora Backend yang berfungsi untuk mengelola data pengguna, produk lukisan, kategori, keranjang belanja, dan proses autentikasi melalui REST API.

Repository backend dapat diakses melalui tautan berikut:

- **Arsora Backend:** [https://github.com/Anggitaaa15/Arsora-Backend](https://github.com/Anggitaaa15/Arsora-Backend)


## Pengembang

**Arsora** – Mobile Application Development
