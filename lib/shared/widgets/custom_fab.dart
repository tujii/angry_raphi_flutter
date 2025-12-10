import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const CustomFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
