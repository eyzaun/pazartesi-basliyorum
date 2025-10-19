import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/habit.dart';
import '../providers/habits_provider.dart';

/// Screen for creating a new habit with multi-step form.
class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  final _uuid = const Uuid();

  int _currentStep = 0;

  // Step 1: Basic Info
  String _selectedCategory = AppConstants.categories.first;
  String _selectedIcon =
      AppConstants.categoryIcons[AppConstants.categories.first]!;
  String _selectedColor = '#6C63FF';

  // Step 2: Frequency
  FrequencyType _frequencyType = FrequencyType.daily;
  final List<String> _selectedDays = [];
  // Custom frequency (X günde 1 kere, X: 1-7)
  int _customPeriodDays = 2;      // X günde 1 kere

  // Step 3: Goals & Reminders
  TimeOfDay? _reminderTime;
  String _goalValue = '1';
  String _goalUnit = 'kez';
  
  // Part 4: Timer fields
  bool _isTimedHabit = false;
  int _targetDurationMinutes = 20;

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
    _goalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createHabit),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(theme),

          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep1BasicInfo(theme, l10n),
                _buildStep2Frequency(theme, l10n),
                _buildStep3GoalsReminders(theme, l10n),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStepIndicator(0, '1', 'Temel Bilgiler', theme),
          Expanded(child: _buildStepConnector(0, theme)),
          _buildStepIndicator(1, '2', 'Sıklık', theme),
          Expanded(child: _buildStepConnector(1, theme)),
          _buildStepIndicator(2, '3', 'Hedefler', theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
      int step, String number, String label, ThemeData theme,) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? theme.colorScheme.primary
                : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step, ThemeData theme) {
    final isCompleted = step < _currentStep;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? theme.colorScheme.primary : Colors.grey[300],
    );
  }

  // ============================================================================
  // STEP 1: Basic Info
  // ============================================================================

  Widget _buildStep1BasicInfo(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alışkanlık Bilgileri',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alışkanlığınız için bir isim ve kategori seçin',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.habitName,
                hintText: 'Örn: Spor yap, Kitap oku',
                prefixIcon: const Icon(Icons.edit_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen alışkanlık ismi girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Açıklama (İsteğe bağlı)',
                hintText: 'Alışkanlık hakkında notlar...',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Selection
            Text(
              'Kategori',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.categories.map((category) {
                final isSelected = category == _selectedCategory;
                final icon = AppConstants.categoryIcons[category]!;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _selectedIcon = icon;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'Renk',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _hexToColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 2: Frequency
  // ============================================================================

  Widget _buildStep2Frequency(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sıklık Ayarları',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alışkanlığınızı ne sıklıkla yapmak istiyorsunuz?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Frequency Type Selection
          _buildFrequencyOption(
            theme,
            FrequencyType.daily,
            Icons.calendar_today,
            'Haftanın Belirli Günleri',
            'Seçtiğiniz günlerde tekrarla',
          ),
          const SizedBox(height: 12),
          _buildFrequencyOption(
            theme,
            FrequencyType.custom,
            Icons.tune,
            'Özel Sıklık',
            'X günde 1 kere (X: 1-7)',
          ),
          const SizedBox(height: 24),

          // Daily Options
          if (_frequencyType == FrequencyType.daily) ...[
            Text(
              'Haftanın Hangi Günleri?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day['value']);

                return FilterChip(
                  selected: isSelected,
                  label: Text(day['label']!),
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

          // Custom Frequency Options
          if (_frequencyType == FrequencyType.custom) ...[
            Text(
              'Kaç günde bir tekrarlanacak?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Her X günde 1 kere',
                        style: theme.textTheme.bodyMedium,
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
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_customPeriodDays günde 1',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _customPeriodDays == 1
                  ? 'Her gün 1 kere yapılacak'
                  : '$_customPeriodDays gün içinde 1 kere yapmanız yeterli',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(
    ThemeData theme,
    FrequencyType type,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _frequencyType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _frequencyType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 3: Goals & Reminders
  // ============================================================================

  Widget _buildStep3GoalsReminders(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hedefler & Hatırlatıcılar',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hedeflerinizi belirleyin ve hatırlatıcı kurun',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Daily Goal
          Text(
            'Günlük Hedef',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: _goalValue,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Miktar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _goalValue = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _goalUnit,
                  decoration: InputDecoration(
                    labelText: 'Birim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['kez', 'dakika', 'saat', 'sayfa', 'km']
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _goalUnit = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reminder Time
          Text(
            'Hatırlatıcı',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(Icons.notifications_outlined,
                color: theme.colorScheme.primary,),
            title: Text(
              _reminderTime == null
                  ? 'Hatırlatıcı kur'
                  : 'Hatırlatıcı: ${_reminderTime!.format(context)}',
            ),
            trailing: _reminderTime != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _reminderTime = null;
                      });
                    },
                  )
                : null,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _reminderTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _reminderTime = time;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Part 4: Timer Option
          Text(
            'Zamanlayıcı',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isTimedHabit,
            onChanged: (value) {
              setState(() {
                _isTimedHabit = value;
              });
            },
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Zamanlayıcılı Alışkanlık'),
            subtitle: const Text('Süre takibi yap (meditasyon, egzersiz, vb.)'),
            secondary: Icon(
              Icons.timer,
              color: theme.colorScheme.primary,
            ),
          ),
          
          // Duration selector (if timer enabled)
          if (_isTimedHabit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hedef Süre',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$_targetDurationMinutes',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Text('dakika'),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _targetDurationMinutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          label: '$_targetDurationMinutes dk',
                          onChanged: (value) {
                            setState(() {
                              _targetDurationMinutes = value.toInt();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [5, 10, 15, 20, 30, 45, 60]
                        .map(
                          (minutes) => ChoiceChip(
                            label: Text('$minutes dk'),
                            selected: _targetDurationMinutes == minutes,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _targetDurationMinutes = minutes;
                                });
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Tips Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'İpucu: Hatırlatıcı kurmak, alışkanlık oluşturma sürecini %40 daha etkili hale getirir.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Navigation
  // ============================================================================

  Widget _buildNavigationButtons(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Geri'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < 2 ? _nextStep : _createHabit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_currentStep < 2 ? 'İleri' : 'Oluştur'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep == 1) {
      if (_frequencyType == FrequencyType.daily && _selectedDays.isEmpty) {
        context.showErrorSnackBar('Lütfen en az bir gün seçin');
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createHabit() async {
    // Get current user
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (mounted) {
        context.showErrorSnackBar('Kullanıcı bilgisi alınamadı');
      }
      return;
    }

    // Prepare frequency config
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

    // Create new habit
    final newHabit = Habit(
      id: _uuid.v4(),
      userId: user.id,
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Timer configuration
      isTimedHabit: _isTimedHabit,
      targetDurationMinutes: _isTimedHabit ? _targetDurationMinutes : null,
    );

    final success =
        await ref.read(habitActionProvider.notifier).createHabit(newHabit);

    if (success && mounted) {
      context.showSuccessSnackBar('Alışkanlık oluşturuldu! 🎉');
      Navigator.of(context).pop(true);
    } else if (mounted) {
      context.showErrorSnackBar('Alışkanlık oluşturulamadı');
    }
  }

  Color _hexToColor(String hex) {
    try {
      final hexColor = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.purple;
    }
  }
}
