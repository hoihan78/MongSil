import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum DreamMood {
  happy('😊', '행복'),
  anxious('😰', '불안'),
  sad('😢', '슬픔'),
  excited('🤩', '신남'),
  peaceful('😌', '평화');

  final String emoji;
  final String label;

  const DreamMood(this.emoji, this.label);
}

class DreamInputState {
  final String content;
  final DateTime date;
  final DreamMood? selectedMood;

  DreamInputState({
    this.content = '',
    DateTime? date,
    this.selectedMood,
  }) : date = date ?? DateTime.now();

  DreamInputState copyWith({
    String? content,
    DateTime? date,
    DreamMood? selectedMood,
  }) {
    return DreamInputState(
      content: content ?? this.content,
      date: date ?? this.date,
      selectedMood: selectedMood ?? this.selectedMood,
    );
  }
}

class DreamInputNotifier extends StateNotifier<DreamInputState> {
  DreamInputNotifier() : super(DreamInputState());

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateMood(DreamMood mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void reset() {
    state = DreamInputState();
  }

  String get formattedDate => DateFormat('yyyy년 MM월 dd일').format(state.date);
}

final dreamInputProvider =
    StateNotifierProvider<DreamInputNotifier, DreamInputState>((ref) {
  return DreamInputNotifier();
});
