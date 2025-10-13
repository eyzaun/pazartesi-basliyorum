import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/habit.dart';
import '../providers/habits_provider.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/habit_card.dart';

/// Today screen showing user's daily habits.
/// This is the main screen where users check in their habits.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    // Trigger sync when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitActionProvider.notifier).syncWithFirebase();
    });
  }
  
  Future<void> _refreshHabits() async {
    // Refresh habits from repository
    final user = await ref.read(currentUserProvider.future);
    if (user != null) {
      ref
        ..invalidate(habitsProvider(user.id))
        ..invalidate(todayLogsProvider(user.id));
    }
    
    // Sync with Firebase
    await ref.read(habitActionProvider.notifier).syncWithFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
        actions: [
          // Sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _refreshHabits,
            tooltip: 'Senkronize et',
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.profile);
            },
            tooltip: l10n.profile,
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            // Guest mode or not logged in
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Misafir modundasınız',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
                    },
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            );
          }
          
          return _buildHabitsList(user.id);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: _refreshHabits,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed(AppRouter.habitCreate);
          if (result == true && mounted) {
            // Refresh habits after creating new one
            unawaited(_refreshHabits());
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.createHabit),
      ),
    );
  }
  
  Widget _buildHabitsList(String userId) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider(userId));
    final todayLogsAsync = ref.watch(todayLogsProvider(userId));
    
    return RefreshIndicator(
      onRefresh: _refreshHabits,
      child: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: l10n.noHabitsYet,
              message: l10n.createYourFirstHabit,
              actionLabel: l10n.createHabit,
              onAction: () async {
                final result = await Navigator.of(context).pushNamed(AppRouter.habitCreate);
                if (result == true && mounted) {
                  unawaited(_refreshHabits());
                }
              },
            );
          }
          
          return todayLogsAsync.when(
            data: (logs) {
              // Separate completed and pending habits
              final pending = habits.where((habit) {
                final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                return log == null || !log.completed;
              }).toList();
              
              final completed = habits.where((habit) {
                final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                return log != null && log.completed;
              }).toList();
              
              // Group pending habits by time section
              final morningHabits = <Habit>[];
              final afternoonHabits = <Habit>[];
              final eveningHabits = <Habit>[];
              final allDayHabits = <Habit>[];
              
              for (final habit in pending) {
                final section = _getTimeSection(habit);
                switch (section) {
                  case 'Sabah':
                    morningHabits.add(habit);
                    break;
                  case 'Öğleden Sonra':
                    afternoonHabits.add(habit);
                    break;
                  case 'Akşam':
                    eveningHabits.add(habit);
                    break;
                  case 'Gün Boyu':
                    allDayHabits.add(habit);
                    break;
                }
              }
              
              // Calculate current streak (placeholder - will be calculated from logs)
              final currentStreak = 0;
              
              return CustomScrollView(
                slivers: [
                  // Date Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateTime.now().toFormattedDate(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DailyProgressCard(
                            completedCount: completed.length,
                            totalCount: habits.length,
                            currentStreak: currentStreak,
                            onTap: () {
                              // Navigate to statistics screen
                              Navigator.of(context).pushNamed(AppRouter.statistics);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Morning section
                  if (morningHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '🌅 Sabah',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = morningHabits[index];
                            final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: () => _completeHabit(habit.id, userId),
                                onSkip: () => _skipHabit(habit.id, userId),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                              ),
                            );
                          },
                          childCount: morningHabits.length,
                        ),
                      ),
                    ),
                  ],
                  
                  // Afternoon section
                  if (afternoonHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '☀️ Öğleden Sonra',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = afternoonHabits[index];
                            final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: () => _completeHabit(habit.id, userId),
                                onSkip: () => _skipHabit(habit.id, userId),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                              ),
                            );
                          },
                          childCount: afternoonHabits.length,
                        ),
                      ),
                    ),
                  ],
                  
                  // Evening section
                  if (eveningHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '🌙 Akşam',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = eveningHabits[index];
                            final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: () => _completeHabit(habit.id, userId),
                                onSkip: () => _skipHabit(habit.id, userId),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                              ),
                            );
                          },
                          childCount: eveningHabits.length,
                        ),
                      ),
                    ),
                  ],
                  
                  // All day section
                  if (allDayHabits.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          '📅 Gün Boyu',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = allDayHabits[index];
                            final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                log: log,
                                onComplete: () => _completeHabit(habit.id, userId),
                                onSkip: () => _skipHabit(habit.id, userId),
                                onTap: () => _navigateToDetail(habit.id),
                                onEdit: () => _editHabit(habit.id),
                                onDelete: () => _deleteHabit(habit.id, userId),
                              ),
                            );
                          },
                          childCount: allDayHabits.length,
                        ),
                      ),
                    ),
                  ],
                  
                  // Completed section (collapsible)
                  if (completed.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showCompleted = !_showCompleted;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              Icon(
                                _showCompleted ? Icons.expand_less : Icons.expand_more,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '✅ Tamamlananlar (${completed.length})',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_showCompleted)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = completed[index];
                              final log = logs.where((l) => l.habitId == habit.id).firstOrNull;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  habit: habit,
                                  log: log,
                                  onComplete: () => _completeHabit(habit.id, userId),
                                  onSkip: () => _skipHabit(habit.id, userId),
                                  onTap: () => _navigateToDetail(habit.id),
                                  onEdit: () => _editHabit(habit.id),
                                  onDelete: () => _deleteHabit(habit.id, userId),
                                ),
                              );
                            },
                            childCount: completed.length,
                          ),
                        ),
                      ),
                  ],
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: Text('Hata: $error'),
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: CustomErrorWidget(
            message: error.toString(),
            onRetry: _refreshHabits,
          ),
        ),
      ),
    );
  }
  
  String _getTimeSection(Habit habit) {
    // For now, we'll use category or name to determine time section
    // In the future, this could be based on a reminderTime field
    final name = habit.name.toLowerCase();
    final category = habit.category.toLowerCase();
    
    // Check for morning keywords
    if (name.contains('sabah') || 
        name.contains('morning') || 
        category.contains('sabah') ||
        name.contains('kahvaltı') ||
        name.contains('uyanmak')) {
      return 'Sabah';
    }
    
    // Check for evening keywords
    if (name.contains('akşam') || 
        name.contains('gece') || 
        name.contains('evening') || 
        name.contains('night') ||
        category.contains('akşam') ||
        name.contains('uyumak')) {
      return 'Akşam';
    }
    
    // Check for afternoon keywords
    if (name.contains('öğlen') || 
        name.contains('afternoon') || 
        category.contains('öğleden')) {
      return 'Öğleden Sonra';
    }
    
    // Default to all day
    return 'Gün Boyu';
  }
  
  Future<void> _completeHabit(String habitId, String userId) async {
    final success = await ref.read(habitActionProvider.notifier).completeHabit(
          habitId: habitId,
          userId: userId,
        );
    
    if (success && mounted) {
      unawaited(_refreshHabits());
      context.showSuccessSnackBar('Tamamlandı! 🎉');
    }
  }
  
  Future<void> _skipHabit(String habitId, String userId) async {
    final reason = await _showSkipReasonDialog();
    if (reason == null) return;
    
    final success = await ref.read(habitActionProvider.notifier).skipHabit(
          habitId: habitId,
          userId: userId,
          skipReason: reason,
        );
    
    if (success && mounted) {
      unawaited(_refreshHabits());
      context.showSnackBar('Atlandı');
    }
  }
  
  Future<String?> _showSkipReasonDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atlama Nedeni'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Meşguldüm'),
                onTap: () => Navigator.of(context).pop('Meşguldüm'),
              ),
              ListTile(
                title: const Text('Hasta'),
                onTap: () => Navigator.of(context).pop('Hasta'),
              ),
              ListTile(
                title: const Text('Unutdum'),
                onTap: () => Navigator.of(context).pop('Unutdum'),
              ),
              ListTile(
                title: const Text('Planlı dinlenme'),
                onTap: () => Navigator.of(context).pop('Planlı dinlenme'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _navigateToDetail(String habitId) {
    Navigator.of(context).pushNamed(
      AppRouter.habitDetail,
      arguments: habitId,
    );
  }
  
  void _editHabit(String habitId) {
    Navigator.of(context).pushNamed(
      AppRouter.habitEdit,
      arguments: habitId,
    ).then((result) {
      if (result == true && mounted) {
        unawaited(_refreshHabits());
      }
    });
  }
  
  Future<void> _deleteHabit(String habitId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alışkanlığı Sil'),
        content: const Text('Bu alışkanlığı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final repository = ref.read(habitRepositoryProvider);
      final result = await repository.deleteHabit(habitId);
      
      if (result.isSuccess && mounted) {
        unawaited(_refreshHabits());
        context.showSuccessSnackBar('Alışkanlık silindi');
      } else if (result.isFailure && mounted) {
        context.showErrorSnackBar(result.errorOrNull ?? 'Silme başarısız');
      }
    }
  }
}
