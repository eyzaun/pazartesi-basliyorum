import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

/// Widget for selecting habit frequency.
class FrequencySelector extends StatefulWidget {
  const FrequencySelector({
    required this.initialType,
    required this.initialConfig,
    required this.onChanged,
    super.key,
  });
  final FrequencyType initialType;
  final Map<String, dynamic> initialConfig;
  final void Function(FrequencyType type, Map<String, dynamic> config)
      onChanged;

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  late FrequencyType _type;
  late bool _everyDay;
  late List<String> _selectedDays;
  late int _timesPerWeek;
  late int _minPerWeek;
  late int _targetPerWeek;

  final List<Map<String, String>> _daysOfWeek = [
    {'value': 'mon', 'label': 'Pzt', 'fullName': 'Pazartesi'},
    {'value': 'tue', 'label': 'Sal', 'fullName': 'Salı'},
    {'value': 'wed', 'label': 'Çar', 'fullName': 'Çarşamba'},
    {'value': 'thu', 'label': 'Per', 'fullName': 'Perşembe'},
    {'value': 'fri', 'label': 'Cum', 'fullName': 'Cuma'},
    {'value': 'sat', 'label': 'Cmt', 'fullName': 'Cumartesi'},
    {'value': 'sun', 'label': 'Paz', 'fullName': 'Pazar'},
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _everyDay = widget.initialConfig['everyDay'] == true;
    _selectedDays =
        List<String>.from(widget.initialConfig['specificDays'] ?? []);
    _timesPerWeek = widget.initialConfig['timesPerWeek'] ?? 3;
    _minPerWeek = widget.initialConfig['minPerWeek'] ?? 2;
    _targetPerWeek = widget.initialConfig['targetPerWeek'] ?? 5;
  }

  void _notifyChange() {
    Map<String, dynamic> config;

    switch (_type) {
      case FrequencyType.daily:
        config =
            _everyDay ? {'everyDay': true} : {'specificDays': _selectedDays};
        break;
      case FrequencyType.weekly:
        config = {'timesPerWeek': _timesPerWeek};
        break;
      case FrequencyType.monthly:
        config = {'timesPerMonth': _timesPerWeek};
        break;
      case FrequencyType.flexible:
        config = {
          'minPerWeek': _minPerWeek,
          'targetPerWeek': _targetPerWeek,
        };
        break;
    }

    widget.onChanged(_type, config);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sıklık',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Frequency type selector
            SegmentedButton<FrequencyType>(
              segments: const [
                ButtonSegment(
                  value: FrequencyType.daily,
                  label: Text('Günlük'),
                  icon: Icon(Icons.today, size: 16),
                ),
                ButtonSegment(
                  value: FrequencyType.weekly,
                  label: Text('Haftalık'),
                  icon: Icon(Icons.calendar_view_week, size: 16),
                ),
                ButtonSegment(
                  value: FrequencyType.flexible,
                  label: Text('Esnek'),
                  icon: Icon(Icons.tune, size: 16),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<FrequencyType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _notifyChange();
                });
              },
            ),
            const SizedBox(height: 20),

            // Configuration options based on type
            if (_type == FrequencyType.daily) ..._buildDailyOptions(),
            if (_type == FrequencyType.weekly) ..._buildWeeklyOptions(),
            if (_type == FrequencyType.flexible) ..._buildFlexibleOptions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDailyOptions() {
    return [
      SwitchListTile(
        title: const Text('Her gün'),
        subtitle: const Text('Haftalık 7 gün'),
        value: _everyDay,
        onChanged: (value) {
          setState(() {
            _everyDay = value;
            if (value) {
              _selectedDays.clear();
            }
            _notifyChange();
          });
        },
        contentPadding: EdgeInsets.zero,
      ),
      if (!_everyDay) ...[
        const SizedBox(height: 12),
        Text(
          'Belirli günler seçin:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _daysOfWeek.map((day) {
            final isSelected = _selectedDays.contains(day['value']);
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
                  _notifyChange();
                });
              },
              showCheckmark: true,
            );
          }).toList(),
        ),
        if (_selectedDays.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Seçilen günler: ${_selectedDays.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    ];
  }

  List<Widget> _buildWeeklyOptions() {
    return [
      Text(
        'Haftada kaç kez: $_timesPerWeek',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Slider(
        value: _timesPerWeek.toDouble(),
        min: 1,
        max: 7,
        divisions: 6,
        label: '$_timesPerWeek kez',
        onChanged: (value) {
          setState(() {
            _timesPerWeek = value.toInt();
            _notifyChange();
          });
        },
      ),
      Text(
        'Haftalık hedef: Haftada $_timesPerWeek gün yapmanız gerekiyor',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
      ),
    ];
  }

  List<Widget> _buildFlexibleOptions() {
    return [
      Text(
        'Minimum: $_minPerWeek, Hedef: $_targetPerWeek',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minimum', style: Theme.of(context).textTheme.bodySmall),
                Slider(
                  value: _minPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_minPerWeek',
                  onChanged: (value) {
                    setState(() {
                      _minPerWeek = value.toInt();
                      if (_minPerWeek > _targetPerWeek) {
                        _targetPerWeek = _minPerWeek;
                      }
                      _notifyChange();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hedef', style: Theme.of(context).textTheme.bodySmall),
                Slider(
                  value: _targetPerWeek.toDouble(),
                  min: _minPerWeek.toDouble(),
                  max: 7,
                  divisions: 7 - _minPerWeek,
                  label: '$_targetPerWeek',
                  onChanged: (value) {
                    setState(() {
                      _targetPerWeek = value.toInt();
                      _notifyChange();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Haftada en az $_minPerWeek, hedef $_targetPerWeek gün',
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
