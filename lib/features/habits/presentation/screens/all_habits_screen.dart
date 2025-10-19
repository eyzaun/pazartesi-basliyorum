import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/habit.dart' as domain;
import '../providers/habits_provider.dart';

/// Sorting options for the All Habits screen.
enum HabitSortOption {
  nameAsc,
  createdDesc,
}

class AllHabitsScreen extends ConsumerStatefulWidget {
  const AllHabitsScreen({super.key});

  @override
  ConsumerState<AllHabitsScreen> createState() => _AllHabitsScreenState();
}

class _AllHabitsScreenState extends ConsumerState<AllHabitsScreen> {
  HabitSortOption _sortOption = HabitSortOption.createdDesc;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.habits),
        actions: [
          PopupMenuButton<HabitSortOption>(
            initialValue: _sortOption,
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: HabitSortOption.nameAsc,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Ada göre (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HabitSortOption.createdDesc,
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Oluşturulma (Yeni-Eski)'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.sort),
            tooltip: 'Sıralama',
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildMessage(context, 'Lütfen giriş yapın.');
          }

          final habitsAsync = ref.watch(habitsProvider(user.id));
          return habitsAsync.when(
            data: (habits) => _buildHabitList(context, habits),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildMessage(
              context,
              'Alışkanlıklar yüklenemedi: $error',
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _buildMessage(context, 'Oturum bilgisi alınamadı: $error'),
      ),
    );
  }

  Widget _buildHabitList(BuildContext context, List<domain.Habit> habits) {
    if (habits.isEmpty) {
      return _buildMessage(context, 'Henüz bir alışkanlık eklemediniz.');
    }

    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final categories = habits
        .map((habit) => habit.category)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final filteredHabits = habits.where((habit) {
      if (_selectedCategory == null) return true;
      return habit.category == _selectedCategory;
    }).toList();

    filteredHabits.sort((a, b) {
      switch (_sortOption) {
        case HabitSortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case HabitSortOption.createdDesc:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Tümü'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              for (final category in categories) ...[
                ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: filteredHabits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final habit = filteredHabits[index];
              final scoreAsync = habit.frequency.type == domain.FrequencyType.custom
                  ? ref.watch(habitScoreProvider(habit.id))
                  : null;
              final color = _colorFromHex(habit.color, theme.colorScheme);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: color,
                    ),
                  ),
                  title: Text(
                    habit.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Kategori: ${habit.category}'),
                          if (scoreAsync != null)
                            scoreAsync.maybeWhen(
                              data: (score) {
                                if (score == null || score.maxScore == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Row(
                                  children: [
                                    Text(
                                      ' • ',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Icon(
                                      Icons.auto_graph,
                                      size: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${score.percentage}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oluşturma: ${DateFormat.yMMMd(locale).format(habit.createdAt)}',
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.habitDetail,
                      arguments: habit.id,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _colorFromHex(String hexColor, ColorScheme scheme) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return scheme.primary;
    }
  }
}
