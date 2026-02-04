import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/dream_input_provider.dart';
import '../theme/app_theme.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.watch(dreamInputProvider).date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFE6E6FA),
                  onPrimary: const Color(0xFF4A4A6A),
                  surface: Colors.white,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A6A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(dreamInputProvider.notifier).updateDate(picked);
    }
  }

  void _submitDream() {
    final state = ref.read(dreamInputProvider);
    if (state.content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('꿈 내용을 입력해주세요 💭'),
          backgroundColor: Color(0xFFF8B4D9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // TODO: Navigate to interpretation/drawing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('꿈 해몽을 시작합니다... ✨'),
        backgroundColor: Color(0xFFB4D8F8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dreamInputProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Text(
                '오늘 꾼 꿈은 어땠나요?',
                style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      color: isDark
                          ? const Color(0xFFE6E6FA)
                          : const Color(0xFF4A4A6A),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '꾸신 꿈을 기록하고 의미를 찾아보세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFFC0C0E0)
                          : const Color(0xFF6A6A8A),
                    ),
              ),
              const SizedBox(height: 32),

              // Date Picker
              Card(
                elevation: 2,
                color: isDark ? const Color(0xFF252540) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E6FA).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: isDark
                                ? const Color(0xFFE6E6FA)
                                : const Color(0xFF4A4A6A),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '날짜',
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? const Color(0xFFC0C0E0)
                                          : const Color(0xFF6A6A8A),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy년 MM월 dd일').format(state.date),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? const Color(0xFFC0C0E0)
                              : const Color(0xFF6A6A8A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mood Selector
              Text(
                '기분 선택',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE6E6FA)
                          : const Color(0xFF4A4A6A),
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: DreamMood.values.map((mood) {
                  final isSelected = state.selectedMood == mood;
                  return InkWell(
                    onTap: () {
                      ref.read(dreamInputProvider.notifier).updateMood(mood);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFF9A8FB0)
                                : const Color(0xFFE6E6FA))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF9A8FB0)
                                  : const Color(0xFFE6E6FA))
                              : (isDark
                                  ? const Color(0xFF252540)
                                  : const Color(0xFFE0E0E0)),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE6E6FA)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: isSelected
                                      ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF4A4A6A))
                                      : (isDark
                                          ? const Color(0xFFC0C0E0)
                                          : const Color(0xFF6A6A8A)),
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Dream Content Input
              Text(
                '꿈 내용',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE6E6FA)
                          : const Color(0xFF4A4A6A),
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF252540),
                            const Color(0xFF1A1A2E),
                          ]
                        : [
                            const Color(0xFFF0F0FF).withOpacity(0.5),
                            const Color(0xFFE6E6FA).withOpacity(0.3),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3A50)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _contentController,
                  onChanged: (value) {
                    ref.read(dreamInputProvider.notifier).updateContent(value);
                  },
                  maxLines: 10,
                  minLines: 6,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '꿈 내용을 자유롭게 적어주세요...\n어떤 장소에서 누구와 있었나요?\n느낌이나 감정도 함께 적어주시면 좋아요 ✨',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFF707090)
                              : const Color(0xFFAAAAAA),
                        ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(24),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      // Bottom Action Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E).withOpacity(0.0),
                    const Color(0xFF1A1A2E).withOpacity(0.95),
                  ]
                : [
                    const Color(0xFFFFFAFA).withOpacity(0.0),
                    const Color(0xFFFFFAFA).withOpacity(0.95),
                  ],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _submitDream,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                '꿈 해몽하고 그림 그리기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF9A8FB0)
                    : const Color(0xFFE6E6FA),
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF4A4A6A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFE6E6FA).withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
