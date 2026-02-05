import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/dream_entry.dart';
import '../theme/app_theme.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Dreams provider
final dreamsProvider = FutureProvider<List<DreamEntry>>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return storageService.getDreams();
});

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Dreams for selected date provider
final selectedDayDreamsProvider = FutureProvider<List<DreamEntry>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final storageService = ref.read(storageServiceProvider);
  return storageService.getDreamsByDate(selectedDate);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  late final ValueNotifier<List<DreamEntry>> _selectedDayDreams;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedDayDreams = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedDayDreams.dispose();
    super.dispose();
  }

  List<DreamEntry> _getEventsForDay(DateTime day) {
    final dreams = ref.read(dreamsProvider).value ?? [];
    final targetDate = DateTime(day.year, day.month, day.day);
    return dreams.where((dream) {
      final dreamDate = DateTime(dream.date.year, dream.date.month, dream.date.day);
      return dreamDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        ref.read(selectedDateProvider.notifier).state = selectedDay;
      });
      _selectedDayDreams.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dreamsAsync = ref.watch(dreamsProvider);

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
                expandedHeight: 100,
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
                        Icons.settings_rounded,
                        color: isDark
                            ? const Color(0xFFE6E6FA)
                            : const Color(0xFF4A4A6A),
                      ),
                    ),
                    onPressed: () => context.push('/settings'),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '몽실',
                    style: theme.textTheme.displaySmall?.copyWith(
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
                    const SizedBox(height: 8),

                    // Calendar Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF252540).withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFE6E6FA))
                                .withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: dreamsAsync.when(
                        data: (dreams) {
                          final eventLoader = (day) => _getEventsForDay(day);
                          return TableCalendar<DreamEntry>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            calendarFormat: _calendarFormat,
                            eventLoader: eventLoader,
                            startingDayOfWeek: StartingDayOfWeek.sunday,
                            onDaySelected: _onDaySelected,
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },

                            // Calendar styling
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              weekendTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF707090)
                                    : const Color(0xFFAAAAAA),
                              ),
                              holidayTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF707090)
                                    : const Color(0xFFAAAAAA),
                              ),

                              // Today
                              todayDecoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF9A8FB0)
                                        : const Color(0xFFE6E6FA))
                                    .withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              todayTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF9A8FB0)
                                    : const Color(0xFF4A4A6A),
                                fontWeight: FontWeight.bold,
                              ),

                              // Selected day
                              selectedDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF9A8FB0),
                                          const Color(0xFFB4A8C8),
                                        ]
                                      : [
                                          const Color(0xFFE6E6FA),
                                          const Color(0xFFB4D8F8),
                                        ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? const Color(0xFF9A8FB0)
                                            : const Color(0xFFE6E6FA))
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),

                              // Default days
                              defaultTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE6E6FA)
                                    : const Color(0xFF4A4A6A),
                              ),

                              // Marker
                              markerDecoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFFB4D8F8)
                                    : const Color(0xFF9A8FB0),
                                shape: BoxShape.circle,
                              ),
                              markersMaxCount: 3,
                              markerSizeScale: 0.2,
                              canMarkersOverflow: true,
                            ),

                            // Header styling
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonShowsNext: false,
                              formatButtonDecoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF9A8FB0)
                                        : const Color(0xFFE6E6FA))
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              formatButtonTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF9A8FB0)
                                    : const Color(0xFF4A4A6A),
                                fontSize: 14,
                              ),
                              titleTextStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE6E6FA)
                                    : const Color(0xFF4A4A6A),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: isDark
                                    ? const Color(0xFF9A8FB0)
                                    : const Color(0xFF4A4A6A),
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: isDark
                                    ? const Color(0xFF9A8FB0)
                                    : const Color(0xFF4A4A6A),
                              ),
                            ),

                            // Days of week styling
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF707090)
                                    : const Color(0xFFAAAAAA),
                                fontSize: 13,
                              ),
                              weekdayStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFFD0D0F0)
                                    : const Color(0xFF5A5A7A),
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              '꿈을 불러오는 중 오류가 발생했어요',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? const Color(0xFF707090)
                                        : const Color(0xFFAAAAAA),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selected date header
                    if (_selectedDay != null)
                      Row(
                        children: [
                          Text(
                            DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                            style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFE6E6FA)
                                      : const Color(0xFF4A4A6A),
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '의 꿈',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF707090)
                                      : const Color(0xFFAAAAAA),
                                ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Dream cards for selected date
                    ValueListenableBuilder<List<DreamEntry>>(
                      valueListenable: _selectedDayDreams,
                      builder: (context, dreams, _) {
                        if (dreams.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFF252540)
                                      : Colors.white)
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (isDark
                                        ? const Color(0xFF3A3A50)
                                        : const Color(0xFFE0E0E0))
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bedtime_rounded,
                                  size: 48,
                                  color: isDark
                                      ? const Color(0xFF707090)
                                      : const Color(0xFFAAAAAA).withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '이 날의 꿈이 없어요',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isDark
                                            ? const Color(0xFF707090)
                                            : const Color(0xFFAAAAAA),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '꿈을 기록해보세요 ✨',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? const Color(0xFF707090)
                                            : const Color(0xFFAAAAAA),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: dreams.map((dream) {
                            return _buildDreamCard(context, dream, isDark);
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Space for FAB
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/input'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('꿈 기록'),
        backgroundColor: isDark
            ? const Color(0xFF9A8FB0)
            : const Color(0xFFE6E6FA),
        foregroundColor: isDark
            ? Colors.white
            : const Color(0xFF4A4A6A),
      ),
    );
  }

  Widget _buildDreamCard(BuildContext context, DreamEntry dream, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDreamDetail(context, dream, isDark),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood emoji
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF9A8FB0)
                            : const Color(0xFFE6E6FA))
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dream.mood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                // Dream content preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFFB4D8F8)
                                      : const Color(0xFF9A8FB0))
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dream.mood.label,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFB4D8F8)
                                    : const Color(0xFF9A8FB0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFFF8B4D9)
                                      : const Color(0xFFF8B4D9))
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '행운: ${dream.luckyItem}',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF8B4D9)
                                    : const Color(0xFFF8B4D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dream.content.length > 60
                            ? '${dream.content.substring(0, 60)}...'
                            : dream.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? const Color(0xFFD0D0F0)
                                  : const Color(0xFF5A5A7A),
                              height: 1.5,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF707090)
                      : const Color(0xFFAAAAAA),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDreamDetail(BuildContext context, DreamEntry dream, bool isDark) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF9A8FB0)
                          : const Color(0xFFE6E6FA))
                      .withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFF9A8FB0)
                                : const Color(0xFFE6E6FA))
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dream.mood.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy년 MM월 dd일').format(dream.date),
                            style: theme.textTheme.titleMedium?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFE6E6FA)
                                      : const Color(0xFF4A4A6A),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            dream.mood.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF707090)
                                      : const Color(0xFFAAAAAA),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? const Color(0xFF707090)
                            : const Color(0xFFAAAAAA),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dream content
                      Text(
                        '꿈 내용',
                        style: theme.textTheme.titleSmall?.copyWith(
                              color: isDark
                                  ? const Color(0xFFE6E6FA)
                                  : const Color(0xFF4A4A6A),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252540)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          dream.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFFD0D0F0)
                                    : const Color(0xFF5A5A7A),
                                height: 1.6,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Interpretation
                      Text(
                        '꿈 해몽',
                        style: theme.textTheme.titleSmall?.copyWith(
                              color: isDark
                                  ? const Color(0xFFE6E6FA)
                                  : const Color(0xFF4A4A6A),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252540)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          dream.interpretation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFFD0D0F0)
                                    : const Color(0xFF5A5A7A),
                                height: 1.6,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Lucky item
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: isDark ? Colors.white : const Color(0xFF4A4A6A),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '오늘의 행운: ${dream.luckyItem}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white : const Color(0xFF4A4A6A),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement delete functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('삭제 기능은 곧 추가될 예정이에요'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('삭제'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF707090)
                              : const Color(0xFFAAAAAA),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF3A3A50)
                                : const Color(0xFFE0E0E0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('닫기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF9A8FB0)
                              : const Color(0xFFE6E6FA),
                          foregroundColor: isDark
                              ? Colors.white
                              : const Color(0xFF4A4A6A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
