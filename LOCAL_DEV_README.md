# Lokale Entwicklung - README

## 🚀 Schnellstart

Führe einfach diesen Befehl aus:

```bash
./dev_local.sh
```

Das wars! Die gesamte lokale Entwicklungsumgebung startet automatisch.

## 📋 Was passiert automatisch:

1. ✅ **Abhängigkeitsprüfung** - Firebase CLI & Flutter
2. 🔐 **Firebase Login** - Falls nötig
3. 📦 **Flutter Dependencies** - Automatische Aktualisierung
4. 🔥 **Firebase Emulatoren** - Auth, Firestore, Hosting
5. 🔨 **Flutter Build** - Mit Emulator-Konfiguration
6. 🌐 **Lokaler Server** - Vollständig funktionsfähig

## 🌐 Lokale URLs:

- **Firebase UI**: http://localhost:4000
- **Web App**: http://localhost:5000  
- **Auth Emulator**: http://localhost:9099
- **Firestore**: http://localhost:8080

## 💾 Datenpersistenz

Die Emulator-Daten werden automatisch in `firebase-emulator-data/` gespeichert und beim nächsten Start wiederhergestellt.

## 🛑 Stoppen

Einfach `Ctrl+C` drücken - alle Services werden sauber beendet.

## 🔧 Manuelle Konfiguration

Falls du etwas anpassen möchtest:

```bash
# Nur Emulatoren starten
firebase emulators:start

# Flutter mit Emulator-Flag builden  
flutter build web --dart-define=USE_FIREBASE_EMULATOR=true

# Flutter mit normalem Build
flutter build web
```