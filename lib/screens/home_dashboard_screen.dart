import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/place_image.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.controller,
    required this.onNavTap,
    required this.onGetFreshIdea,
    required this.onCantDecide,
    required this.onOpenBucketList,
  });

  final AppController controller;
  final ValueChanged<int> onNavTap;
  final VoidCallback onGetFreshIdea;
  final VoidCallback onCantDecide;
  final VoidCallback onOpenBucketList;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  AppController get controller => widget.controller;
  ValueChanged<int> get onNavTap => widget.onNavTap;
  VoidCallback get onGetFreshIdea => widget.onGetFreshIdea;
  VoidCallback get onCantDecide => widget.onCantDecide;
  VoidCallback get onOpenBucketList => widget.onOpenBucketList;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    final couple = controller.couple;
    final pending = controller.bucketItems
        .where((i) => i.status == BucketListStatus.pending)
        .toList();
    final completed = controller.bucketItems
        .where((i) => i.status == BucketListStatus.done)
        .toList();
    final idea = controller.currentSuggestions.isEmpty
        ? null
        : controller.currentSuggestions.first;
    final location = couple?.locations.isNotEmpty == true
        ? couple!.locations.first
        : 'Location not set';
    final partner = _partnerName();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.gradientEnd,
                onRefresh: () async {
                  if (couple?.locations.isNotEmpty == true &&
                      couple!.budget > 0) {
                    await controller.generateSuggestions(controller.mood);
                  } else {
                    await controller.generateMoodIdeas(controller.mood);
                  }
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dateLabel(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_greeting()}, ${user.name} & $partner',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => onNavTap(3),
                          customBorder: const CircleBorder(),
                          child: AvatarBadge(
                            initial: user.name.isEmpty
                                ? '?'
                                : user.name[0].toUpperCase(),
                            backgroundColor: AppColors.blushDeep,
                            textColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => onNavTap(3),
                          customBorder: const CircleBorder(),
                          child: AvatarBadge(
                            initial: _partnerInitial(),
                            backgroundColor: AppColors.magentaDeep,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _contextBar(
                      location: location,
                      budget: couple?.budget ?? 0,
                      currency: couple?.budgetCurrency ?? 'PHP',
                    ),
                    const SizedBox(height: 16),
                    _hero(context, idea),
                    const SizedBox(height: 18),
                    const AppSectionTitle(
                      title: 'Choose your vibe',
                      subtitle:
                          'Your mood is independent from saved preferences.',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 94,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 9),
                        itemBuilder: (_, i) {
                          final mood = _moods[i];
                          final selected =
                              controller.mood.toLowerCase() ==
                              mood.label.toLowerCase();
                          return _MoodTile(
                            mood: mood,
                            selected: selected,
                            onTap: () async {
                              await controller.generateMoodIdeas(mood.label);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Find a date',
                            subtitle: 'Use your preferences',
                            onTap: onGetFreshIdea,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Pick for us',
                            subtitle: 'Talk to DateMate',
                            onTap: onCantDecide,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppSectionTitle(
                      title: 'Your date bucket',
                      subtitle:
                          '${pending.length} saved · ${completed.length} completed',
                      actionLabel: 'See all',
                      onAction: onOpenBucketList,
                    ),
                    const SizedBox(height: 10),
                    if (pending.isEmpty)
                      AppCard(child: _emptyBucket(onGetFreshIdea))
                    else
                      ...pending
                          .take(3)
                          .map(
                            (item) => _SavedPreview(
                              item: item,
                              onTap: onOpenBucketList,
                            ),
                          ),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onOpenBucketList,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.blush,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: AppColors.gradientEnd,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Last date together',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        completed.isEmpty
                                            ? 'Your completed dates will appear here.'
                                            : '${completed.first.name} · ${_formatDate(completed.first.completedAt ?? DateTime.now())}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'DateMate AI · made for easier date decisions',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(currentIndex: 0, onTap: onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _contextBar({
    required String location,
    required double budget,
    required String currency,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onNavTap(3),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .11)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.gradientEnd,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(width: 1, height: 18, color: AppColors.outline),
              const SizedBox(width: 10),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: AppColors.gradientEnd,
              ),
              const SizedBox(width: 5),
              Text(
                budget > 0 ? '$currency ${budget.round()}' : 'Budget not set',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_rounded, size: 13, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, DateSuggestion? idea) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onGetFreshIdea,
        child: Ink(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: AppColors.heroGradient,
            border: Border.all(color: Colors.white.withValues(alpha: .14)),
            boxShadow: AppShadows.glow,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: idea == null
                    ? _heroArtwork()
                    : PlaceImage(
                        placeName: idea.title,
                        category: idea.category,
                        seedKey: idea.placeId,
                        assetPath: idea.imageUrl,
                        aiIdea: idea.imageUrl.isEmpty && !idea.verified,
                        height: 220,
                        borderRadius: 0,
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primaryDark.withValues(alpha: .35),
                        AppColors.primaryDark.withValues(alpha: .94),
                      ],
                      stops: const [0.2, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .24),
                        ),
                      ),
                      child: const Text(
                        "TONIGHT'S IDEA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idea?.title ?? 'Your next date starts here',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      idea == null
                          ? 'Choose a vibe or save preferences to discover real places.'
                          : '${idea.location} · ${idea.price}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroButton(
                            label: 'Fresh idea',
                            icon: Icons.refresh_rounded,
                            onTap: onGetFreshIdea,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HeroButton(
                            label: 'Pick for us',
                            icon: Icons.auto_awesome_rounded,
                            onTap: onCantDecide,
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroArtwork() {
    return Stack(
      children: [
        Positioned(
          left: -45,
          top: -55,
          child: _orb(150, AppColors.rose.withValues(alpha: .22)),
        ),
        Positioned(
          right: -35,
          top: 15,
          child: _orb(125, Colors.white.withValues(alpha: .10)),
        ),
        Positioned(
          left: 30,
          top: 35,
          child: Icon(
            Icons.favorite_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: .18),
          ),
        ),
        Positioned(
          right: 32,
          top: 38,
          child: Icon(
            Icons.local_cafe_rounded,
            size: 44,
            color: Colors.white.withValues(alpha: .16),
          ),
        ),
        Positioned(
          left: 105,
          top: 72,
          child: Icon(
            Icons.restaurant_rounded,
            size: 30,
            color: Colors.white.withValues(alpha: .14),
          ),
        ),
        Positioned(
          right: 100,
          top: 74,
          child: Icon(
            Icons.movie_rounded,
            size: 30,
            color: Colors.white.withValues(alpha: .14),
          ),
        ),
        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .10),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white70,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _emptyBucket(VoidCallback onTap) => Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.favorite_border_rounded,
          color: AppColors.gradientEnd,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Your bucket is waiting',
        style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
      const SizedBox(height: 4),
      Text(
        'Save places you want to try together.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
      ),
      const SizedBox(height: 10),
      OutlinedButton(onPressed: onTap, child: const Text('Discover a date')),
    ],
  );

  /// Greeting based on Philippine time (UTC+8), independent of the device's
  /// own time zone.
  String _greeting() {
    final hour = DateTime.now().toUtc().add(const Duration(hours: 8)).hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _partnerName() {
    final c = controller.couple;
    if (c == null || c.memberIds.length < 2) return 'your partner';
    final id = c.memberIds.firstWhere(
      (id) => id != controller.currentUser!.id,
      orElse: () => '',
    );
    return c.memberNames[id] ?? 'your partner';
  }

  String _partnerInitial() {
    final name = _partnerName();
    if (name == 'your partner') return '♥';
    return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
  }

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

  String _dateLabel() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  static const _moods = <_MoodData>[
    _MoodData('Chill', Icons.spa_rounded),
    _MoodData('Foodie', Icons.restaurant_rounded),
    _MoodData('Adventurous', Icons.explore_rounded),
    _MoodData('Cheap date', Icons.savings_outlined),
  ];
}

class _MoodData {
  const _MoodData(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });
  final _MoodData mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 104,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: selected
              ? AppColors.buttonGradient
              : AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: .3)
                : Colors.white.withValues(alpha: .09),
          ),
          boxShadow: selected ? AppShadows.glow : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              mood.icon,
              size: 22,
              color: selected ? Colors.white : AppColors.pinkText,
            ),
            const Spacer(),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .09)),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.chipGradient,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.pinkText.withValues(alpha: .25),
                ),
              ),
              child: Icon(icon, color: AppColors.pinkText, size: 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Container(
      decoration: BoxDecoration(
        gradient: filled ? AppColors.buttonGradient : null,
        color: filled ? null : Colors.white.withValues(alpha: .12),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: filled ? .28 : .22),
        ),
        boxShadow: filled ? AppShadows.glow : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedPreview extends StatelessWidget {
  const _SavedPreview({required this.item, required this.onTap});
  final BucketListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: 62,
                height: 62,
                child: PlaceImage(
                  placeName: item.name,
                  category: item.category,
                  seedKey: item.id,
                  assetPath: item.imageUrl,
                  aiIdea:
                      item.imageUrl.isEmpty &&
                      item.subtitle != 'Added manually',
                  height: 62,
                  borderRadius: 0,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.category} · ${item.price}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
