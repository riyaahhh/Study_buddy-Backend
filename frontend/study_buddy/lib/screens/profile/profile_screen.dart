import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/gamification_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().fetchMyProfile();
      context.read<GamificationViewModel>().fetchGamification();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (updated == true && mounted) {
      await context.read<UserViewModel>().fetchMyProfile(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textS,
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          final user = vm.user;
          if (user == null) {
            final isUnauthorized = vm.errorStatusCode == 401;
            return AppEmptyState(
              icon: Icons.person_outline_rounded,
              title: vm.errorStatusCode == 404
                  ? 'Profile not found'
                  : 'Unable to load profile',
              subtitle: isUnauthorized
                  ? 'Your session has expired. Please sign in again.'
                  : (vm.error ?? 'Check your connection and try again.'),
              buttonLabel: isUnauthorized ? 'Log In' : 'Retry',
              onButton: () {
                if (isUnauthorized) {
                  // Direct logout
                  context.read<AuthViewModel>().logout().then((_) {
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  });
                } else {
                  vm.fetchMyProfile(forceRefresh: true);
                }
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await Future.wait([
                vm.fetchMyProfile(forceRefresh: true),
                context
                    .read<GamificationViewModel>()
                    .fetchGamification(forceRefresh: true),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Header Card ──────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.5),
                      boxShadow: subtleShadow,
                    ),
                    child: Column(
                      children: [
                        UserAvatar(
                          name: user.name,
                          size: 80,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textH,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textS,
                            fontFamily: 'Inter',
                          ),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            user.bio!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textB,
                              fontFamily: 'Inter',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (user.reliabilityScore != null &&
                            user.reliabilityScore! > 0) ...[
                          const SizedBox(height: 14),
                          ReliabilityBadge(score: user.reliabilityScore!),
                        ],
                        if (user.subjects != null &&
                            user.subjects!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: user.subjects!
                                .map((s) => SubjectChip(label: s))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stats ────────────────────────────────
                  Consumer<SessionViewModel>(
                    builder: (context, svm, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              value: '${svm.mySessions.length}',
                              label: 'Sessions',
                              icon: Icons.calendar_month_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              value: '${user.totalCompleted ?? 0}',
                              label: 'Completed',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              value:
                                  '${user.reliabilityScore?.toStringAsFixed(0) ?? 0}%',
                              label: 'Reliability',
                              icon: Icons.verified_outlined,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Consumer<GamificationViewModel>(
                    builder: (context, gamificationVm, _) {
                      final gamification = gamificationVm.profile;
                      if (gamification == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          _GamificationCard(
                            xp: gamification.xp,
                            streak: gamification.currentStreak,
                            badges: gamification.badges,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // ── Info ─────────────────────────────────
                  InfoRow(
                    icon: Icons.account_balance_outlined,
                    label: 'College',
                    value: user.college?.isNotEmpty == true
                        ? user.college!
                        : 'Not set - add it to join the leaderboard',
                    iconColor: AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: user.latitude != null
                        ? 'Location set ✓'
                        : 'Not set — tap Edit to add',
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Subjects',
                    value: user.subjects != null && user.subjects!.isNotEmpty
                        ? user.subjects!.join(', ')
                        : 'No subjects added yet',
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(height: 24),

                  // ── Reliability Score Card ───────────────
                  if (user.totalJoined != null && user.totalJoined! > 0)
                    _ReliabilityCard(
                      score: user.reliabilityScore ?? 0,
                      joined: user.totalJoined ?? 0,
                      completed: user.totalCompleted ?? 0,
                    ),
                  if (user.totalJoined != null && user.totalJoined! > 0)
                    const SizedBox(height: 16),

                  // ── Edit Profile ─────────────────────────
                  OutlinedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 10),

                  // ── Sign Out ─────────────────────────────
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Badge {
  final String title;
  final IconData icon;
  final Color color;

  const _Badge(this.title, this.icon, this.color);
}

class _GamificationCard extends StatelessWidget {
  final int xp;
  final int streak;
  final List<String> badges;

  const _GamificationCard({
    required this.xp,
    required this.streak,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    const allBadges = [
      _Badge('Bronze Scholar', Icons.school_rounded, Color(0xFFB45309)),
      _Badge(
          'Silver Scholar', Icons.workspace_premium_rounded, Color(0xFF64748B)),
      _Badge(
          'Placement Warrior', Icons.military_tech_rounded, AppColors.warning),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.textH,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$xp XP  ·  $streak day streak',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: allBadges.map((badge) {
              final unlocked = badges.contains(badge.title);
              final isLast = allBadges.indexOf(badge) == allBadges.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isLast ? 0 : 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? badge.color.withValues(alpha: 0.1)
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: unlocked
                            ? badge.color.withValues(alpha: 0.35)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          unlocked ? badge.icon : Icons.lock_outline_rounded,
                          color: unlocked ? badge.color : AppColors.textT,
                          size: 24,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          badge.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unlocked ? AppColors.textH : AppColors.textT,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            xp < 100
                ? '${100 - xp} XP until Bronze Scholar'
                : xp < 300
                    ? '${300 - xp} XP until Silver Scholar'
                    : 'Complete 10 sessions to earn Placement Warrior',
            style: const TextStyle(
              color: AppColors.textS,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reliability Card ──────────────────────────────────────────────
class _ReliabilityCard extends StatelessWidget {
  final double score;
  final int joined;
  final int completed;

  const _ReliabilityCard({
    required this.score,
    required this.joined,
    required this.completed,
  });

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _label {
    if (score >= 80) return 'Highly reliable study partner ⭐';
    if (score >= 50) return 'Building reliability 📈';
    return 'Complete sessions to build score 🚀';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reliability Score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textH,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              Text(
                '$completed / $joined sessions',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textS,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${score.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _color,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  score >= 80
                      ? 'Excellent'
                      : score >= 50
                          ? 'Good'
                          : 'Building',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _color,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: _color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textS,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
