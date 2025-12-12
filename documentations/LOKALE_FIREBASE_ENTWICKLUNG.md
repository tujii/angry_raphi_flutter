# 🔥 Lokale Firebase Entwicklungsumgebung

Diese Anleitung beschreibt die komplette Einrichtung einer lokalen Firebase-Entwicklungsumgebung für schnelle Entwicklung ohne Abhängigkeit von der DEV-Umgebung.

## 📋 Übersicht

- **Firebase Emulatoren**: Auth, Firestore, Hosting, UI
- **VS Code Integration**: One-Click Start mit Tasks und Launch Configs
- **Automatisches Seeding**: Beispieldaten werden automatisch erstellt
- **Performance-Optimiert**: Schnelle Ladezeiten durch optimierte Queries

## 🚀 Quick Start

1. **Firebase Emulatoren starten**:
   ```bash
   # Terminal
   firebase emulators:start --export-on-exit=./emulator-data --import=./emulator-data
   ```

2. **VS Code Launch**: 
   - `F5` drücken
   - "🔥 Local + Beispieldaten" auswählen
   - App startet automatisch mit lokalen Emulatoren

## 🛠️ Setup Details

### Firebase Configuration

**firebase.json**:
```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8081,
      "rules": "firestore.rules.dev"
    },
    "hosting": {
      "port": 5002
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

**firestore.rules.dev** (Offene Regeln für Entwicklung):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### VS Code Integration

**.vscode/tasks.json**:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "🔥 Firebase Emulatoren starten",
      "type": "shell",
      "command": "firebase",
      "args": [
        "emulators:start",
        "--export-on-exit=./emulator-data",
        "--import=./emulator-data"
      ],
      "group": "build",
      "isBackground": true,
      "problemMatcher": {
        "owner": "firebase",
        "pattern": {
          "regexp": "^(.*)$",
          "line": 1
        },
        "background": {
          "activeOnStart": true,
          "beginsPattern": "^.*Starting emulators.*$",
          "endsPattern": "^.*All emulators ready.*$"
        }
      }
    },
    {
      "label": "🌱 Beispieldaten laden",
      "type": "shell", 
      "command": "dart",
      "args": ["scripts/seed_emulator_simple.dart"],
      "group": "build"
    }
  ]
}
```

**.vscode/launch.json**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "🔥 Local (mit Firebase Emulatoren)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=USE_FIREBASE_EMULATOR=true"],
      "preLaunchTask": "🔥 Firebase Emulatoren starten"
    },
    {
      "name": "🔥 Local + Beispieldaten",
      "request": "launch", 
      "type": "dart",
      "args": ["--dart-define=USE_FIREBASE_EMULATOR=true"],
      "preLaunchTask": "🔥 Firebase Emulatoren starten"
    }
  ]
}
```

## 🏗️ Architektur-Verbesserungen

### Service-Aufteilung

Komplexe Firebase-Logic wurde in separate Services extrahiert:

**lib/services/firebase_emulator_service.dart**:
- Emulator-Verbindung
- Status-Checks  
- Format-Konvertierung

**lib/utils/emulator_data_seeder.dart**:
- Automatisches Seeding
- Beispieldaten-Erstellung
- HTTP-basierte Firestore-Calls

### Performance-Optimierungen

1. **Non-blocking Setup**: 
   - Firebase-Initialisierung läuft im Hintergrund
   - App startet sofort, Setup parallel

2. **Cache-first Queries**:
   - Keine erzwungenen Server-Calls (`Source.server` entfernt)
   - Schnellere Ladezeiten durch lokalen Cache

3. **Vereinfachte Streams**:
   - Keine komplexen Raphcon-Berechnungen in Real-time
   - Verwendet gespeicherte Counts aus User-Collection

## 📊 Seeding-System

### Automatisches Seeding

Die App lädt automatisch Beispieldaten beim Start:

```dart
// main.dart - Non-blocking Setup
await FirebaseEmulatorService.connectToEmulators();
EmulatorDataSeeder.seedData().catchError((e) {
  print('⚠️ Background seeding failed: $e');
});
```

### Seed-Daten

**Benutzer** (users Collection):
- Max Mustermann (M.M.) - 2 Raphcons
- Anna Schmidt (A.S.) - 2 Raphcons  
- Tom Weber (T.W.) - 2 Raphcons

**Raphcons** (raphcons Collection):
- Verschiedene Hardware-Probleme
- Zeitlich verteilte Erstellung
- Verknüpft mit Demo-Benutzern

**Admins** (admins Collection):
- Demo-Admin-Accounts
- Produktions-Admin-Emails

## 🔧 Entwicklungs-Workflow

### Tägliche Entwicklung

1. **Start**: `F5` → "🔥 Local + Beispieldaten"
2. **Entwickeln**: App läuft mit lokalen Daten
3. **Testen**: Änderungen sofort sichtbar
4. **Stop**: Emulatoren stoppen, Daten werden gespeichert

### Daten-Management

**Daten zurücksetzen**:
```bash
rm -rf emulator-data/
firebase emulators:start
```

**Manuelles Seeding**:
```bash
dart scripts/seed_emulator_simple.dart
```

**Firebase UI**: `http://localhost:4000`
- Firestore-Daten anzeigen
- Auth-Benutzer verwalten
- Logs einsehen

## 🐛 Troubleshooting

### Häufige Probleme

**Java-Version**:
```bash
# Java 21 erforderlich
brew install openjdk@21
sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
```

**Port-Konflikte**:
- Firestore: 8081 (statt 8080)
- Hosting: 5002 (statt 5000/5001)
- Auth: 9099
- UI: 4000

**App hängt beim Laden**:
- Auth-Streams wurden deaktiviert
- Firestore verwendet Cache-first
- Seeding läuft non-blocking

### Debug-Informationen

**Emulator-Status prüfen**:
```bash
curl http://localhost:8081/  # Firestore
curl http://localhost:9099/  # Auth
```

**Logs**:
- VS Code Terminal: Emulator-Logs
- Flutter Debug Console: App-Logs
- Firebase UI: Detaillierte Logs

## ⚡ Performance-Tips

1. **Cache nutzen**: Keine `Source.server` Calls
2. **Streams optimieren**: Nur nötige Daten abonnieren
3. **Seeding intelligent**: Prüfung auf vorhandene Daten
4. **Background-Tasks**: Lange Operationen non-blocking

## 🔄 Zurück zu Produktion

Um wieder auf DEV/PROD zu wechseln:

1. **Launch Config ändern**: `USE_FIREBASE_EMULATOR=false`
2. **Oder**: "Production" Launch Config verwenden
3. **Firebase Options**: Automatisch korrekte Konfiguration

## 📁 Datei-Struktur

```
📂 angry_raphi_flutter/
├── 📂 .vscode/
│   ├── launch.json          # Debug-Konfigurationen
│   └── tasks.json           # Firebase-Tasks
├── 📂 lib/
│   ├── 📂 services/
│   │   └── firebase_emulator_service.dart
│   ├── 📂 utils/
│   │   └── emulator_data_seeder.dart
│   └── main.dart            # Optimierte App-Initialisierung
├── 📂 scripts/
│   └── seed_emulator_simple.dart    # Seeding-Script
├── firebase.json            # Emulator-Konfiguration
├── firestore.rules.dev      # Offene Entwicklungsregeln
└── emulator-data/           # Lokale Emulator-Daten
```

## 🎯 Vorteile

✅ **Schnelle Entwicklung**: Keine Netzwerk-Latenz  
✅ **Offline-Fähig**: Funktioniert ohne Internet  
✅ **Daten-Kontrolle**: Eigene Test-Daten  
✅ **One-Click-Start**: VS Code Integration  
✅ **Performance**: Optimierte Queries und Caching  
✅ **Clean Architecture**: Services sauber getrennt  

---

*Erstellt: Dezember 2025 - Lokale Firebase-Entwicklungsumgebung für AngryRaphi Flutter App*