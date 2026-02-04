import '../providers/dream_input_provider.dart';

class DreamEntry {
  final String id;
  final DateTime date;
  final String content;
  final DreamMood mood;
  final String imageUrl;
  final String interpretation;
  final String luckyItem;

  DreamEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
    required this.imageUrl,
    required this.interpretation,
    required this.luckyItem,
  });

  // Convert DreamEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood.name,
      'imageUrl': imageUrl,
      'interpretation': interpretation,
      'luckyItem': luckyItem,
    };
  }

  // Create DreamEntry from JSON
  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String,
      mood: DreamMood.values.firstWhere(
        (mood) => mood.name == json['mood'] as String,
        orElse: () => DreamMood.peaceful,
      ),
      imageUrl: json['imageUrl'] as String,
      interpretation: json['interpretation'] as String,
      luckyItem: json['luckyItem'] as String,
    );
  }

  // Create a copy with updated fields
  DreamEntry copyWith({
    String? id,
    DateTime? date,
    String? content,
    DreamMood? mood,
    String? imageUrl,
    String? interpretation,
    String? luckyItem,
  }) {
    return DreamEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imageUrl: imageUrl ?? this.imageUrl,
      interpretation: interpretation ?? this.interpretation,
      luckyItem: luckyItem ?? this.luckyItem,
    );
  }
}
