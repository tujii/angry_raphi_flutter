import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class StoryOfTheDayBanner extends StatefulWidget {
  final List<String> stories;

  const StoryOfTheDayBanner({
    super.key,
    required this.stories,
  });

  @override
  State<StoryOfTheDayBanner> createState() => _StoryOfTheDayBannerState();
}

class _StoryOfTheDayBannerState extends State<StoryOfTheDayBanner> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void didUpdateWidget(StoryOfTheDayBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stories != widget.stories) {
      _startRotation();
    }
  }

  void _startRotation() {
    _timer?.cancel();
    if (widget.stories.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.stories.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withValues(alpha: 0.15),
            AppConstants.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '📖 Story of the Week',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              widget.stories.isNotEmpty
                  ? widget.stories[_currentIndex]
                  : 'Keine Stories verfügbar',
              key: ValueKey(_currentIndex),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (widget.stories.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.stories.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? AppConstants.primaryColor
                          : AppConstants.primaryColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
