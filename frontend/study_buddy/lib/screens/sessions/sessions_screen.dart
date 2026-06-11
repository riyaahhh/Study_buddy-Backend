import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../models/session_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../chat/chat_screen.dart';
import 'create_session_screen.dart';
import 'session_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Upcoming'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().fetchAllSessions();
      context.read<SessionViewModel>().fetchMySessions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<SessionModel> _filter(List<SessionModel> sessions) {
    var list = sessions;
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) {
        return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (s.subject?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false) ||
            s.hostName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    if (_selectedFilter == 'Active') {
      list = list.where((s) => s.status == 'active').toList();
    } else if (_selectedFilter == 'Upcoming') {
      list = list.where((s) => s.status == 'upcoming').toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sessions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search sessions, subjects...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              // Filter chips
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final selected = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppColors.textS,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Sessions'),
                  Tab(text: 'My Sessions'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
          );
          if (context.mounted) {
            context
                .read<SessionViewModel>()
                .fetchAllSessions(forceRefresh: true);
            context
                .read<SessionViewModel>()
                .fetchMySessions(forceRefresh: true);
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SessionList(useAll: true, filterFn: _filter),
          _SessionList(useAll: false, filterFn: _filter),
        ],
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final bool useAll;
  final List<SessionModel> Function(List<SessionModel>) filterFn;

  const _SessionList({required this.useAll, required this.filterFn});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [SkeletonCard(), SkeletonCard(), SkeletonCard()],
            ),
          );
        }

        final sessions = filterFn(useAll ? vm.allSessions : vm.mySessions);

        if (sessions.isEmpty) {
          return AppEmptyState(
            icon: Icons.calendar_month_outlined,
            title: useAll ? 'No sessions found' : 'No sessions yet',
            subtitle: useAll
                ? 'Try a different search or filter.'
                : 'Create or join a session to get started.',
            buttonLabel: useAll ? null : 'Create Session',
            onButton: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            if (useAll) {
              await context
                  .read<SessionViewModel>()
                  .fetchAllSessions(forceRefresh: true);
            } else {
              await context
                  .read<SessionViewModel>()
                  .fetchMySessions(forceRefresh: true);
            }
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _SessionCard(session: sessions[i]),
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.book_outlined,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textH,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (session.subject != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          session.subject!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textS,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: session.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Meta row
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: AppColors.textT),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    session.hostName,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textS,
                        fontFamily: 'Inter'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textT),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    session.locationName ?? 'Online',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textS,
                        fontFamily: 'Inter'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.group_outlined,
                    size: 14, color: AppColors.textT),
                const SizedBox(width: 4),
                Text(
                  '${session.maxMembers}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textS,
                      fontFamily: 'Inter'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context
                          .read<SessionViewModel>()
                          .joinSession(session.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SessionDetailScreen(session: session)),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Join'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(session: session)),
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
