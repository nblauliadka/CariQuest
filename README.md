<div align="center">
  <h1>🎯 CARIQUEST - Student Talent Marketplace</h1>
  <p><b>A campus talent marketplace platform</b> connecting <b>Experts</b> and <b>Seekers</b> through a bidding system, quest tracking, and a secure wallet.</p>

  [![Interactive Preview](https://img.shields.io/badge/Interactive_Preview-Click_Here-0A6C75?style=for-the-badge&logo=netlify&logoColor=white)](https://cariquestpreview.netlify.app)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](#)
  [![Riverpod](https://img.shields.io/badge/Riverpod-0A0A0A?style=for-the-badge&logo=dart&logoColor=white)](#)
</div>

<br>

## ✨ What is CariQuest?

CariQuest is a Flutter-based cross-platform mobile application specifically designed for the student ecosystem at **Universitas Syiah Kuala (USK)**. This application solves the campus talent distribution problem by providing a service marketplace that matches students seeking task/project assistance with student experts in their respective fields.

| Role | Core Features |
|---|---|
| 🛠️ **Expert** | Manage portfolio profiles, place bids on projects (Quests), accept jobs, and track earnings balance in the Wallet. |
| 🔍 **Seeker** | Create job postings (Quests), review applicants, monitor the project lifecycle (Pending → Working → Review → Finished), and provide ratings. |
| 🛡️ **Admin** | Monitor all transactions, verify users, and mediate disputes between students. |

---

## 🏗 Demo Mock MVP Architecture

For a rapid, frictionless portfolio showcase, this version of CariQuest is built as a **100% Offline Local Mock MVP**:

- **☁️ Zero Cloud Configuration**: All Firebase dependencies (Auth, Firestore, Storage) have been completely stripped out. No API keys, no CORS errors.
- **📦 In-Memory Data Engine**: Utilizes an isolated `MockData` system that simulates a real-time database, network latency, and state persistence during the app runtime.
- **⚡️ Plug & Play**: The application is ready to run instantly without any server setup.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.3+) |
| **State Management** | Riverpod 2.x (`StateNotifier` + `StreamProvider`) |
| **Routing** | `go_router` 13.x (Declarative App Routing) |
| **Storage Layer** | `shared_preferences` (Local login session) |
| **UI & Animations** | Material 3, `flutter_animate`, `lottie` |

---

## 🔑 Demo Accounts (Instant Login)

The system is pre-populated with verified account data. Use the credentials below to test different roles (all use the same password):

| Role | Email Login | Password |
|---|---|---|
| **🎓 Expert** | `expert@demo.com` | `demo123` |
| **🔍 Seeker** | `seeker@demo.com` | `demo123` |
| **🛡️ Admin** | `admin@demo.com` | `demo123` |

> *Pro Tip: The login screen is equipped with a "Demo Login" button for quick auto-fill.*

---

## 📁 Project Structure (Feature-First)

```text
cariquest/
├── lib/
│   ├── core/         ← Themes, Constants, and MockData Engine
│   ├── features/     ← Independent modules (Auth, Quest, Expert, Seeker, Wallet)
│   ├── shared/       ← Global models and reusable UI Widgets
│   └── main.dart     ← App entry point without Firebase initialization
└── pubspec.yaml
