import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/shortcut_tile.dart';

class HomeDashboardScreen extends StatelessWidget {
  final AppController controller;
  final ValueChanged<int> onNavTap;
  final VoidCallback onGetFreshIdea;
  final VoidCallback onCantDecide;
  final VoidCallback onOpenBucketList;

  const HomeDashboardScreen({
    super.key,
    required this.controller,
    required this.onNavTap,
    required this.onGetFreshIdea,
    required this.onCantDecide,
    required this.onOpenBucketList,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;

    final pendingItems = controller.bucketItems
        .where((item) => item.status == BucketListStatus.pending)
        .toList();

    final completedItems = controller.bucketItems
        .where((item) => item.status == BucketListStatus.done)
        .toList();

    final pending = pendingItems.length;
    final done = completedItems.length;

    final idea = controller.currentSuggestions.isNotEmpty
        ? controller.currentSuggestions.first
        : null;

    final savedItems = pendingItems.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.generateSuggestions(controller.mood);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -----------------------------------------------------
                      // HEADER
                      // -----------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dateLabel(),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                    children: [
                                      TextSpan(text: 'Hi ${user.name} '),
                                      const TextSpan(
                                        text: '& ',
                                        style: TextStyle(
                                          color: AppColors.gradientEnd,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _partnerName(controller),
                                        style: const TextStyle(
                                          color: AppColors.gradientEnd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AvatarBadge(
                            initial: user.name.isEmpty
                                ? '?'
                                : user.name[0].toUpperCase(),
                            backgroundColor: const Color(0xFFF8C9D7),
                            textColor: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          AvatarBadge(
                            initial: _partnerInitial(controller),
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // -----------------------------------------------------
                      // TONIGHT'S IDEA
                      // -----------------------------------------------------
                      Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroCardGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(child: _heroArtwork()),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary.withValues(alpha: .88),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "TONIGHT'S IDEA",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white70,
                                          letterSpacing: 1,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    idea?.title ?? 'Build your first date idea',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    idea == null
                                        ? 'Save your preferences to generate ideas.'
                                        : '${idea.price} · ${idea.location}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: onGetFreshIdea,
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white24,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Get a fresh idea',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // -----------------------------------------------------
                      // SHORTCUTS
                      // -----------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: ShortcutTile(
                              icon: Icons.shuffle,
                              title: "Can't decide?",
                              subtitle: 'Pick for us',
                              onTap: onCantDecide,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ShortcutTile(
                              icon: Icons.checklist,
                              title: 'Bucket List',
                              subtitle: '$pending pending · $done done',
                              onTap: onOpenBucketList,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // -----------------------------------------------------
                      // SAVED FOR SOON HEADER
                      // -----------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Saved for soon',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: onOpenBucketList,
                            child: const Text(
                              'See all',
                              style: TextStyle(color: AppColors.gradientEnd),
                            ),
                          ),
                        ],
                      ),

                      // -----------------------------------------------------
                      // SAVED ITEMS
                      // -----------------------------------------------------
                      if (savedItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Your bucket list is empty. Add a date idea to get started.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      else
                        Column(
                          children: savedItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: InkWell(
                                onTap: onOpenBucketList,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 17,
                                        backgroundColor: AppColors.secondary,
                                        child: Icon(
                                          Icons.favorite_border,
                                          color: AppColors.gradientEnd,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${item.category} · ${item.price}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 10),

                      // -----------------------------------------------------
                      // LAST DATE TOGETHER
                      // -----------------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Last date together',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              completedItems.isEmpty
                                  ? 'No completed dates yet'
                                  : '${completedItems.first.name} · '
                                        '${_formatDate(completedItems.first.completedAt ?? DateTime.now())}',
                            ),
                            if (completedItems.isNotEmpty &&
                                completedItems.first.rating != null)
                              Row(
                                children: List.generate(5, (index) {
                                  final rating = completedItems.first.rating!;

                                  return Icon(
                                    index < rating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: const Color(0xFFD9A441),
                                  );
                                }),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------------
            // BOTTOM NAVIGATION
            // -------------------------------------------------------------
            AppBottomNavBar(currentIndex: 0, onTap: onNavTap),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // HERO ARTWORK
  // -----------------------------------------------------------------------

  Widget _heroArtwork() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -45,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -35,
            top: 22,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 28,
            child: Icon(
              Icons.favorite,
              size: 44,
              color: Colors.white.withValues(alpha: .18),
            ),
          ),
          Positioned(
            right: 34,
            top: 30,
            child: Icon(
              Icons.local_cafe,
              size: 42,
              color: Colors.white.withValues(alpha: .17),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            child: Icon(
              Icons.restaurant,
              size: 29,
              color: Colors.white.withValues(alpha: .15),
            ),
          ),
          Positioned(
            right: 102,
            top: 68,
            child: Icon(
              Icons.local_activity,
              size: 28,
              color: Colors.white.withValues(alpha: .15),
            ),
          ),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .20)),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white70,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // PARTNER NAME
  // -----------------------------------------------------------------------

  String _partnerName(AppController controller) {
    final couple = controller.couple;

    if (couple == null || couple.memberIds.length < 2) {
      return 'your partner';
    }

    final partnerId = couple.memberIds.firstWhere(
      (id) => id != controller.currentUser!.id,
      orElse: () => '',
    );

    return couple.memberNames[partnerId] ?? 'your partner';
  }

  // -----------------------------------------------------------------------
  // PARTNER INITIAL
  // -----------------------------------------------------------------------

  String _partnerInitial(AppController controller) {
    final name = _partnerName(controller);

    if (name == 'your partner') {
      return '♥';
    }

    if (name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }

  // -----------------------------------------------------------------------
  // DATE FORMAT
  // -----------------------------------------------------------------------

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  // -----------------------------------------------------------------------
  // CURRENT DATE LABEL
  // -----------------------------------------------------------------------

  String _dateLabel() {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${days[now.weekday - 1]}, '
        '${now.day} ${_month(now.month)}';
  }

  String _month(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}
