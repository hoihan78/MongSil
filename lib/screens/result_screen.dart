import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/mock_dream_service.dart';
import '../services/storage_service.dart';
import '../providers/dream_input_provider.dart';
import '../models/dream_entry.dart';
import '../theme/app_theme.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)!.settings.arguments as DreamAnalysisResult;
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
                  ]
                : [
                    const Color(0xFFFFFAFA),
                    const Color(0xFFF0F0FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar with transparent background
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? const Color(0xFF252540)
                              : Colors.white)
                          .withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark
                          ? const Color(0xFFE6E6FA)
                          : const Color(0xFF4A4A6A),
                    ),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFF252540)
                                : Colors.white)
                            .withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      icon: Icon(
                        Icons.share_rounded,
                        color: isDark
                            ? const Color(0xFFE6E6FA)
                            : const Color(0xFF4A4A6A),
                      ),
                    ),
                    onPressed: () {
                      _showShareDialog(context, result, isDark);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '꿈 해몽 결과',
                    style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFE6E6FA)
                              : const Color(0xFF4A4A6A),
                        ),
                  ),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                ),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),

                    // Dream Image - Art gallery style
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFE6E6FA))
                                .withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Image
                            GestureDetector(
                              onTap: () => _showFullImage(context, result.imageUrl),
                              child: Hero(
                                tag: 'dreamImage',
                                child: Image.network(
                                  result.imageUrl,
                                  width: double.infinity,
                                  height: 400,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 400,
                                      color: isDark
                                          ? const Color(0xFF252540)
                                          : const Color(0xFFE0E0E0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: isDark
                                              ? const Color(0xFF9A8FB0)
                                              : const Color(0xFFE6E6FA),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 400,
                                      color: isDark
                                          ? const Color(0xFF252540)
                                          : const Color(0xFFE0E0E0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image_rounded,
                                              size: 64,
                                              color: isDark
                                                  ? const Color(0xFF707090)
                                                  : const Color(0xFFAAAAAA),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '이미지를 불러올 수 없어요',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Gallery frame overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: (isDark
                                            ? const Color(0xFFE6E6FA)
                                            : Colors.white)
                                        .withOpacity(0.3),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                            // Tap hint
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.fullscreen_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '확대',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Lucky Item Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF9A8FB0),
                                  const Color(0xFFE6E6FA),
                                ]
                              : [
                                  const Color(0xFFF8B4D9),
                                  const Color(0xFFE6E6FA),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF9A8FB0)
                                    : const Color(0xFFF8B4D9))
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '오늘의 행운 아이템',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.luckyItem,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Interpretation Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF252540)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFE0E0E0))
                                .withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? const Color(0xFF9A8FB0)
                                            : const Color(0xFFE6E6FA))
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: isDark
                                        ? const Color(0xFF9A8FB0)
                                        : const Color(0xFF4A4A6A),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '꿈 해몽',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? const Color(0xFFE6E6FA)
                                            : const Color(0xFF4A4A6A),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              height: 200,
                              child: SingleChildScrollView(
                                child: Text(
                                  result.interpretation,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                        height: 1.8,
                                        color: isDark
                                            ? const Color(0xFFD0D0F0)
                                            : const Color(0xFF5A5A7A),
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Action Buttons
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              // Save Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveDream(context, result, isDark),
                  icon: const Icon(Icons.bookmark_border_rounded),
                  label: const Text('저장'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF252540)
                        : Colors.white,
                    foregroundColor: isDark
                        ? const Color(0xFFE6E6FA)
                        : const Color(0xFF4A4A6A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF3A3A50)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Redraw Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _redrawDream(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 그리기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF9A8FB0)
                        : const Color(0xFFE6E6FA),
                    foregroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF4A4A6A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFE6E6FA).withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Share Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showShareDialog(context, result, isDark),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('공유'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF252540)
                        : Colors.white,
                    foregroundColor: isDark
                        ? const Color(0xFFE6E6FA)
                        : const Color(0xFF4A4A6A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF3A3A50)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: Center(
              child: Hero(
                tag: 'dreamImage',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _saveDream(BuildContext context, DreamAnalysisResult result, bool isDark) async {
    final inputState = ref.read(dreamInputProvider);
    
    // Create a DreamEntry
    final entry = DreamEntry(
      id: _uuid.v4(),
      date: inputState.date,
      content: inputState.content,
      mood: inputState.selectedMood ?? DreamMood.peaceful,
      imageUrl: result.imageUrl,
      interpretation: result.interpretation,
      luckyItem: result.luckyItem,
    );

    // Save to local storage
    final storageService = StorageService();
    await storageService.saveDream(entry);

    // Reset input state
    ref.read(dreamInputProvider.notifier).reset();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('꿈을 저장했어요 💾'),
          backgroundColor: const Color(0xFFB4D8F8),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to home after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.go('/');
      }
    }
  }

  void _redrawDream(BuildContext context) {
    context.pop();
  }

  void _showShareDialog(BuildContext context, DreamAnalysisResult result, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6FA).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.share_rounded,
                color: isDark ? const Color(0xFF9A8FB0) : const Color(0xFF4A4A6A),
              ),
            ),
            const SizedBox(width: 12),
            const Text('공유하기'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShareOption(
              context,
              Icons.copy_rounded,
              '해몽 내용 복사',
              () {
                Clipboard.setData(ClipboardData(text: result.interpretation));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('해몽 내용을 복사했어요'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              isDark,
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              context,
              Icons.image_rounded,
              '이미지 공유',
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이미지를 공유하려면 스크린샷을 찍어주세요'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252540) : const Color(0xFFF0F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? const Color(0xFF9A8FB0) : const Color(0xFF4A4A6A),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? const Color(0xFFE6E6FA) : const Color(0xFF4A4A6A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF707090) : const Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }
}
