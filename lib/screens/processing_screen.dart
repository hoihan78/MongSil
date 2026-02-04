import 'package:flutter/material.dart';
import 'dart:async';
import '../services/mock_dream_service.dart';
import '../theme/app_theme.dart';

class ProcessingScreen extends StatefulWidget {
  final String dreamContent;

  const ProcessingScreen({
    super.key,
    required this.dreamContent,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  final List<String> _loadingMessages = [
    "꿈 조각을 모으는 중...",
    "AI가 그림을 그리고 있어요...",
    "별들의 의미를 해석 중...",
    "꿈의 색을 섞고 있어요...",
    "잠시만 기다려주세요 ✨",
    "거의 완성되어가요...",
    "마법의 붓질 중...",
  ];

  final MockDreamService _mockDreamService = MockDreamService();

  @override
  void initState() {
    super.initState();

    // Pulse animation for glowing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for the loading spinner
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Start changing messages
    _messageTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });

    // Start dream analysis
    _analyzeDream();
  }

  Future<void> _analyzeDream() async {
    try {
      final result = await _mockDreamService.analyzeDream(widget.dreamContent);

      if (mounted) {
        _messageTimer?.cancel();
        _pulseController.dispose();
        _rotateController.dispose();

        // Navigate to result screen
        context.push('/result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        _messageTimer?.cancel();
        _pulseController.dispose();
        _rotateController.dispose();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('분석 중 오류가 발생했습니다: $e'),
            backgroundColor: const Color(0xFFF8B4D9),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF252540),
                    const Color(0xFF1A1A2E),
                  ]
                : [
                    const Color(0xFFFFFAFA),
                    const Color(0xFFF0F0FF),
                    const Color(0xFFE6E6FA),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '꿈을 해석하고 있어요',
                    style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          color: isDark
                              ? const Color(0xFFE6E6FA)
                              : const Color(0xFF4A4A6A),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                // Animated Moon/Spinner
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseAnimation.value,
                      child: Transform.scale(
                        scale: 0.8 + (_pulseAnimation.value * 0.2),
                        child: AnimatedBuilder(
                          animation: _rotateAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value * 2 * 3.14159,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? [
                                            const Color(0xFF9A8FB0),
                                            const Color(0xFFE6E6FA),
                                          ]
                                        : [
                                            const Color(0xFFE6E6FA),
                                            const Color(0xFFF8B4D9),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark
                                              ? const Color(0xFF9A8FB0)
                                              : const Color(0xFFE6E6FA))
                                          .withOpacity(0.4 * _pulseAnimation.value),
                                      blurRadius: 40 * _pulseAnimation.value,
                                      spreadRadius: 10 * _pulseAnimation.value,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.nights_stay_rounded,
                                    size: 80,
                                    color: isDark
                                        ? const Color(0xFF1A1A2E)
                                        : const Color(0xFF4A4A6A),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Loading message with fade animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(_currentMessageIndex),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _loadingMessages[_currentMessageIndex],
                      key: ValueKey(_currentMessageIndex),
                      style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: isDark
                                ? const Color(0xFFC0C0E0)
                                : const Color(0xFF6A6A8A),
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                // Small progress indicator at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(
                    backgroundColor: (isDark
                            ? const Color(0xFF252540)
                            : const Color(0xFFE0E0E0))
                        .withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? const Color(0xFF9A8FB0) : const Color(0xFFE6E6FA),
                    ),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
