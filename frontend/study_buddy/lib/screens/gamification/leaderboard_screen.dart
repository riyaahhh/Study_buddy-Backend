import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gamification_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/gamification_viewmodel.dart';
import '../../widgets/app_widgets.dart';
import '../profile/edit_profile_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _currentUserId = await ApiService.getUserId();
      if (mounted) {
        setState(() {});
        context.read<GamificationViewModel>().fetchGamification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Leaderboard')),
      body: Consumer<GamificationViewModel>(
        builder: (context, vm, _) {
          final profile = vm.profile;
          if (vm.isLoading && profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (profile?.college == null || profile!.college!.trim().isEmpty) {
            return AppEmptyState(
              icon: Icons.school_outlined,
              title: 'Add your college',
              subtitle:
                  'Set your college in your profile to join its weekly ranking.',
              buttonLabel: 'Edit Profile',
              onButton: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => vm.fetchGamification(forceRefresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _LeaderboardHeader(
                  college: profile.college!,
                  rank: profile.weeklyRank,
                  weeklyXp: profile.weeklyXp,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Most active this week',
                  style: TextStyle(
                    color: AppColors.textH,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (vm.leaderboard.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text(
                      'No XP has been earned at your college this week yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textS),
                    ),
                  )
                else
                  ...vm.leaderboard.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LeaderboardRow(
                        entry: entry,
                        isCurrentUser: entry.userId == _currentUserId,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final String college;
  final int? rank;
  final int weeklyXp;

  const _LeaderboardHeader({
    required this.college,
    required this.rank,
    required this.weeklyXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            college,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HeaderStat(
                  label: 'Your rank', value: rank == null ? '-' : '#$rank'),
              const SizedBox(width: 12),
              _HeaderStat(label: 'Weekly XP', value: '$weeklyXp XP'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
  });

  Color get _rankColor {
    if (entry.rank == 1) return const Color(0xFFF59E0B);
    if (entry.rank == 2) return const Color(0xFF64748B);
    if (entry.rank == 3) return const Color(0xFFB45309);
    return AppColors.textS;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.border,
          width: isCurrentUser ? 1 : 0.5,
        ),
        boxShadow: subtleShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: _rankColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          UserAvatar(
            name: entry.name,
            imageUrl: entry.avatarUrl,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? '${entry.name} (You)' : entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textH,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.totalXp} total XP'
                  '${entry.badges.isEmpty ? '' : ' · ${entry.badges.last}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textS,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.weeklyXp} XP',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
