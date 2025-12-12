import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';

class MarkdownContentWidget extends StatelessWidget {
  final String content;

  const MarkdownContentWidget({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _buildMarkdownContent(context, content);
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    if (content.isEmpty) {
      return Text(
        AppLocalizations.of(context)?.subtitle ?? 'Bewerte Personen mit Raphcons',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      );
    }

    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Headers
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(3),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ));
      }
      // Bold text (like **Performance & Loading**)
      else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line.substring(2, line.length - 2),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ));
      }
      // List items
      else if (line.startsWith('- ')) {
        // Extract emoji and text
        String listItem = line.substring(2);
        String emoji = '';
        String text = listItem;
        
        // Check if line starts with emoji
        if (listItem.length > 2 && _isEmoji(listItem.substring(0, 2))) {
          emoji = listItem.substring(0, 2);
          text = listItem.substring(2).trim();
        }
        
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emoji.isNotEmpty) ...[
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
              ] else
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
      // Regular text
      else if (!line.startsWith('#')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _isEmoji(String text) {
    // Simple emoji detection - check for common emoji ranges
    if (text.isEmpty) return false;
    final codeUnit = text.codeUnitAt(0);
    return (codeUnit >= 0x1F300 && codeUnit <= 0x1F9FF) || // Misc symbols
           (codeUnit >= 0x2600 && codeUnit <= 0x26FF) ||   // Misc symbols
           (codeUnit >= 0x2700 && codeUnit <= 0x27BF);     // Dingbats
  }
}