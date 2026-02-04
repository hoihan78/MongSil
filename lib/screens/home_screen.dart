import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '몽실',
              style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '꿈을 기록하고 해몽해보세요 ✨',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.push('/input'),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('꿈 기록하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/input'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('꿈 기록'),
        backgroundColor: const Color(0xFFE6E6FA),
        foregroundColor: const Color(0xFF4A4A6A),
      ),
    );
  }
}
