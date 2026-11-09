// Model representing a Fanar AI model option.

class AiModel {
  final String id;
  final String displayName;
  final String? description;

  const AiModel({
    required this.id,
    required this.displayName,
    this.description,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) => AiModel(
    id: json['id'] as String? ?? '',
    displayName: json['id'] as String? ?? '',
    description: null,
  );

  // Default models shipped with the app — used before the API responds.
  static List<AiModel> get defaults => const [
    AiModel(id: 'Fanar', displayName: 'Fanar'),
    AiModel(
      id: 'Fanar-S-1-7B',
      displayName: 'Fanar S 7B',
      description: 'Smaller, faster model',
    ),
    AiModel(
      id: 'Fanar-C-1-8.7B',
      displayName: 'Fanar C 8.7B',
    ),
    AiModel(
      id: 'Fanar-C-2-27B',
      displayName: 'Fanar C 27B',
      description: 'Most capable',
    ),
    AiModel(id: 'Fanar-Sadiq', displayName: 'Fanar Sadiq'),
    AiModel(
      id: 'Fanar-Sadiq-Agentic',
      displayName: 'Fanar Sadiq Agentic',
      description: 'Agentic tasks',
    ),
  ];
}
