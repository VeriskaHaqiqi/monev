
<div align="center">

# 💰 Monev
### Money Evaluation — Personal Finance Tracker

Aplikasi mobile pencatatan keuangan pribadi yang sederhana, modern, dan mudah digunakan.
Dibangun sebagai tugas mata kuliah **Mobile Development**.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

</div>

---

## 📖 Tentang Aplikasi

**Monev** membantu pengguna mencatat pemasukan dan pengeluaran, mengelola kategori transaksi, memantau kondisi keuangan, serta mengevaluasi kebiasaan finansial melalui statistik sederhana. Aplikasi ini dibangun sebagai media pembelajaran Flutter dengan tetap memperhatikan desain yang modern dan fitur yang realistis.

## ✨ Fitur Utama

- 🔐 **Autentikasi** — Registrasi & Login dengan Firebase Authentication (Email/Password)
- 💵 **Manajemen Transaksi** — Tambah, ubah, hapus transaksi pemasukan & pengeluaran
- 🏷️ **Manajemen Kategori** — Kelola kategori Pemasukan & Pengeluaran secara terpisah, dengan proteksi penghapusan kategori yang masih digunakan transaksi
- 📊 **Statistik** — Ringkasan saldo, pie chart distribusi pengeluaran per kategori, dan bar chart pemasukan vs pengeluaran per bulan
- 👤 **Profil** — Upload foto profil, ubah nama, dan logout
- 💬 **Kutipan Motivasi** — Terintegrasi dengan REST API (ZenQuotes) di halaman Dashboard
- 🎨 **Desain Konsisten** — Design system custom bertema *emerald neobrutalism* (outline tebal + hard shadow)

## 🛠️ Tech Stack

| Kategori          | Teknologi                                  |
|--------------------|---------------------------------------------|
| Frontend           | Flutter (Dart)                             |
| Backend & Database | Firebase Authentication, Firebase Realtime Database |
| REST API           | [ZenQuotes API](https://zenquotes.io)      |
| Chart              | fl_chart                                   |
| Font               | Google Fonts (Poppins & Inter)             |
| Version Control    | Git & GitHub                               |

## 📱 Screenshot

<div align="center">

| Kategori | Dashboard | Transaksi |
|:---:|:---:|:---:|
| ![Login](screenshots/kategori.png) | ![Dashboard](screenshots/dashboard.png) | ![Statistik](screenshots/transaksi.png) |
</div>

## 🏗️ Struktur Proyek

```
lib/
├── core/
│   ├── constants/       # Design tokens (warna, tipografi)
│   ├── services/        # Auth, Database, Quote service
│   ├── utils/            # Helper functions (format Rupiah, dll)
│   └── widgets/          # Reusable widgets (NeoContainer, BottomNav)
├── features/
│   ├── auth/             # Splash, Login, Registrasi
│   ├── dashboard/        # Halaman utama
│   ├── transaction/      # Daftar & form Transaksi
│   ├── category/         # Manajemen Kategori
│   ├── statistic/        # Statistik & Chart
│   ├── profile/          # Profil pengguna
│   └── main_screen.dart  # Bottom navigation container
├── models/               # User, Transaction, Category model
├── firebase_options.dart
└── main.dart
```

## 🗂️ Struktur Data (Realtime Database)

```
monev-dfb25-default-rtdb/
├── users/
│   └── {uid}/
│       ├── name
│       ├── email
│       └── photoUrl (base64)
├── transactions/
│   └── {pushId}/
│       ├── title
│       ├── amount
│       ├── type          # income | expense
│       ├── categoryId
│       ├── date
│       ├── note
│       └── userId
└── categories/
    └── {pushId}/
        ├── name
        ├── type           # income | expense
        └── userId
```

## 🚀 Cara Menjalankan Proyek

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stable terbaru)
- Android Studio / VS Code dengan Flutter extension
- Akun [Firebase](https://console.firebase.google.com) dan [Firebase CLI](https://firebase.google.com/docs/cli)

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/username/monev.git
   cd monev
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Hubungkan ke project Firebase kamu sendiri**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   > File `firebase_options.dart` sengaja tidak disertakan/di-*gitignore* karena berisi konfigurasi spesifik project Firebase. Buat project Firebase sendiri di [Firebase Console](https://console.firebase.google.com), lalu jalankan perintah di atas.

4. **Aktifkan service di Firebase Console**
   - **Authentication** → Sign-in method → aktifkan **Email/Password**
   - **Realtime Database** → Create Database → mode **Test**

5. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 🔒 Keamanan Data

Realtime Database Rules saat ini masih menggunakan mode *test* untuk keperluan pengembangan. Untuk penggunaan produksi, disarankan mengganti rules agar setiap pengguna hanya dapat mengakses data miliknya sendiri, misalnya:

```json
{
  "rules": {
    "transactions": {
      "$id": {
        ".read": "auth != null && data.child('userId').val() === auth.uid",
        ".write": "auth != null"
      }
    },
    "categories": {
      "$id": {
        ".read": "auth != null && data.child('userId').val() === auth.uid",
        ".write": "auth != null"
      }
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
```

## 🎯 Ruang Lingkup

Aplikasi ini **tidak** mencakup:
- Payment gateway atau transfer uang
- Sinkronisasi antar bank
- Notifikasi push
- Fitur AI
- Multi-user dalam satu akun

Monev dirancang murni untuk pencatatan dan evaluasi keuangan pribadi per pengguna.

## 👩‍💻 Dikembangkan Oleh

Dibuat sebagai tugas mata kuliah **Mobile Development** — Program Studi Sistem Informasi, Universitas Airlangga.

---

<div align="center">
  <sub>Built with 💚 using Flutter & Firebase</sub>
</div>
=======
# monev
Monev merupakan aplikasi personal finance tracker yang membantu pengguna mencatat pemasukan dan pengeluaran, mengelola kategori transaksi, memantau kondisi keuangan, serta mengevaluasi kebiasaan finansial melalui statistik sederhana.
>>>>>>> bbc0a8d5b7f5aca0d61f4df8ae5c4541c4764dcc
