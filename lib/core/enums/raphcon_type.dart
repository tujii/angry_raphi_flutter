/// Enumeration for different types of hardware/technical problems
/// Used to categorize what kind of issue a Raphcon represents
/// Following Clean Architecture - Domain layer enum
/// 
/// Types have been reduced to core categories:
/// - headset: Headset issues
/// - webcam: Webcam issues  
/// - otherPeripherals: Other peripheral devices (mouse, keyboard, speakers, etc.)
/// - mouseHighlighter: Mouse highlighter issues
/// - lateMeeting: Late to meeting
enum RaphconType {
  headset('headset'),
  webcam('webcam'),
  otherPeripherals('otherPeripherals'),
  mouseHighlighter('mouseHighlighter'),
  lateMeeting('lateMeeting');

  const RaphconType(this.value);

  final String value;

  /// Get localized display name for the enum
  String getDisplayName(dynamic localizations) {
    // Use AppLocalizations for proper i18n support
    switch (this) {
      case RaphconType.headset:
        return localizations.raphconTypeHeadset;
      case RaphconType.webcam:
        return localizations.raphconTypeWebcam;
      case RaphconType.otherPeripherals:
        return localizations.raphconTypeOtherPeripherals;
      case RaphconType.mouseHighlighter:
        return localizations.raphconTypeMouseHighlighter;
      case RaphconType.lateMeeting:
        return localizations.raphconTypeLateMeeting;
    }
  }

  /// Create RaphconType from string value
  /// Provides backward compatibility by mapping old types to new types:
  /// - mouse, keyboard, speakers -> otherPeripherals
  /// - microphone -> headset
  /// - network, software, hardware, other -> otherPeripherals
  static RaphconType fromString(String value) {
    // Direct matches for new types
    for (RaphconType type in RaphconType.values) {
      if (type.value == value) {
        return type;
      }
    }
    
    // Backward compatibility mapping for old types
    switch (value) {
      case 'mouse':
      case 'keyboard':
      case 'speakers':
      case 'network':
      case 'software':
      case 'hardware':
      case 'other':
        return RaphconType.otherPeripherals;
      case 'microphone':
        return RaphconType.headset;
      default:
        return RaphconType.otherPeripherals; // Default fallback
    }
  }

  /// Get icon for each type
  String get iconName {
    switch (this) {
      case RaphconType.headset:
        return 'headset';
      case RaphconType.webcam:
        return 'videocam';
      case RaphconType.otherPeripherals:
        return 'devices';
      case RaphconType.mouseHighlighter:
        return 'highlight_mouse_cursor';
      case RaphconType.lateMeeting:
        return 'schedule';
    }
  }
}
