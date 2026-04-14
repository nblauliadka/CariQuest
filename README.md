<div align="center">
  <h1>🎯 CARIQUEST — USK Student Talent Marketplace</h1>
  <p><b>Platform Marketplace Talenta Kampus</b> yang menghubungkan <b>Expert</b> dan <b>Seeker</b> di ekosistem Universitas Syiah Kuala melalui sistem <i>bidding</i>, <i>quest tracking</i>, dan <i>secure wallet</i>.</p>

  [![Interactive Preview](https://img.shields.io/badge/Live_Demo_%26_Interactive_Preview-0A6C75?style=for-the-badge&logo=vercel&logoColor=white)](https://link-preview-lu-nanti.com)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](#)
  [![Riverpod](https://img.shields.io/badge/Riverpod-0A0A0A?style=for-the-badge&logo=dart&logoColor=white)](#)
</div>

<br>

## ✨ What is CariQuest?
CariQuest adalah aplikasi *mobile cross-platform* yang dibangun sebagai proyek MVP portofolio. Aplikasi ini berjalan secara lokal tanpa cloud. 
Menghadirkan ekosistem jasa yang cerdas bagi mahasiswa USK melalui pengelolaan proyek komprehensif, fitur *bidding* efisien, dan gamifikasi berorientasi pertumbuhan. Dirancang dengan lapisan *In-Memory Mock Data* sehingga seluruh fitur seperti pelacakan status pesanan, dompet digital, hingga riwayat transaksi dapat dijalankan tanpa memerlukan dependensi backend.

| Role | What they can do |
|---|---|
| 🛠️ **Expert** | Melamar quest (bid/apply), mengerjakan pesanan, menerima saldo digital, meningkatkan EXP/Rank, melihat notifikasi *real-time*, dan berkomunikasi via *in-app chat*. |
| 🔍 **Seeker** | Membuka lowongan project (post quest) dengan detail *jobdesk* dan target *budget*, menyetujui penawaran, mengelola pelacakan tugas dari *pending* hingga *finished*, serta memberi ulasan. |
| 🛡️ **Admin** | Memoderasi masalah operasional melalui fitur mediasi sengketa (*dispute resolution*) dan memantau akun-akun yang terdaftar dalam platform. |

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter SDK `>=3.3.4`, Dart `<4.0.0` |
| State | `flutter_riverpod: ^2.5.1`, `riverpod_annotation: ^2.3.5` |
| Routing | `go_router: ^13.2.0` |
| Navigation | `flutter_web_plugins/url_strategy.dart` |
| UI & Animations | `google_fonts`, `lottie`, `flutter_animate`, `shimmer`, `flutter_staggered_grid_view` |
| Database | MockData Engine (In-memory, Zero Cloud Config), dengan `shared_preferences: ^2.2.3` |

---

## 📁 Project Structure
```text
cariquest/
├── pubspec.yaml
└── lib/
    ├── auth/           ← General Auth Logic and Global Authentication State
    ├── core/           ← App Theme, Colors, Enums, Error Handling, and MockData Engine
    ├── features/       ← Feature-based domains (chat, dispute, expert, notification, payment, profile, quest, rating, seeker, wallet)
    ├── quest/          ← Dedicated sub-routing/logic specifically for Quest integrations
    ├── shared/         ← Reusable widgets, app router config, and global data models
    └── main.dart       ← Application Entry Point & ProviderScope Initialization
```

---

## 🔑 Demo Accounts (Instan Login)

| Role | Email | Password |
|---|---|---|
| Expert 🛠️ | `expert@demo.com` | `demo123` |
| Seeker 🔍 | `seeker@demo.com` | `demo123` |

---

## 🚀 Quick Start — Local MVP
```bash
# 1. Install Dependencies
flutter pub get

# 2. Run the Application in Chrome
flutter run -d chrome
```

---
*Developed with ❤️ as a modern academic portfolio showcase.*
