import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/gamification_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../models/session_model.dart';
import '../explore/explore_screen.dart';
import '../sessions/sessions_screen.dart';
import '../sessions/session_detail_screen.dart';
import '../sessions/create_session_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../gamification/leaderboard_screen.dart';
import '../focus/focus_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboard(onOpenDiscover: () => setState(() => _currentIndex = 1)),
      const ExploreScreen(),
      const SessionsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
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

// Helper widgets (simple stand-ins for widgets/app_widgets.dart)
class NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;
  const NotificationBell({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_outlined),
      onPressed: onTap,
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const StatCard({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 100;
          final iconBox = Container(
            width: compact ? 32 : 40,
            height: compact ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: compact ? 20 : 24),
          );
          final details = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textS,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconBox,
                const SizedBox(height: 6),
                details,
              ],
            );
          }

          return Row(
            children: [
              iconBox,
              const SizedBox(width: 10),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader(
      {Key? key, required this.title, this.actionLabel, this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textH,
                fontFamily: 'Inter')),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const QuickActionButton(
      {Key? key,
      required this.icon,
      required this.label,
      required this.color,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onButton;
  const AppEmptyState(
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.buttonLabel,
      this.onButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppColors.textS),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textS)),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onButton, child: Text(buttonLabel)),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final dynamic status;
  const StatusBadge({Key? key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = status?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  final VoidCallback onOpenDiscover;

  const HomeDashboard({
    super.key,
    required this.onOpenDiscover,
  });

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
      context.read<GamificationViewModel>().fetchGamification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        displacement: 60,
        onRefresh: () async {
          await Future.wait([
            context.read<UserViewModel>().fetchMyProfile(),
            context
                .read<SessionViewModel>()
                .fetchAllSessions(forceRefresh: true),
            context
                .read<SessionViewModel>()
                .fetchMySessions(forceRefresh: true),
            context
                .read<GamificationViewModel>()
                .fetchGamification(forceRefresh: true),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ───────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withOpacity(0.08),
              titleSpacing: 20,
              title: Consumer<UserViewModel>(
                builder: (context, vm, _) {
                  final name = vm.user?.name ?? 'Student';
                  final hour = DateTime.now().hour;
                  final greeting = hour < 12
                      ? 'Good morning'
                      : hour < 17
                          ? 'Good afternoon'
                          : 'Good evening';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                NotificationBell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Streak Card ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Consumer<GamificationViewModel>(
                      builder: (context, vm, _) => _StreakCard(
                        streak: vm.profile?.currentStreak ?? 0,
                        xp: vm.profile?.xp ?? 0,
                      ),
                    ),
                  ),

                  // ── Stats Row ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<GamificationViewModel>(
                            builder: (context, vm, _) => StatCard(
                              value: '${vm.profile?.xp ?? 0}',
                              label: 'Total XP',
                              icon: Icons.bolt_rounded,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<GamificationViewModel>(
                            builder: (context, vm, _) => StatCard(
                              value: vm.profile?.weeklyRank == null
                                  ? '-'
                                  : '#${vm.profile!.weeklyRank}',
                              label: 'College Rank',
                              icon: Icons.leaderboard_outlined,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Quick Actions ────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: SectionHeader(title: 'Quick Actions'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.add_rounded,
                            label: 'New\nSession',
                            color: AppColors.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CreateSessionScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.people_outline_rounded,
                            label: 'Find\nPartners',
                            color: AppColors.secondary,
                            onTap: widget.onOpenDiscover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.timer_outlined,
                            label: 'Focus\nTimer',
                            color: AppColors.success,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FocusTimerScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.leaderboard_outlined,
                            label: 'Leader\nboard',
                            color: AppColors.warning,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Upcoming Sessions ────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    child: SectionHeader(
                      title: 'Upcoming Sessions',
                      actionLabel: 'See all',
                      onAction: () {},
                    ),
                  ),
                  Consumer<SessionViewModel>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: const [
                              SkeletonCard(),
                              SkeletonCard(),
                            ],
                          ),
                        );
                      }
                      final sessions = vm.allSessions.take(4).toList();
                      if (sessions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppEmptyState(
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
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _SessionRow(session: sessions[i]),
                      );
                    },
                  ),

                  // ── My Active Sessions ───────────────────────
                  Consumer<SessionViewModel>(
                    builder: (context, vm, _) {
                      if (vm.mySessions.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                            child: SectionHeader(
                              title: 'My Sessions',
                              actionLabel: 'View all',
                              onAction: () {},
                            ),
                          ),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vm.mySessions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, i) =>
                                  _MySessionChip(session: vm.mySessions[i]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
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
  final int streak;
  final int xp;
  final List<String> _days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const _StreakCard({required this.streak, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: primaryShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streak-Day Streak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  streak == 0
                      ? 'Check in to start your streak'
                      : 'Keep it going! $xp XP earned',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 5.0;
                    final availableForDays =
                        constraints.maxWidth - (gap * (_days.length - 1));
                    final daySize =
                        (availableForDays / _days.length).clamp(0.0, 30.0);

                    return Row(
                      children: List.generate(_days.length, (i) {
                        final todayIndex = DateTime.now().weekday - 1;
                        final earliestDone = todayIndex - streak + 1;
                        final done =
                            streak > 0 && i <= todayIndex && i >= earliestDone;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i == _days.length - 1 ? 0 : gap,
                          ),
                          child: Container(
                            width: daySize,
                            height: 30,
                            decoration: BoxDecoration(
                              color: done
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _days[i],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: done
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.6),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 30,
              ),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.book_outlined,
                color: AppColors.primary,
                size: 20,
              ),
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
                        Text(
                          session.subject!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textS,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const Text(
                          ' · ',
                          style:
                              TextStyle(color: AppColors.textT, fontSize: 12),
                        ),
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
        width: 180,
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.book_outlined,
                      color: AppColors.primary, size: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
