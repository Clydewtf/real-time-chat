# 💬 Real-Time Chat App — Flutter + GraphQL

A **modern real-time messaging app** built with Flutter and GraphQL.
Designed as a pet-project focused on clean architecture, Riverpod state management, and WebSocket-powered live communication.
Fast. Offline-capable.

---

## 🚀 Features

- **Authentication** — email + password login (JWT)
- **Chat list** — instant updates on last messages
- **Real-time messaging** — WebSocket subscriptions keep chats alive without reloads
- **Typing indicators** — feel the presence of a live conversation partner
- **Online / Last seen status** — lightweight presence system
- **Smooth UX**:
  - auto-scroll on new messages
  - graceful behavior in slow networks
  - animated updates and message bubbles
- **Offline-first architecture** — local chat history available anytime
- **Error handling** — thoughtful state transitions
- **Scalable data structure** — ready for group chats and media in future

---

## 🧠 Tech Stack

### 🖥️ Frontend (Flutter)

- Flutter + Dart
- Clean Architecture + domain-driven mindset
- Riverpod (StateNotifier + AsyncValue)
- Navigation: GoRouter (Navigator 2.0)
- GraphQL: Queries, Mutations, Subscriptions
- WebSockets for realtime
- Local DB: Drift (encrypted)
- Codegen: Artemis, Freezed, json_serializable
- Streams & async programming
- Testing: unit & widget
- Sentry/AppMetrica (optional)

### ⚙️ Backend (Hasura + PostgreSQL)

- Hasura GraphQL Engine
- PostgreSQL storage
- Subscriptions for realtime events
- JWT authorization
- Dockerized setup for local development
- Railway/Vercel planned for production deployment

---

## 🧩 CI/CD & Workflow

- **GitHub Actions** for:
  - Build & test automation (planned)
  - Linting & checks for Dart
  - Security verification
- Automatic migrations and deployment planned as app evolves
- Conventional branching (main, dev, feature/*)

---

## 🗺️ Roadmap

- [ ] 
- [ ] 
- [ ] 

---

## ✨ Highlights

- Realtime UX powered by GraphQL Subscriptions
- Offline-first experience wherever you go
- Clean separation of UI, domain, and data layers
- Scalable design prepared for production-level features
- Modern UX patterns for messaging apps

---

## 📌 Status

Actively in development.
