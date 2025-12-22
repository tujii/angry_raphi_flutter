# Raphcon Type Migration Guide

## Overview

The Raphcon types have been reduced from 10 types to 5 core categories to simplify the user experience and make problem reporting more intuitive.

## New Types

The following 5 types are now available:

1. **Headset** (`headset`) - Headset and audio issues
2. **Webcam** (`webcam`) - Webcam and video issues
3. **Andere Peripheriegeräte** (`otherPeripherals`) - Other peripheral devices
4. **Mouse Highlighter** (`mouseHighlighter`) - Mouse highlighter issues
5. **Zu spät zum Meeting** (`lateMeeting`) - Late to meeting

## Backward Compatibility

### Old Types Mapping

The system automatically maps old types from the database to the new types:

| Old Type | Maps To |
|----------|---------|
| `mouse` | `otherPeripherals` |
| `keyboard` | `otherPeripherals` |
| `speakers` | `otherPeripherals` |
| `network` | `otherPeripherals` |
| `software` | `otherPeripherals` |
| `hardware` | `otherPeripherals` |
| `other` | `otherPeripherals` |
| `microphone` | `headset` |

### Implementation

The backward compatibility is implemented in the `RaphconType.fromString()` method in `/lib/core/enums/raphcon_type.dart`:

```dart
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
```

This ensures that:
- All old Raphcon records in the database will continue to work
- Old type values are automatically converted to the appropriate new type
- No data migration is required
- No errors occur when reading legacy data

## Changes Made

### Core Files
- `lib/core/enums/raphcon_type.dart` - Updated enum with new types and backward compatibility
- `lib/features/raphcon_management/domain/entities/raphcon_entity.dart` - Updated default type
- `lib/features/raphcon_management/data/models/raphcon_model.dart` - Updated default type

### Localization
- `lib/l10n/app_de.arb` - German translations for new types
- `lib/l10n/app_en.arb` - English translations for new types

### UI Components
- `lib/shared/widgets/raphcon_type_selection_dialog.dart` - Updated icon mapping
- `lib/shared/widgets/raphcon_detail_bottom_sheet.dart` - Updated icon mapping
- `lib/shared/widgets/streaming_raphcon_detail_bottom_sheet.dart` - Updated icon mapping
- `lib/shared/widgets/raphcon_statistics_bottom_sheet.dart` - Updated icon mapping

### Services
- `lib/services/story_of_the_day_service.dart` - Updated story templates for new types
- `lib/features/raphcon_management/presentation/bloc/raphcon_bloc.dart` - Updated default type
- `lib/features/raphcon_management/domain/repositories/raphcons_repository.dart` - Updated default type

### Tests
- `test/core/enums/raphcon_type_test.dart` - Updated with new types and backward compatibility tests
- `test/features/raphcon_management/domain/entities/raphcon_entity_test.dart` - Updated to use new types
- `test/features/raphcon_management/data/models/raphcon_model_test.dart` - Updated with backward compatibility tests

## Testing

The backward compatibility has been tested with:
- Unit tests for the `fromString()` method
- Tests to verify old type values map correctly to new types
- Tests to ensure default values use the new types

## User Impact

- Users will see only 5 simplified type options when creating new Raphcons
- Existing Raphcons with old types will continue to display correctly
- No manual data migration required
- The UI will show appropriate icons for all types

## Technical Notes

- The old enum values have been removed from the codebase
- The `fromString()` method provides the only interface between old and new types
- New Raphcons created will only use the 5 new types
- The default type for all new Raphcons is `otherPeripherals`
