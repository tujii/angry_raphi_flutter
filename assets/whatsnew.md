## 🆕 Version 2.3.2 (03.02.2026)
- 🐛 Bugfix: Story-Banner zeigt jetzt datenbasierte Stories (auch bei nur 1 Raphcon)
- 🧩 Fix: RenderFlex-Overflow im Typ-Auswahl-Dialog behoben (respon­sive Höhe & Scroll)
- 🛠️ Verbesserte Fehlerbehandlung und Debug-Logs für Story-Generierung

## 🏆 Neue Features

**Version 2.3.0 (Dezember 2025)**
- 🌐 Saubere URLs: URL-Pfade werden jetzt korrekt in der Browser-Adressleiste angezeigt (ohne # Hash)
- ↩️ Navigation: Zurück-Buttons für Nutzungsbedingungen, Datenschutz und Admin-Einstellungen
- 🛡️ Zugriffskontrolle: Nicht-Admins sehen aussagekräftige "Zugriff verweigert" Seite statt Weiterleitung
- 🔧 Firestore-Regeln: Optimierte Sicherheitsregeln für registrierte Benutzer und Admin-Zugriff

**Version 2.2.0 (Dezember 2025)**
- 🥉 Bronze Badge Fix: Bronze Badges werden jetzt korrekt für alle berechtigten Benutzer angezeigt
- 🔐 Logout für alle: Jeder angemeldete Benutzer kann sich jetzt über das Menü abmelden (nicht nur Admins)
- 👤 Benutzer-Avatar: Angemeldete Benutzer sehen ihr Profilbild oder Initial in der App Bar
- 📧 Admin-Check per Email: Admin-Status wird jetzt über Email-Adresse statt User-ID geprüft
- 🔧 Firestore Rules: Berechtigungen für registrierte Benutzer optimiert
- 🧪 Badge-Tests: Komplexe Test-Szenarien für verschiedene Badge-Verteilungen

**Ranking-Bugfix (Dezember 2025)**
- 🥇 Behoben: Benutzer mit gleicher Raphcon-Anzahl erhalten jetzt korrekt das gleiche Ranking-Badge (Gold, Silber, Bronze)
- 🎯 Standard-Wettbewerbsranking implementiert: Bei Gleichstand erhalten alle betroffenen Benutzer denselben Rang
- 🧪 Umfassende Unit-Tests für die Ranking-Logik hinzugefügt

**Story of the Week 2.0 (Dezember 2025)**
- 🎬 Animierte Story-Rotation: Stories wechseln alle 4 Sekunden
- 🎯 Intelligente Story-Generierung mit bis zu 5 verschiedenen Stories
- 🤖 Verbesserte KI-Integration mit 5 verschiedenen Schreibstilen
- 📊 Optimierte Algorithmen für relevantere und vielfältigere Stories
- 🎪 Dot-Indikatoren zeigen aktuelle Story-Position
- ⚙️ Duplikat-Vermeidung für einzigartige Inhalte

**Performance & Loading (Dezember 2025)**
- ⚡ Deutlich verbessertes Loading-Verhalten beim App-Start
- 🚀 Optimierte Service Worker Konfiguration für schnellere Ladezeiten
- 📱 iOS-spezifisches Install-Banner für PWA Installation
- 🔧 Behebung von Widget-Disposal-Fehlern bei Navigation

**Code-Optimierungen**
- 🧹 Entfernung ungenutzter Imports und Variablen
- 💾 Verbesserte Admin-Cache-Verwaltung für Creator-Anzeige
- 🎯 Optimierter Raphcon-Bloc ohne unnötige Abhängigkeiten

**Ranking-System**
- Das Benutzer-Ranking kann jetzt über die Suche angezeigt werden
- Übersichtliche Darstellung der Top-Performer

**Erweiterte Suchfunktion**
- Suche nach Benutzer-Initialen ist jetzt möglich
- Schnellere Navigation zu spezifischen Benutzern

**Admin-Verwaltung**
- Administratoren können jetzt weitere Admins berechtigen
- Dezentrale Verwaltung der Benutzerrechte