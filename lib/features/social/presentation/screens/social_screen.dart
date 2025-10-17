import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/habit_activity_repository_impl.dart';
import '../../domain/entities/friend.dart';
import '../../utils/habit_summary.dart';
import '../providers/social_providers.dart';
import '../widgets/activity_card.dart';
import '../widgets/add_friend_dialog.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/friend_request_card.dart';
import '../widgets/shared_habit_card.dart';

/// Social screen for friends and shared habits.
class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Lütfen giriş yapın')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sosyal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Akış', icon: Icon(Icons.feed)),
            Tab(text: 'Bağlantılar', icon: Icon(Icons.people)),
            Tab(text: 'Paylaşımlar', icon: Icon(Icons.share)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityFeedTab(currentUser.id),
          _buildConnectionsTab(currentUser.id),
          _buildSharedTab(currentUser.id),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _showAddFriendDialog(context),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildActivityFeedTab(String currentUserId) {
    final activitiesAsync = ref.watch(activityFeedProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feed_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz aktivite yok',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arkadaşlarınız alışkanlık tamamladığında\nburada göreceksiniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activityFeedProvider);
          },
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ActivityCard(
                activity: activity,
                currentUserId: currentUserId,
                onTap: () => _showActivityDetails(activity),
                onDelete: activity.userId == currentUserId
                    ? () => _deleteActivity(activity.id)
                    : null,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(activityFeedProvider),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsTab(String currentUserId) {
    final friendsAsync = ref.watch(friendsProvider);
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return friendsAsync.when(
      data: (friends) {
        return requestsAsync.when(
          data: (requests) => _buildConnectionsContent(
            currentUserId: currentUserId,
            friends: friends,
            requests: requests,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Hata: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildConnectionsContent({
    required String currentUserId,
    required List<Friend> friends,
    required List<Friend> requests,
  }) {
    final theme = Theme.of(context);
    final hasFriends = friends.isNotEmpty;
    final hasRequests = requests.isNotEmpty;

    if (!hasFriends && !hasRequests) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz bağlantınız yok',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Arkadaş eklemek için + butonuna tıklayın',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[];

    if (hasRequests) {
      children.add(_buildSectionHeader('Bekleyen İstekler'));
      children.add(const SizedBox(height: 8));
      for (final request in requests) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: FriendRequestCard(
              friend: request,
              onAccept: () => _acceptRequest(request.id),
              onReject: () => _rejectRequest(request.id),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 12));
    }

    if (hasFriends) {
      children.add(_buildSectionHeader('Arkadaşlar'));
      children.add(const SizedBox(height: 8));
      for (final friend in friends) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FriendListItem(
              friend: friend,
              currentUserId: currentUserId,
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showFriendOptions(friend),
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: children,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSharedTab(String currentUserId) {
    final sharedWithMeAsync = ref.watch(sharedWithMeProvider);
    final sharedByMeAsync = ref.watch(sharedByMeProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Benimle Paylaşılan'),
              Tab(text: 'Paylaştıklarım'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSharedList(sharedWithMeAsync, currentUserId),
                _buildSharedList(sharedByMeAsync, currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedList(AsyncValue<List> sharedAsync, String currentUserId) {
    return sharedAsync.when(
      data: (sharedHabits) {
        if (sharedHabits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.share_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Paylaşılan alışkanlık yok',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: sharedHabits.length,
          itemBuilder: (context, index) {
            final sharedHabit = sharedHabits[index];
            return SharedHabitCard(
              sharedHabit: sharedHabit,
              currentUserId: currentUserId,
              onUnshare: () => _unshareHabit(sharedHabit.id),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddFriendDialog(),
    );
  }

  void _showFriendOptions(friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_remove),
                title: const Text('Arkadaşlıktan Çıkar'),
                onTap: () {
                  Navigator.pop(context);
                  _removeFriend(friend.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acceptRequest(String friendshipId) async {
    final result = await ref.read(acceptFriendRequestProvider)(friendshipId);
    
    if (result is Failure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _rejectRequest(String friendshipId) async {
    final result = await ref.read(rejectFriendRequestProvider)(friendshipId);
    
    if (result is Failure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _removeFriend(String friendshipId) async {
    final result = await ref.read(removeFriendProvider)(friendshipId);
    
    if (result is Failure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _unshareHabit(String sharedHabitId) async {
    final result = await ref.read(unshareHabitProvider)(sharedHabitId);
    
    if (result is Failure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  void _showActivityDetails(activity) {
    final detailChips = <Widget>[];
    if (activity.habitCategory != null && activity.habitCategory!.isNotEmpty) {
      detailChips.add(
        _buildDetailChip(
          Icons.category_outlined,
          formatCategoryLabel(activity.habitCategory!),
        ),
      );
    }
    if (activity.habitFrequencyLabel != null &&
        activity.habitFrequencyLabel!.isNotEmpty) {
      detailChips.add(
        _buildDetailChip(
          Icons.calendar_today_outlined,
          activity.habitFrequencyLabel!,
        ),
      );
    }
    if (activity.habitGoalLabel != null &&
        activity.habitGoalLabel!.isNotEmpty) {
      detailChips.add(
        _buildDetailChip(
          Icons.flag_outlined,
          activity.habitGoalLabel!,
        ),
      );
    }

    final timerLabel = activity.timerDuration != null &&
            activity.timerDuration! > 0
        ? _formatTimerDuration(activity.timerDuration!)
        : null;
    final completedLabel =
        DateFormat('d MMMM yyyy - HH:mm', 'tr').format(activity.completedAt);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(activity.username[0].toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.username,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          activity.habitName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (activity.habitDescription != null &&
                  activity.habitDescription!.isNotEmpty) ...[
                Text(
                  'Alışkanlık özeti',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.habitDescription!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              if (detailChips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: detailChips,
                ),
              ],

              // Photo if available
              if (activity.photoUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    activity.photoUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Note if available
              if (activity.note != null && activity.note!.isNotEmpty) ...[
                Text(
                  'Not:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.note!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              // Additional info chips
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (activity.quality != null)
                    _buildDetailInfo(
                      icon: Icons.star,
                      label: _getQualityText(activity.quality!),
                      iconColor: Colors.amber[700],
                    ),
                  if (timerLabel != null)
                    _buildDetailInfo(
                      icon: Icons.timer_outlined,
                      label: timerLabel,
                    ),
                  _buildDetailInfo(
                    icon: Icons.access_time,
                    label: completedLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    final theme = Theme.of(context);
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.surfaceContainerHighest
          .withAlpha((0.7 * 255).round()),
      avatar: Icon(
        icon,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildDetailInfo({
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatTimerDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sn';
    }
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (remaining == 0) {
      return '$minutes dk';
    }
    return '$minutes dk ${remaining.toString().padLeft(2, '0')} sn';
  }

  String _getQualityText(String quality) {
    switch (quality) {
      case 'excellent':
        return 'Mükemmel';
      case 'good':
        return 'İyi';
      case 'fair':
        return 'Normal';
      case 'poor':
        return 'Zayıf';
      default:
        return quality;
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktiviteyi Sil'),
        content: const Text('Bu aktiviteyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result =
          await ref.read(habitActivityRepositoryProvider).deleteActivity(activityId);

      if (!mounted) return;

      if (result is Failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      } else {
        ref.invalidate(activityFeedProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktivite silindi')),
        );
      }
    }
  }
}

