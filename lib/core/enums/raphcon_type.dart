/// Enumeration for different types of hardware/technical problems
/// Used to categorize what kind of issue a Raphcon represents
/// Following Clean Architecture - Domain layer enum
enum RaphconType {
  mouse('mouse'),
  keyboard('keyboard'),
  microphone('microphone'),
  headset('headset'),
  webcam('webcam'),
  speakers('speakers'),
  network('network'),
  software('software'),
  hardware('hardware'),
  other('other');

  const RaphconType(this.value);

  final String value;

  /// Get localized display name for the enum
  String getDisplayName(dynamic localizations) {
    // Use AppLocalizations for proper i18n support
    switch (this) {
      case RaphconType.mouse:
        return localizations.raphconTypeMouse;
      case RaphconType.keyboard:
        return localizations.raphconTypeKeyboard;
      case RaphconType.microphone:
        return localizations.raphconTypeMicrophone;
      case RaphconType.headset:
        return localizations.raphconTypeHeadset;
      case RaphconType.webcam:
        return localizations.raphconTypeWebcam;
      case RaphconType.speakers:
        return localizations.raphconTypeSpeakers;
      case RaphconType.network:
        return localizations.raphconTypeNetwork;
      case RaphconType.software:
        return localizations.raphconTypeSoftware;
      case RaphconType.hardware:
        return localizations.raphconTypeHardware;
      case RaphconType.other:
        return localizations.raphconTypeOther;
    }
  }

  /// Create RaphconType from string value
  static RaphconType fromString(String value) {
    for (RaphconType type in RaphconType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return RaphconType.other; // Default fallback
  }

  /// Get icon for each type
  String get iconName {
    switch (this) {
      case RaphconType.mouse:
        return 'mouse';
      case RaphconType.keyboard:
        return 'keyboard';
      case RaphconType.microphone:
        return 'mic';
      case RaphconType.headset:
        return 'headset';
      case RaphconType.webcam:
        return 'videocam';
      case RaphconType.speakers:
        return 'volume_up';
      case RaphconType.network:
        return 'wifi_off';
      case RaphconType.software:
        return 'computer';
      case RaphconType.hardware:
        return 'hardware';
      case RaphconType.other:
        return 'help_outline';
    }
  }
}
