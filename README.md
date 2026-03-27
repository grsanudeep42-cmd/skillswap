# SkillSwap

**Exchange skills, not money.**  
A peer-to-peer learning app where people trade what they know for what they want to learn.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-Express-339933?logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?logo=mongodb&logoColor=white)
![Socket.io](https://img.shields.io/badge/Socket.io-Real--time-010101?logo=socket.io&logoColor=white)
![Agora](https://img.shields.io/badge/Agora-RTC-099DFD)

## Problem

Learning new skills is expensive.  
Many people can teach but do not have a platform to reach learners.  
SkillSwap solves both by enabling direct skill-for-skill exchange with zero payments.

## What We Built

SkillSwap is a mobile-first platform where two people exchange knowledge directly:  
You teach me Flutter, I teach you Digital Marketing. No money involved.

## Features

- 🎯 Smart skill matching engine
- 💬 Real-time chat powered by Socket.io
- 📹 1:1 video calling with Agora RTC
- 📈 Exchange progress tracking with completion percentages
- 🗂️ Session history logging
- 📊 Weekly activity analytics dashboard
- 🔀 Sent / Received / Connected match tabs
- ⭐ Post-session star ratings
- 🧠 Skill distribution statistics
- 👤 Rich profile with teach/learn skills

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter (Android) |
| Backend | Node.js + Express |
| Database | MongoDB |
| Real-time | Socket.io |
| Video Calling | Agora RTC |
| State Management | Provider |

## Project Structure

```text
hackathon/
├── backend/        # Node.js + Express API
└── hackathon_app/  # Flutter mobile app
```

## Setup

### 1) Backend

```bash
cd backend
npm install
npm run dev
```

If `npm run dev` is unavailable:

```bash
npm start
```

### 2) Flutter App

```bash
cd hackathon_app
flutter pub get
flutter run
```

### 3) Analyze and Build

```bash
cd hackathon_app
flutter analyze
flutter build apk --debug
```

Debug APK output:

`hackathon_app/build/app/outputs/flutter-apk/app-debug.apk`

## Screenshots

> Add product screenshots here:
- Login / Onboarding
- Discover Matches
- Real-time Chat
- Video Session
- Analytics Dashboard

## Team

> Add team member names, roles, and contact links.

## License

MIT
