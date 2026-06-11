import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../models/session_model.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/sessions/sessions_screen.dart';
import '../screens/sessions/session_detail_screen.dart';
import '../screens/sessions/create_session_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeDashboard(),
    const ExploreScreen(),
    const SessionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Sessions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().fetchMyProfile();
      context.read<SessionViewModel>().fetchAllSessions();
      context.read<SessionViewModel>().fetchMySessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            context.read<UserViewModel>().fetchMyProfile(),
            context
                .read<SessionViewModel>()
                .fetchAllSessions(forceRefresh: true),
            context
                .read<SessionViewModel>()
                .fetchMySessions(forceRefresh: true),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              titleSpacing: 20,
              title: Consumer<UserViewModel>(
                builder: (context, vm, _) {
                  final name = vm.user?.name ?? '';
                  final hour = DateTime.now().hour;
                  final greeting = hour < 12
                      ? 'Good morning'
                      : hour < 17
                          ? 'Good afternoon'
                          : 'Good evening';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textS,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (name.isNotEmpty)
                        Text(
                          name.split(' ').first,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textH,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                        ),
                    ],
                  );
                },
              ),
              actions: [
                Consumer<UserViewModel>(
                  builder: (context, vm, _) {
                    final name = vm.user?.name ?? '';
                    return Row(
                      children: [
                        NotificationBell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen()),
                          ),
                        ),
                        if (name.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          UserAvatar(name: name, size: 34),
                        ],
                        const SizedBox(width: 16),
                      ],
                    );
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),

                  // ── Streak Card ──────────────────────────
                  const _StreakCard(),
                  const SizedBox(height: 16),

                  // ── Stats Row ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<SessionViewModel>(
                          builder: (context, vm, _) => StatCard(
                            value: '${vm.mySessions.length}',
                            label: 'My Sessions',
                            icon: Icons.calendar_month_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(
                          value: '24h',
                          label: 'This Week',
                          icon: Icons.timer_outlined,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(
                          value: '92%',
                          label: 'Focus',
                          icon: Icons.bolt_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Quick Actions ────────────────────────
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.add_rounded,
                          label: 'New Session',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateSessionScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.people_outline_rounded,
                          label: 'Find Partners',
                          color: AppColors.secondary,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.timer_outlined,
                          label: 'Focus Timer',
                          color: AppColors.success,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.leaderboard_outlined,
                          label: 'Leader board',
                          color: AppColors.warning,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Upcoming Sessions ────────────────────
                  SectionHeader(
                    title: 'Upcoming Sessions',
                    actionLabel: 'See all',
                    onAction: () {},
                  ),
                  const SizedBox(height: 12),

                  Consumer<SessionViewModel>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return const Column(
                          children: [SkeletonCard(), SkeletonCard()],
                        );
                      }
                      final sessions = vm.allSessions.take(4).toList();
                      if (sessions.isEmpty) {
                        return AppEmptyState(
                          icon: Icons.calendar_month_outlined,
                          title: 'No sessions yet',
                          subtitle:
                              'Create your first study session and invite others.',
                          buttonLabel: 'Create Session',
                          onButton: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreateSessionScreen()),
                          ),
                        );
                      }
                      return Column(
                        children: sessions
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _SessionRow(session: s),
                                ))
                            .toList(),
                      );
                    },
                  ),

                  // ── My Sessions horizontal ───────────────
                  Consumer<SessionViewModel>(
                    builder: (context, vm, _) {
                      if (vm.mySessions.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),
                          SectionHeader(
                            title: 'My Sessions',
                            actionLabel: 'View all',
                            onAction: () {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: vm.mySessions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) =>
                                  _MySessionChip(session: vm.mySessions[i]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak Card ───────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: primaryShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '7-Day Streak',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep it going!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(7, (i) {
                    return Expanded(
                      child: Container(
                        height: 28,
                        margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _days[i],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 26)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session Row ───────────────────────────────────────────────────
class _SessionRow extends StatelessWidget {
  final SessionModel session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: subtleShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(11),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textH,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (session.subject != null) ...[
                        Flexible(
                          child: Text(
                            session.subject!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textS,
                              fontFamily: 'Inter',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(' · ',
                            style: TextStyle(
                                color: AppColors.textT, fontSize: 12)),
                      ],
                      Flexible(
                        child: Text(
                          session.hostName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textS,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusBadge(status: session.status),
          ],
        ),
      ),
    );
  }
}

// ── My Session Chip ───────────────────────────────────────────────
class _MySessionChip extends StatelessWidget {
  final SessionModel session;
  const _MySessionChip({required this.session});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session)),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.book_outlined,
                      color: AppColors.primary, size: 14),
                ),
                const Spacer(),
                StatusBadge(status: session.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textH,
                fontFamily: 'Inter',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              session.subject ?? 'General',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textS,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
