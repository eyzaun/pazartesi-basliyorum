import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/habit.dart';
import '../providers/habits_provider.dart';

/// Screen for editing an existing habit.
class EditHabitScreen extends ConsumerStatefulWidget {
  const EditHabitScreen({required this.habitId, super.key});
  final String habitId;

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = AppConstants.categories.first;
  String _selectedIcon =
      AppConstants.categoryIcons[AppConstants.categories.first]!;
  String _selectedColor = '#6C63FF';
  FrequencyType _frequencyType = FrequencyType.daily;
  final List<String> _selectedDays = [];
  int _customPeriodDays = 2; // X günde 1 kere (X: 1-7)
  HabitStatus _status = HabitStatus.active;

  bool _isInitialized = false;

  final List<String> _colors = [
    '#6C63FF',
    '#FF6B6B',
    '#4ECDC4',
    '#FFD93D',
    '#95E1D3',
    '#F38181',
    '#AA96DA',
    '#FCBAD3',
  ];

  final List<Map<String, String>> _daysOfWeek = [
    {'value': 'mon', 'label': 'Pzt'},
    {'value': 'tue', 'label': 'Sal'},
    {'value': 'wed', 'label': 'Çar'},
    {'value': 'thu', 'label': 'Per'},
    {'value': 'fri', 'label': 'Cum'},
    {'value': 'sat', 'label': 'Cmt'},
    {'value': 'sun', 'label': 'Paz'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm(Habit habit) {
    if (_isInitialized) return;

    _nameController.text = habit.name;
    _descriptionController.text = habit.description ?? '';
    _selectedCategory = habit.category;
    _selectedIcon = habit.icon;
    _selectedColor = habit.color;
    _frequencyType = habit.frequency.type;
    _status = habit.status;

    final config = habit.frequency.config;
    if (_frequencyType == FrequencyType.daily) {
      if (config['specificDays'] != null) {
        _selectedDays.addAll(List<String>.from(config['specificDays']));
      } else if (config['everyDay'] == true) {
        // Eski "her gün" verisini tüm günler olarak yükle
        _selectedDays.addAll(['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']);
      }
    } else if (_frequencyType == FrequencyType.custom) {
      _customPeriodDays = (config['periodDays'] ?? 2).clamp(1, 7);
      // timesInPeriod artık her zaman 1, eski veriyi yok say
    } else if (_frequencyType == FrequencyType.weekly) {
      // Eski haftalık veriyi günlük'e çevir - haftanın tüm günleri
      _frequencyType = FrequencyType.daily;
      _selectedDays.addAll(['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']);
    }

    _isInitialized = true;
  }

  Future<void> _updateHabit(Habit originalHabit) async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> frequencyConfig;
    if (_frequencyType == FrequencyType.daily) {
      frequencyConfig = {'specificDays': _selectedDays};
    } else if (_frequencyType == FrequencyType.custom) {
      frequencyConfig = {
        'periodDays': _customPeriodDays,
        'timesInPeriod': 1, // Her zaman 1
      };
    } else {
      frequencyConfig = {'specificDays': _selectedDays};
    }

    final updatedHabit = originalHabit.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: HabitFrequency(
        type: _frequencyType,
        config: frequencyConfig,
      ),
      status: _status,
      updatedAt: DateTime.now(),
    );

    final success =
        await ref.read(habitActionProvider.notifier).updateHabit(updatedHabit);

    if (success && mounted) {
      context.showSuccessSnackBar('Alışkanlık güncellendi');
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final error = ref.read(habitActionProvider).error;
      context.showErrorSnackBar(error ?? 'Güncelleme başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habitAsync = ref.watch(habitProvider(widget.habitId));
    final actionState = ref.watch(habitActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editHabit),
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return const CustomErrorWidget(
              message: 'Alışkanlık bulunamadı',
            );
          }

          _initializeForm(habit);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durum',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<HabitStatus>(
                          segments: const [
                            ButtonSegment(
                              value: HabitStatus.active,
                              label: Text('Aktif'),
                              icon: Icon(Icons.check_circle, size: 16),
                            ),
                            ButtonSegment(
                              value: HabitStatus.paused,
                              label: Text('Duraklatıldı'),
                              icon: Icon(Icons.pause_circle, size: 16),
                            ),
                            ButtonSegment(
                              value: HabitStatus.archived,
                              label: Text('Arşivlendi'),
                              icon: Icon(Icons.archive, size: 16),
                            ),
                          ],
                          selected: {_status},
                          onSelectionChanged: (Set<HabitStatus> newSelection) {
                            setState(() {
                              _status = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon and Color
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Görünüm',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _getColorFromHex(_selectedColor)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _selectedIcon,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Renk', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _colors.map((color) {
                            final isSelected = color == _selectedColor;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(color),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white, width: 3,)
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: _getColorFromHex(color)
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20,)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.habitName,
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  maxLength: AppConstants.maxHabitNameLength,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alışkanlık adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: AppConstants.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(AppConstants.categoryIcons[category]!),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        _selectedIcon = AppConstants.categoryIcons[value]!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: AppConstants.maxDescriptionLength,
                ),
                const SizedBox(height: 16),

                // Frequency
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.frequency,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<FrequencyType>(
                          segments: const [
                            ButtonSegment(
                              value: FrequencyType.daily,
                              label: Text('Belirli Günler'),
                              icon: Icon(Icons.today, size: 16),
                            ),
                            ButtonSegment(
                              value: FrequencyType.custom,
                              label: Text('X Günde 1'),
                              icon: Icon(Icons.tune, size: 16),
                            ),
                          ],
                          selected: {_frequencyType},
                          onSelectionChanged:
                              (Set<FrequencyType> newSelection) {
                            setState(() {
                              _frequencyType = newSelection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_frequencyType == FrequencyType.daily) ...[
                          Text(
                            'Haftanın Hangi Günleri?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _daysOfWeek.map((day) {
                              final isSelected =
                                  _selectedDays.contains(day['value']);
                              return FilterChip(
                                label: Text(day['label']!),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDays.add(day['value']!);
                                    } else {
                                      _selectedDays.remove(day['value']);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        if (_frequencyType == FrequencyType.custom) ...[
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kaç günde bir tekrarlanacak?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: _customPeriodDays.toDouble(),
                                min: 1,
                                max: 7,
                                divisions: 6,
                                label: '$_customPeriodDays günde 1 kere',
                                onChanged: (value) {
                                  setState(() {
                                    _customPeriodDays = value.toInt();
                                  });
                                },
                              ),
                              Text(
                                '$_customPeriodDays günde 1 kere',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _customPeriodDays == 1
                                        ? 'Her gün 1 kere yapılacak'
                                        : '$_customPeriodDays gün içinde 1 kere yapmanız yeterli',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Update Button
                ElevatedButton(
                  onPressed:
                      actionState.isLoading ? null : () => _updateHabit(habit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorFromHex(_selectedColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: actionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Güncelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }
}
