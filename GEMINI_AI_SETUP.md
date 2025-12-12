# Gemini AI Integration für Story of the Day

## Übersicht

Die Story of the Day Feature kann optional Google's Gemini AI nutzen, um dynamische, lustige Geschichten über Raphcon-Statistiken zu generieren.

## Features

- ✨ **AI-Generierte Stories**: Nutzt Gemini 1.5 Flash für kreative, kontextbezogene Texte
- 🔄 **Automatischer Fallback**: Bei Fehlern oder ohne API-Key werden Templates verwendet
- 🆓 **Kostenloses Tier**: Gemini API bietet 60 Requests/Minute kostenlos
- 🔒 **Datenschutz**: API-Key bleibt lokal, keine Daten werden dauerhaft gespeichert

## Setup

### 1. Gemini API Key erstellen

1. Besuche [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Melde dich mit deinem Google-Konto an
3. Klicke auf "Get API Key" oder "Create API Key"
4. Kopiere den generierten API-Key

### 2. API Key konfigurieren

Öffne `lib/core/config/ai_config.dart` und setze deinen API-Key:

```dart
class AIConfig {
  static const String? geminiApiKey = 'DEIN_API_KEY_HIER'; // Ersetze mit deinem Key
  
  static bool get isEnabled => geminiApiKey != null && geminiApiKey.isNotEmpty;
}
```

### 3. App neu bauen

```bash
flutter pub get
flutter run
```

## Funktionsweise

### Mit Gemini AI (API-Key konfiguriert)

1. System sammelt wöchentliche Raphcon-Statistiken
2. Sendet Kontext an Gemini API (Benutzername, Problem-Typ, Anzahl)
3. Gemini generiert einen humorvollen deutschen Satz
4. Story wird im Banner angezeigt

**Beispiel-Prompt an Gemini:**
```
Generiere einen kurzen, lustigen deutschen Satz über Technik-Probleme.
Benutzer: M.J.
Problem: Headset
Anzahl: 5 mal diese Woche
```

**Gemini Antwort:**
```
🎧 M.J. hat den epischen Kampf gegen sein Headset 5x verloren! 😅
```

### Ohne Gemini AI (Kein API-Key)

Das System nutzt vordefinierte, lustige Templates:

```dart
'🎧 $userName hat den Krieg ${count}x gegen sein Headset verloren diese Woche!'
```

## API Limits

**Gemini API Free Tier:**
- ✅ 60 Requests pro Minute
- ✅ 1,500 Requests pro Tag
- ✅ Kostenlos für immer

Da Stories nur einmal pro Tag generiert werden, bleibt man problemlos im Free Tier.

## Fehlerbehandlung

Das System ist robust gegen API-Fehler:

```dart
// Versuch 1: Gemini AI
if (_geminiService.isAvailable) {
  final aiStory = await _geminiService.generateStory(...);
  if (aiStory != null) return aiStory;
}

// Fallback: Templates
return '🎧 $userName hat den Krieg ${count}x gegen sein Headset verloren!';
```

**Mögliche Fehlerszenarien:**
- ❌ Kein API-Key → Templates werden verwendet
- ❌ Netzwerkfehler → Templates werden verwendet  
- ❌ Rate Limit erreicht → Templates werden verwendet
- ❌ Ungültige API-Antwort → Templates werden verwendet

## Datenschutz

- **API-Key**: Wird nur lokal in der App gespeichert
- **User-Daten**: Nur initiale (z.B. "M.J.") und Problem-Typen werden an Gemini gesendet
- **Keine Speicherung**: Gemini speichert keine Anfragen (laut Google's Datenschutzrichtlinien)
- **Opt-Out**: Einfach API-Key auf `null` setzen

## Beispiel Stories

### Mit AI generiert:
```
🎧 M.J. verliert 5x gegen sein Headset - Zeit für einen Waffenstillstand? 😄
💻 S.C.'s Software scheint ein Eigenleben zu führen... 3x diese Woche!
⌨️ I.G. und die Tastatur: Eine turbulente Beziehung mit 4 Krisen!
```

### Mit Templates:
```
🎧 M.J. hat den Krieg 5x gegen sein Headset verloren diese Woche!
💻 S.C. hat seine Software nicht im Griff, diese Woche sogar 3x!
⌨️ I.G. hat seine Tastatur nicht im Griff - 4x diese Woche!
```

## Deaktivierung

Um Gemini AI zu deaktivieren, setze in `ai_config.dart`:

```dart
static const String? geminiApiKey = null;
```

Die App funktioniert weiterhin normal mit den Template-basierten Stories.

## Troubleshooting

### "API Key ungültig"
- Überprüfe ob der Key korrekt kopiert wurde
- Stelle sicher, dass keine zusätzlichen Leerzeichen vorhanden sind
- Erstelle ggf. einen neuen API-Key

### "Rate Limit erreicht"
- Kostenloses Tier: 60 req/min, 1,500/Tag
- Bei Überschreitung: Templates werden automatisch verwendet
- Oder upgrade auf bezahlten Plan

### "Stories sind nicht kreativ genug"
- Gemini generiert zufällige Varianten
- Bei Bedarf: Prompts in `gemini_ai_service.dart` anpassen
- Mehr Beispiele in den Prompts führen zu besseren Ergebnissen

## Weiterführende Links

- [Gemini API Dokumentation](https://ai.google.dev/docs)
- [API Key Management](https://makersuite.google.com/app/apikey)
- [Pricing](https://ai.google.dev/pricing)
- [Datenschutz](https://ai.google.dev/gemini-api/terms)
