import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/time_override.dart';
import '../habits/presentation/providers/habits_provider.dart';
import '../auth/presentation/providers/auth_provider.dart';

/// Debug menu for testing features
/// Only available in debug mode
class DebugMenuScreen extends ConsumerStatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  ConsumerState<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends ConsumerState<DebugMenuScreen> {
  late DateTime _selectedDate;
  final _dateFormat = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR');

  @override
  void initState() {
    super.initState();
    _selectedDate = TimeOverride.overrideDate ?? DateTime.now();
  }

  void _updateDate() {
    setState(() {
      TimeOverride.setEnabled(true);
      TimeOverride.setOverride(_selectedDate);
    });
    
    // Invalidate providers to refresh UI with new date
    _invalidateProviders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarih değiştirildi: ${_dateFormat.format(_selectedDate)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearOverride() {
    setState(() {
      TimeOverride.setEnabled(false);
      TimeOverride.clearOverride();
      _selectedDate = DateTime.now();
    });
    
    // Invalidate providers to refresh UI with real date
    _invalidateProviders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarih sıfırlandı (gerçek zamana dönüldü)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addDays(int days) {
    setState(() {
      TimeOverride.setEnabled(true);
      _selectedDate = _selectedDate.add(Duration(days: days));
      TimeOverride.setOverride(_selectedDate);
    });
    
    // Invalidate providers to refresh UI with new date
    _invalidateProviders();
  }
  
  Future<void> _invalidateProviders() async {
    // Increment date refresh counter to force rebuild of all date-dependent providers
    ref.read(dateRefreshProvider.notifier).state++;
    
    // Also invalidate user-specific providers
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user != null) {
        // Invalidate all date-dependent providers
        ref.invalidate(habitsProvider(user.id));
        ref.invalidate(todayLogsProvider(user.id));
      }
    } catch (e) {
      // User might not be logged in, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverrideActive = TimeOverride.isOverrideActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Debug Menüsü'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu menü sadece test amaçlıdır. Prod build\'de görünmez.',
                    style: TextStyle(color: Colors.orange[900]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Debug Mode Toggle
          Card(
            child: SwitchListTile(
              title: const Text('Debug Modu Aktif'),
              subtitle: Text(
                TimeOverride.isEnabled
                    ? 'Test tarihi kullanılıyor'
                    : 'Gerçek tarih kullanılıyor',
              ),
              value: TimeOverride.isEnabled,
              onChanged: (value) {
                setState(() {
                  TimeOverride.setEnabled(value);
                  if (!value) {
                    // Disabled olduğunda tarihi de sıfırla
                    _selectedDate = DateTime.now();
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Debug modu aktif - Test tarihi kullanılacak'
                          : 'Debug modu pasif - Gerçek tarih kullanılacak',
                    ),
                    backgroundColor: value ? Colors.orange : Colors.blue,
                  ),
                );
              },
              secondary: Icon(
                TimeOverride.isEnabled ? Icons.bug_report : Icons.bug_report_outlined,
                color: TimeOverride.isEnabled ? Colors.orange : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Current Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mevcut Durum',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Gerçek Tarih',
                    _dateFormat.format(DateTime.now()),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildStatusRow(
                    'Test Tarihi',
                    isOverrideActive
                        ? _dateFormat.format(_selectedDate)
                        : 'Aktif değil',
                    Icons.bug_report,
                    isOverrideActive ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hızlı İşlemler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickButton(
                        'Yarına Geç',
                        Icons.arrow_forward,
                        Colors.green,
                        () => _addDays(1),
                      ),
                      _buildQuickButton(
                        '+3 Gün',
                        Icons.fast_forward,
                        Colors.teal,
                        () => _addDays(3),
                      ),
                      _buildQuickButton(
                        '+7 Gün',
                        Icons.skip_next,
                        Colors.blue,
                        () => _addDays(7),
                      ),
                      _buildQuickButton(
                        'Dün\'e Dön',
                        Icons.arrow_back,
                        Colors.orange,
                        () => _addDays(-1),
                      ),
                      _buildQuickButton(
                        'Sıfırla',
                        Icons.restart_alt,
                        Colors.red,
                        _clearOverride,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Picker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manuel Tarih Seçimi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(_dateFormat.format(_selectedDate)),
                    subtitle: const Text('Tarihi değiştirmek için tıklayın'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('tr', 'TR'),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _updateDate,
                      icon: const Icon(Icons.check),
                      label: const Text('Tarihi Uygula'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Scenarios
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Senaryoları',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildScenarioTile(
                    'Streak Test',
                    'Seri kırılmasını test et',
                    Icons.local_fire_department,
                    Colors.orange,
                    () {
                      setState(() {
                        _selectedDate = DateTime.now().add(const Duration(days: 2));
                        TimeOverride.setOverride(_selectedDate);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('2 gün ileri alındı - Seri kırılmış olmalı'),
                        ),
                      );
                    },
                  ),
                  _buildScenarioTile(
                    'Haftalık Test',
                    '1 hafta sonrasına git',
                    Icons.calendar_view_week,
                    Colors.purple,
                    () {
                      setState(() {
                        _selectedDate = DateTime.now().add(const Duration(days: 7));
                        TimeOverride.setOverride(_selectedDate);
                      });
                    },
                  ),
                  _buildScenarioTile(
                    'Aylık Test',
                    '1 ay sonrasına git',
                    Icons.calendar_view_month,
                    Colors.blue,
                    () {
                      setState(() {
                        _selectedDate = DateTime.now().add(const Duration(days: 30));
                        TimeOverride.setOverride(_selectedDate);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildScenarioTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.play_arrow),
      onTap: onTap,
    );
  }
}
