import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user_model.dart';
import '../../models/explore_filter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/explore_filter_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  ExploreFilter _filter = ExploreFilter();
  int _swipedCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNearbyUsers();
  }

  Future<void> _loadNearbyUsers() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _fallback();
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        context.read<UserViewModel>().fetchNearbyUsers(
              lat: position.latitude,
              lng: position.longitude,
            );
      }
    } catch (_) {
      _fallback();
    }
  }

  void _fallback() {
    if (mounted) {
      context.read<UserViewModel>().fetchNearbyUsers(
            lat: 18.5204,
            lng: 73.8567,
          );
    }
  }

  List<UserModel> _applyFilters(List<UserModel> users) {
    if (!_filter.isActive) return users;
    return users.where((u) {
      if (_filter.subject != null &&
          (u.subjects == null ||
              !u.subjects!.any((s) =>
                  s.toLowerCase().contains(_filter.subject!.toLowerCase())))) {
        return false;
      }
      if (_filter.year != null && u.year != null && u.year != _filter.year) {
        return false;
      }
      if (_filter.studyMode != null &&
          u.studyMode != null &&
          u.studyMode != _filter.studyMode &&
          _filter.studyMode != 'Both') {
        return false;
      }
      if (_filter.examTarget != null &&
          u.examTarget != null &&
          u.examTarget != _filter.examTarget) {
        return false;
      }
      return true;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, __) => ExploreFilterSheet(
          currentFilter: _filter,
          onApply: (f) => setState(() => _filter = f),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          // Filter button
          GestureDetector(
            onTap: _openFilters,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _filter.isActive
                        ? AppColors.primaryLight
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _filter.isActive
                          ? AppColors.primary.withAlpha((0.3 * 255).round())
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color:
                        _filter.isActive ? AppColors.primary : AppColors.textS,
                  ),
                ),
                if (_filter.isActive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_filter.activeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Refresh
          GestureDetector(
            onTap: _loadNearbyUsers,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.textS,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, vm, _) {
          // Loading
          if (vm.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Finding students near you...',
                    style: TextStyle(
                      color: AppColors.textS,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          }

          final users = _applyFilters(vm.nearbyUsers);

          // Active filter chips
          return Column(
            children: [
              // Filter chips row
              if (_filter.isActive)
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...[
                                _filter.subject,
                                _filter.year,
                                _filter.studyMode,
                                _filter.examTarget,
                              ].where((f) => f != null).map((f) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SubjectChip(
                                      label: f!,
                                      isSelected: true,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _filter = ExploreFilter()),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Counter
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      '${users.length} student${users.length != 1 ? 's' : ''} found',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textS,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_swipedCount > 0)
                      Text(
                        '$_swipedCount connected',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Empty state
              if (users.isEmpty)
                Expanded(
                  child: AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: _filter.isActive
                        ? 'No matches found'
                        : 'No students nearby',
                    subtitle: _filter.isActive
                        ? 'Try adjusting your filters to find more students.'
                        : 'Be the first to join StudyBuddy in your area!',
                    buttonLabel: _filter.isActive ? 'Clear filters' : null,
                    onButton: () => setState(() => _filter = ExploreFilter()),
                  ),
                )
              else
                // Cards
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CardSwiper(
                          controller: _swiperController,
                          cardsCount: users.length,
                          numberOfCardsDisplayed:
                              users.length > 2 ? 3 : users.length,
                          backCardOffset: const Offset(0, 24),
                          scale: 0.92,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          onSwipe: (prev, current, direction) {
                            if (direction == CardSwiperDirection.right) {
                              setState(() => _swipedCount++);
                              showAppSnackBar(
                                context,
                                'Connect request sent to ${users[prev].name}!',
                                isSuccess: true,
                              );
                            }
                            return true;
                          },
                          cardBuilder: (_, index, __, ___) =>
                              _StudentCard(user: users[index]),
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SwipeButton(
                              icon: Icons.close_rounded,
                              color: AppColors.error,
                              size: 56,
                              onTap: () => _swiperController.swipe(),
                            ),
                            const SizedBox(width: 16),
                            _SwipeButton(
                              icon: Icons.star_rounded,
                              color: AppColors.warning,
                              size: 48,
                              onTap: () => _swiperController.swipe(),
                              filled: false,
                            ),
                            const SizedBox(width: 16),
                            _SwipeButton(
                              icon: Icons.favorite_rounded,
                              color: AppColors.primary,
                              size: 56,
                              onTap: () => _swiperController.swipe(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Swipe Button ──────────────────────────────────────────────────
class _SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool filled;

  const _SwipeButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? color : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled ? color : AppColors.border,
            width: 1,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withAlpha((0.25 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : subtleShadow,
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : color,
          size: size * 0.42,
        ),
      ),
    );
  }
}

// ── Student Card ──────────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final UserModel user;

  const _StudentCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorIndex = user.name.isNotEmpty
        ? user.name.codeUnitAt(0) % AppColors.palette.length
        : 0;
    final avatarColor = AppColors.palette[colorIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: cardShadow,
      ),
      child: Column(
        children: [
          // ── Avatar section ─────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: avatarColor.withAlpha((0.08 * 255).round()),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    avatarColor.withAlpha((0.3 * 255).round()),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Reliability badge
                if (user.reliabilityScore != null && user.reliabilityScore! > 0)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: ReliabilityBadge(
                      score: user.reliabilityScore!,
                      compact: true,
                    ),
                  ),
                // Exam target badge
                if (user.examTarget != null)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.examTarget!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info section ───────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textH,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (user.year != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.year!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textS,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (user.bio != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textS,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  if (user.subjects != null && user.subjects!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: user.subjects!
                          .take(3)
                          .map((s) => SubjectChip(label: s))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
