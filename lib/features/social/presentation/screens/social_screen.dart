import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/result.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/social_providers.dart';
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
            Tab(text: 'Arkadaşlar', icon: Icon(Icons.people)),
            Tab(text: 'İstekler', icon: Icon(Icons.person_add)),
            Tab(text: 'Paylaşılan', icon: Icon(Icons.share)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(currentUser.id),
          _buildRequestsTab(),
          _buildSharedTab(currentUser.id),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _showAddFriendDialog(context),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildFriendsTab(String currentUserId) {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
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
                  'Henüz arkadaşınız yok',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arkadaş eklemek için + butonuna tıklayın',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return FriendListItem(
              friend: friend,
              currentUserId: currentUserId,
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showFriendOptions(friend),
              ),
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

  Widget _buildRequestsTab() {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Arkadaşlık isteği yok',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return FriendRequestCard(
              friend: request,
              onAccept: () => _acceptRequest(request.id),
              onReject: () => _rejectRequest(request.id),
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
}

