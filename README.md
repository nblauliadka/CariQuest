<div align="center">
  <h1>🎯 CARIQUEST — USK Student Talent Marketplace</h1>
  <p><b>Platform Marketplace Talenta Kampus</b> yang menghubungkan <b>Expert</b> dan <b>Seeker</b> di ekosistem Universitas Syiah Kuala melalui sistem <i>bidding</i>, <i>quest tracking</i>, dan <i>secure wallet</i>.</p>

  [![Interactive Preview](https://img.shields.io/badge/Live_Demo_%26_Interactive_Preview-0A6C75?style=for-the-badge&logo=netlify&logoColor=white)](https://cariquestpreview.netlify.app)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](#)
  [![Riverpod](https://img.shields.io/badge/Riverpod-0A0A0A?style=for-the-badge&logo=dart&logoColor=white)](#)
</div>

<br>

## ✨ What is CariQuest?

CariQuest adalah aplikasi *mobile cross-platform* berbasis Flutter yang dirancang khusus untuk ekosistem mahasiswa **Universitas Syiah Kuala (USK)**. Aplikasi ini memecahkan masalah distribusi talenta kampus dengan menyediakan *marketplace* jasa yang mempertemukan pencari bantuan tugas/proyek dengan mahasiswa ahli di bidangnya.

| Role | Core Features |
|---|---|
| 🛠️ **Expert** | Mengelola profil portofolio, melakukan *bidding* pada proyek (Quest), menerima pekerjaan, dan melacak saldo pendapatan di Wallet. |
| 🔍 **Seeker** | Membuat postingan pekerjaan (Quest), mereview pelamar, memantau *lifecycle* proyek (Pending → Working → Review → Finished), dan memberikan rating. |
| 🛡️ **Admin** | Memantau seluruh transaksi, melakukan verifikasi pengguna, dan memediasi sengketa (*dispute*) antar mahasiswa. |

---

## 🏗 Demo Mock MVP Architecture

Untuk keperluan *showcase* portofolio yang cepat dan bebas hambatan, versi CariQuest ini dibangun sebagai **100% Offline Local Mock MVP**:

- **☁️ Zero Cloud Configuration**: Seluruh dependensi Firebase (Auth, Firestore, Storage) telah dihapus total. Tidak ada *API keys*, tidak ada *CORS errors*.
- **📦 In-Memory Data Engine**: Menggunakan sistem `MockData` terisolasi yang mensimulasikan *database real-time*, *latency*, dan *state persistence* selama aplikasi berjalan.
- **⚡️ Plug & Play**: Aplikasi siap dijalankan secara instan tanpa perlu *setup server*.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.3+) |
| **State Management** | Riverpod 2.x (`StateNotifier` + `StreamProvider`) |
| **Routing** | `go_router` 13.x (Declarative App Routing) |
| **Storage Layer** | `shared_preferences` (Sesi login lokal) |
| **UI & Animations** | Material 3, `flutter_animate`, `lottie` |

---

## 🔑 Demo Accounts (Instan Login)

Sistem sudah diisi dengan data akun terverifikasi. Gunakan kredensial di bawah ini untuk mencoba berbagai *role* (semua menggunakan password yang sama):

| Role | Email Login | Password |
|---|---|---|
| **🎓 Expert** | `expert@demo.com` | `demo123` |
| **🔍 Seeker** | `seeker@demo.com` | `demo123` |
| **🛡️ Admin** | `admin@demo.com` | `demo123` |

> *Pro Tip: Layar login sudah dilengkapi tombol "Demo Login" untuk auto-fill.*

---

## 📁 Project Structure (Feature-First)

```text
cariquest/
├── lib/
│   ├── core/         ← Tema, Konstanta, dan MockData Engine
│   ├── features/     ← Modul independen (Auth, Quest, Expert, Seeker, Wallet)
│   ├── shared/       ← Model global dan Widget UI yang dapat digunakan ulang
│   └── main.dart     ← Entry point aplikasi tanpa inisialisasi Firebase
└── pubspec.yaml
```

---

## 🚀 Quick Start — Local Development

Karena menggunakan sistem *Mock Data*, aplikasi ini sangat ringan dan dioptimalkan untuk berjalan langsung di *browser* laptop Anda.

**1. Clone Repository**
```bash
git clone [https://github.com/nblauliadka/cariquest.git](https://github.com/nblauliadka/cariquest.git)
cd cariquest
```

**2. Install Dependencies**
```bash
flutter pub get
```

**3. Run the App (Web Mode Recommended)**
```bash
flutter run -d chrome
```

---
<div align="center">
  <i>Built with ☕ and 🔥 for Universitas Syiah Kuala</i>
</div>
