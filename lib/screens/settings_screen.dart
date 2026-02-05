import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

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
              // App Bar
              SliverAppBar(
                floating: true,
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
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '설정',
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

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // Theme Settings
                    _buildSectionHeader(
                      context,
                      '테마',
                      Icons.palette_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252540) : Colors.white,
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
                      child: Column(
                        children: [
                          _buildThemeOption(
                            context,
                            ref,
                            '시스템 설정 따르기',
                            Icons.brightness_auto_rounded,
                            ThemeMode.system,
                            themeMode,
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: isDark
                                ? const Color(0xFF3A3A50)
                                : const Color(0xFFE0E0E0),
                          ),
                          _buildThemeOption(
                            context,
                            ref,
                            '라이트 모드',
                            Icons.light_mode_rounded,
                            ThemeMode.light,
                            themeMode,
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: isDark
                                ? const Color(0xFF3A3A50)
                                : const Color(0xFFE0E0E0),
                          ),
                          _buildThemeOption(
                            context,
                            ref,
                            '다크 모드',
                            Icons.dark_mode_rounded,
                            ThemeMode.dark,
                            themeMode,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Data Management
                    _buildSectionHeader(
                      context,
                      '데이터 관리',
                      Icons.folder_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252540) : Colors.white,
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
                      child: _buildDangerOption(
                        context,
                        '모든 꿈 일기 삭제',
                        Icons.delete_forever_rounded,
                        () => _showDeleteConfirmation(context, ref),
                        isDark,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Info
                    _buildSectionHeader(
                      context,
                      '앱 정보',
                      Icons.info_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252540) : Colors.white,
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
                      child: Column(
                        children: [
                          _buildInfoOption(
                            context,
                            '버전',
                            'v1.0.0',
                            Icons.tag_rounded,
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: isDark
                                ? const Color(0xFF3A3A50)
                                : const Color(0xFFE0E0E0),
                          ),
                          _buildInfoOption(
                            context,
                            '만든이',
                            'OpenClaw',
                            Icons.person_rounded,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.bedtime_rounded,
                            size: 32,
                            color: isDark
                                ? const Color(0xFF707090)
                                : const Color(0xFFAAAAAA).withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '몽실 - MongSil',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF707090)
                                      : const Color(0xFFAAAAAA),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '꿈을 기록하고 의미를 찾아보세요',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF707090)
                                      : const Color(0xFFAAAAAA),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark
                    ? const Color(0xFF9A8FB0)
                    : const Color(0xFFE6E6FA))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF9A8FB0) : const Color(0xFF4A4A6A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE6E6FA) : const Color(0xFF4A4A6A),
              ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isSelected = mode == currentMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSelected
                          ? (isDark ? const Color(0xFF9A8FB0) : const Color(0xFFE6E6FA))
                          : (isDark ? const Color(0xFF3A3A50) : const Color(0xFFF0F0FF)))
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF4A4A6A))
                      : (isDark ? const Color(0xFF707090) : const Color(0xFFAAAAAA)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? (isDark ? const Color(0xFFE6E6FA) : const Color(0xFF4A4A6A))
                            : (isDark ? const Color(0xFFC0C0E0) : const Color(0xFF6A6A8A)),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: isDark ? const Color(0xFF9A8FB0) : const Color(0xFFE6E6FA),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8B4D9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 20,
                  color: Color(0xFFF8B4D9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFF8B4D9),
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFF8B4D9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOption(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark
                      ? const Color(0xFF9A8FB0)
                      : const Color(0xFFE6E6FA))
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF9A8FB0) : const Color(0xFF4A4A6A),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? const Color(0xFFC0C0E0) : const Color(0xFF6A6A8A),
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? const Color(0xFFE6E6FA) : const Color(0xFF4A4A6A),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: const Color(0xFFF8B4D9).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF8B4D9),
              ),
            ),
            const SizedBox(width: 12),
            const Text('정말 삭제하시겠어요?'),
          ],
        ),
        content: Text(
          '모든 꿈 일기가 영구적으로 삭제되며,\n복구할 수 없어요.',
          style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFFC0C0E0) : const Color(0xFF6A6A8A),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? const Color(0xFF707090) : const Color(0xFFAAAAAA),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllDreams(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8B4D9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllDreams(BuildContext context) async {
    try {
      final storageService = StorageService();
      await storageService.clearAllDreams();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 꿈 일기를 삭제했어요'),
            backgroundColor: Color(0xFFB4D8F8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했어요: $e'),
            backgroundColor: const Color(0xFFF8B4D9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
