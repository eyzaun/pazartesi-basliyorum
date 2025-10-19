// Helper utilities for presenting habit metadata in the social module.
//
// The social feature needs lightweight, human-readable strings that describe
// schedules, categories or targets without pulling in the full habit domain
// layer. These helpers operate on raw maps coming from Firestore to avoid
// tight coupling with the main habit entities.

const _weekdayLabelsTr = <String, String>{
  'monday': 'Pzt',
  'tuesday': 'Sal',
  'wednesday': 'Çar',
  'thursday': 'Per',
  'friday': 'Cum',
  'saturday': 'Cmt',
  'sunday': 'Paz',
};

/// Returns a short text that explains the provided frequency definition.
///
/// The [frequencyData] map is expected to contain the standard habit schema
/// with `type` and `config` keys. When the map is not available the function
/// returns `null` so that callers can simply skip rendering the information.
String? buildFrequencyLabel(Map<String, dynamic>? frequencyData) {
  if (frequencyData == null || frequencyData.isEmpty) {
    return null;
  }

  final String? type = frequencyData['type'] as String?;
  final Map<String, dynamic>? config =
      frequencyData['config'] as Map<String, dynamic>?;

  switch (type) {
    case 'daily':
      if (config == null) {
        return 'Her gün';
      }
      if (config['everyDay'] == true) {
        return 'Her gün';
      }
      final specificDays = (config['specificDays'] as List?)
          ?.cast<String>()
          .where((day) => _weekdayLabelsTr.containsKey(day))
          .toList();
      if (specificDays != null && specificDays.isNotEmpty) {
        final display = specificDays.map((day) => _weekdayLabelsTr[day] ?? day).join(', ');
        return 'Belirli günler ($display)';
      }
      return 'Günlük';

    case 'weekly':
      final timesPerWeek = config?['timesPerWeek'] as int? ?? 1;
      return 'Haftada $timesPerWeek kez';

    case 'custom':
      final periodDays = config?['periodDays'] as int? ?? 2;
      final timesInPeriod = config?['timesInPeriod'] as int? ?? 1;
      if (timesInPeriod == 1) {
        return periodDays == 1 ? 'Her gün' : '$periodDays günde 1 kere';
      }
      return '$periodDays günde $timesInPeriod tekrar';

    case 'monthly':
      return 'Aylık plan';

    case 'flexible':
      final target = config?['targetCompletions'] as int?;
      if (target != null) {
        final days = config?['targetDays'] as int? ?? 7;
        return 'Esnek hedef: $days günde $target';
      }
      return 'Esnek hedef';

    default:
      return 'Özel plan';
  }
}

/// Builds a short goal description based on habit metadata.
///
/// Currently the function focuses on timed habits. Additional goal types can
/// be added here without touching UI code.
String? buildGoalLabel(Map<String, dynamic> habitData) {
  if (habitData['isTimedHabit'] == true) {
    final minutes = habitData['targetDurationMinutes'] as int?;
    if (minutes != null && minutes > 0) {
      return 'Hedef süre: $minutes dk';
    }
  }

  final customGoal = habitData['goalDescription'] as String?;
  if (customGoal != null && customGoal.trim().isNotEmpty) {
    return customGoal;
  }

  return null;
}

/// Formats habit category identifiers (e.g. `health_care`) into a readable
/// Turkish title.
String formatCategoryLabel(String category) {
  final cleaned = category.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  if (cleaned.isEmpty) return category;
  final words = cleaned.split(' ');
  return words
      .map((word) {
        if (word.isEmpty) return word;
        final lower = word.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}