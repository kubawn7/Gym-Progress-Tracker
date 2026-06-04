# 🏋️ GymTracker

Minimalistyczna aplikacja mobilna do śledzenia postępów na siłowni. Zapisuj ciężary, monitoruj rekordy i zarządzaj przerwami między seriami.

---

## Funkcjonalności

- **Ćwiczenia** — dodawaj ćwiczenia do własnej listy z podziałem na kategorie (klatka, plecy, nogi itd.)
- **Historia wyników** — zapisuj ciężar, serie i powtórzenia po każdym treningu
- **Rekordy** — automatyczne śledzenie rekordowego ciężaru na każdym ćwiczeniu
- **Timer przerw** — odliczanie czasu odpoczynku z presetami (30s–5min) i animowanym kółkiem
- **Pulpit** — szybki podgląd statystyk i ostatnio trenowanych ćwiczeń
- **Persystencja** — dane zapisywane lokalnie, działają bez internetu

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.x |
| State management | Provider |
| Persystencja | SharedPreferences |
| Czcionki | Google Fonts (Space Grotesk) |

## Uruchomienie

```bash
# Zainstaluj zależności
flutter pub get

# Uruchom (wybierz platformę)
flutter run -d chrome      # przeglądarka
flutter run -d windows     # Windows desktop
flutter run                # podłączone urządzenie / emulator Android
```

Wymagany Flutter SDK `>=3.0.0`.

## Struktura projektu

```
lib/
├── main.dart               # Punkt wejścia, nawigacja dolna
├── theme.dart              # Ciemny motyw (kolory, czcionki)
├── models/
│   └── exercise.dart       # Modele Exercise i WeightEntry
├── providers/
│   ├── exercise_provider.dart   # Logika ćwiczeń + zapis
│   └── timer_provider.dart      # Logika timera
└── screens/
    ├── home_screen.dart          # Pulpit
    ├── exercises_screen.dart     # Lista ćwiczeń
    ├── exercise_detail_screen.dart  # Historia + dodawanie wyników
    └── timer_screen.dart         # Timer przerwy
```

## Screenshoty

> _Do uzupełnienia po pierwszym uruchomieniu._

---

## Licencja

MIT
