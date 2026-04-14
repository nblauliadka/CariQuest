# CariQuest

[![Interactive Product Showcase](https://img.shields.io/badge/Live_Demo_%26_Interactive_Preview-0A6C75?style=for-the-badge&logo=vercel&logoColor=white)](https://your-future-showcase-link.com)
> *Click the badge above to access the Interactive Product Showcase, feature breakdown, and the live web demo of CariQuest.*

---

## 🚀 About CariQuest

**CariQuest** is a premium, high-performance skill and talent marketplace tailored specifically for the Universitas Syiah Kuala (USK) student ecosystem. The platform serves as a secure bridge, connecting **Seekers** (students looking for specific services or help with projects) with **Experts** (talented students offering their skills, from UI/UX design to data analysis). 

Built with modern UI/UX principles in mind, CariQuest delivers a top-tier mobile and web experience featuring fully interactive dashboards, seamless onboarding, robust state management, and real-time status tracking for active quests.

## 🏗 Demo Mock MVP Architecture

To streamline product showcases, portfolio presentations, and rigorous UI/UX testing without the absolute need for complex backend configurations or internet dependencies, this build of CariQuest has been architected as a **100% Offline Local Mock MVP**. 

- **☁️ Zero Cloud Configuration**: All Firebase (`cloud_firestore`, `firebase_auth`, `firebase_storage`) dependencies have been intentionally stripped. No API keys, no Google Services JSONs, no CORS issues on the web!
- **📦 In-Memory Data Engine**: Uses an isolated singleton `MockData` engine that faithfully emulates remote reactive streams, pagination, and backend-latency.
- **⚡️ Plug & Play**: Clone the repository and execute `flutter run`. The app will instantly launch fully seeded with realistic test data. Data modifications (bids, chats, and account updates) persist dynamically for the life cycle of the active session.

## 🔐 Built-in Demo Credentials

The pre-seeded demo environment includes the following verified test accounts. All accounts utilize the same secure default password:

| User Role | Email Address | Password | Features |
| :--- | :--- | :--- | :--- |
| **🎓 Expert** | `expert@demo.com` | `demo123` | Access to the Expert Dashboard, Quest Feed, Bidding, Portfolio creation. |
| **🔍 Seeker** | `seeker@demo.com` | `demo123` | Access to Seeker Dashboard, Quest creation, Applicant tracking, Payment mockups. |
| **🛡 Admin** | `admin@demo.com` | `demo123` | Access to Mediation Console, Transaction validation, User ban features. |

*Note: The login screen also features an interactive tap-to-autofill credential card for rapid testing.*

## 🛠 Tech Stack

| Category | Technology / Framework |
| :--- | :--- |
| **Frontend Framework** | `Flutter` (Cross-platform UI) |
| **Language** | `Dart` |
| **State Management** | `flutter_riverpod` (Riverpod 2.x) |
| **Routing** | `go_router` (Declarative deep-linking) |
| **Architecture** | `MockData Repository Pattern` (Repository mapping / SOLID principles) |

## 💻 Getting Started (Local Development)

Begin by ensuring Flutter is correctly installed on your machine. All non-essential platform files have been removed, guaranteeing a pristine build environment.

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/CariQuest.git
   cd CariQuest
   ```

2. **Fetch Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   For the best interactive preview (PWA/Web app implementation):
   ```bash
   flutter run -d chrome
   ```
   *To build a production web bundle for hosting:*
   ```bash
   flutter build web
   ```

---
*Developed with ❤️ as a modern academic portfolio showcase.*
