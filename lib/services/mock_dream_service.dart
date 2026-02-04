import 'dart:async';
import 'dart:math';

class DreamAnalysisResult {
  final String imageUrl;
  final String interpretation;
  final String luckyItem;

  DreamAnalysisResult({
    required this.imageUrl,
    required this.interpretation,
    required this.luckyItem,
  });

  factory DreamAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DreamAnalysisResult(
      imageUrl: json['imageUrl'] as String,
      interpretation: json['interpretation'] as String,
      luckyItem: json['luckyItem'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'interpretation': interpretation,
      'luckyItem': luckyItem,
    };
  }
}

class MockDreamService {
  final Random _random = Random();

  // Sample interpretations for variety
  final List<String> _interpretations = [
    "당신의 꿈은 내면의 평화를 의미합니다. 오늘은 뜻밖의 행운이 찾아올 수 있어요!",
    "이 꿈은 새로운 시작과 기회를 알려줍니다. 두려움 없이 앞으로 나아가세요!",
    "꿈속에서 느꼈던 감정이 현재의 심리 상태를 반영하고 있어요. 스스로에게 더 다정하게 대하세요.",
    "당신의 잠재력이 꿈을 통해 표현되었습니다. 오늘 도전할 일이 생길 거예요!",
    "이 꿈은 인간관계의 조화를 의미합니다. 주변 사람들에게 감사를 표현해보세요.",
    "꿈속의 상징이 당신의 창의력을 나타냅니다. 오늘 무언가 새로운 것을 시도해보세요!",
  ];

  // Sample lucky items
  final List<String> _luckyItems = [
    "파란색 머그컵",
    "은색 열쇠고리",
    "연두색 양말",
    "보라색 펜",
    "하얀색 책갈피",
    "분홍색 포스트잇",
    "노란색 쿠키",
    "주황색 가방",
  ];

  /// Analyze dream content and return mock result
  /// Simulates AI processing with 2 second delay
  Future<DreamAnalysisResult> analyzeDream(String content) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate random seed for unique image
    final seed = _random.nextInt(10000);
    final imageUrl = 'https://picsum.photos/seed/$seed/512/512';

    // Pick random interpretation and lucky item
    final interpretation = _interpretations[_random.nextInt(_interpretations.length)];
    final luckyItem = _luckyItems[_random.nextInt(_luckyItems.length)];

    return DreamAnalysisResult(
      imageUrl: imageUrl,
      interpretation: interpretation,
      luckyItem: luckyItem,
    );
  }
}
