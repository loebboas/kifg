import 'package:flutter/material.dart';

class UserLevelProgressBar extends StatelessWidget {
  final int points;

  const UserLevelProgressBar({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final level = points ~/ 500;
    final progressToNext = (points % 500) / 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Text('Level $level', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progressToNext,
            minHeight: 8,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
