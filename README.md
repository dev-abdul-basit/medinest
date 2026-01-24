# Medinest

Medinest is a Flutter-based medication reminder and personal health journaling application designed for reliable daily use. It helps users manage pills, track health notes, and coordinate care involving doctors and family members, with strong offline support and cloud synchronization.

Built with Flutter 3, GetX, Firebase, and Sqflite, Medinest is architected for scalability, performance, and long-term maintainability.
## Core Features

Medinest focuses on practical medication adherence and lightweight health tracking.

Medication management allows users to create pill reminders with precise schedules and custom alert sounds. Reminders can be associated with the user, a doctor, or a family member, enabling shared care scenarios.

Health journaling provides a simple way to log notes related to medication intake, symptoms, or daily health observations.

Doctor and family profiles allow structured organization of reminders and records, suitable for caregivers managing multiple dependents.

Offline-first behavior is achieved through Sqflite, with Firebase used for authentication, cloud sync, notifications, and backups.

Monetization is supported through Google AdMob and in-app subscriptions, with purchase handling implemented via the official Flutter in_app_purchase APIs.

## Tech Stack

Flutter (Dart) – Cross-platform UI and application logic

GetX – State management, routing, and dependency injection

Firebase – Auth, Firestore, Storage, Cloud Messaging, App Check

Sqflite – Local persistent storage for offline access

Flutter Local Notifications – Time-critical medication alerts

Google Mobile Ads – AdMob integration

In-App Purchases – Subscription handling

Dio – Networking

Timezone & Flutter Timezone – Accurate scheduled notifications

## Architecture Overview
The project follows a modular, feature-oriented structure with clear separation between UI, controllers, services, and data layers.

GetX is used consistently for state management and navigation to minimize boilerplate and improve testability.

Local data is treated as the source of truth, with Firebase acting as a synchronization and backup layer rather than a hard dependency for core functionality.
