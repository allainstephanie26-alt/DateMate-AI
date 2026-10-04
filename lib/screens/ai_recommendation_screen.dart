import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/date_suggestion_card.dart';
import '../widgets/primary_gradient_button.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/app_page_header.dart';
import '../widgets/place_image.dart';
import '../widgets/datemate_chat_sheet.dart';
import '../widgets/place_browse_section.dart';
import '../models/app_models.dart';

class AiRecommendationScreen extends StatefulWidget {
  final AppController controller;
  final ValueChanged<int>? onNavTap;

  const AiRecommendationScreen({
    super.key,
    required this.controller,
    this.onNavTap,
  });

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  String mood = 'Chill';
  final _browseSectionKey = GlobalKey<PlaceBrowseSectionState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerChanged);
    mood = widget.controller.mood;

    if (widget.controller.currentSuggestions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.controller.generateMoodIdeas(mood),
      );
    }
  }

  void _controllerChanged() {
    if (mounted) setState(() {});
  }

  /// A key that changes whenever the search criteria change, so the browse
  /// grid below restarts from page 0 with fresh results instead of mixing
  /// pages generated for a previous mood or filter set.
  String get _browseToken {
    final couple = widget.controller.couple;
    return [
      mood,
      couple?.locations.join(',') ?? '',
      couple?.foods.join(',') ?? '',
      couple?.activities.join(',') ?? '',
      couple?.budget ?? 0,
    ].join('|');
  }

  /// Fires when the outer page scrolls near the bottom, so the "unlimited
  /// places" grid keeps growing as the couple scrolls instead of stopping
  /// at one page — the "Load more" button underneath does the same thing
  /// for a tap-only alternative.
  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.pixels > n.metrics.maxScrollExtent - 500) {
      _browseSectionKey.currentState?.loadMore();
    }
    return false;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerChanged);
    super.dispose();
  }

  Future<void> _generate() async {
    if (_hasSavedFilters) {
      await widget.controller.generateSuggestions(mood);
    } else {
      await widget.controller.generateMoodIdeas(mood);
    }

    if (!mounted) return;

    if (widget.controller.currentSuggestions.isEmpty) {
      _toast(
        'No verified place matches that combination yet — DateMate ideas below should still fit.',
      );
    } else {
      _toast('Ideas matching your saved preferences are ready.');
    }
  }

  bool get _hasSavedFilters {
    final couple = widget.controller.couple;
    return couple != null && couple.locations.isNotEmpty && couple.budget > 0;
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickForUs() async {
    if (widget.controller.currentSuggestions.isEmpty) {
      await _generate();
    }
    if (!mounted || widget.controller.currentSuggestions.isEmpty) {
      _toast(
        'I can still chat and pick from mood-based ideas before you save preferences.',
      );
      return;
    }
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateMateChatSheet(controller: widget.controller),
    );
  }

  Future<void> _showDetails(DateSuggestion suggestion) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceDetailsSheet(
        suggestion: suggestion,
        controller: widget.controller,
        onSaved: () => _toast('Added to your Bucket List.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppPageHeader(
                        title: 'AI Date Recommendation',
                        subtitle: 'A calmer way to choose your next date',
                        onBack: () => widget.onNavTap?.call(0),
                        trailing: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.blush,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.gradientEnd,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tonight we feel...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children:
                                  [
                                        'Chill',
                                        'Foodie',
                                        'Adventurous',
                                        'Cheap date',
                                      ]
                                      .map(
                                        (m) => SelectableChip(
                                          label: m,
                                          selected: mood == m,
                                          onTap: () async {
                                            setState(() => mood = m);
                                            await widget.controller
                                                .generateMoodIdeas(m);
                                            if (mounted) {
                                              _toast(
                                                'Fresh $m ideas are ready — this mood is independent of saved preferences.',
                                              );
                                            }
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _hasSavedFilters
                                    ? AppColors.blush
                                    : AppColors.lavenderSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _hasSavedFilters
                                        ? Icons.tune_rounded
                                        : Icons.explore_rounded,
                                    size: 14,
                                    color: AppColors.gradientEnd,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _hasSavedFilters
                                        ? 'Using your saved preferences'
                                        : 'Explore by mood — preferences are optional',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  c.couple == null || c.couple!.budget <= 0
                                      ? 'Explore mode'
                                      : '${c.couple!.budgetCurrency} ${c.couple!.budget.round()}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    c.couple?.locations.isEmpty ?? true
                                        ? 'Mood-only ideas — no location required'
                                        : c.couple!.locations.join(', '),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PrimaryGradientButton(
                              label: c.generating
                                  ? 'Finding real places...'
                                  : 'Generate New Ideas',
                              icon: Icons.auto_awesome,
                              loading: c.generating,
                              onPressed: c.generating ? null : _generate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (c.generating)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.gradientEnd,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Matching location, preferences, and budget...',
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (c.currentSuggestions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.blush,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                color: AppColors.gradientEnd,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No verified place currently matches every saved filter. Browse the unlimited catalog below, or try a nearby area, another preference, or a higher budget.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...c.currentSuggestions.map(
                          (s) => DateSuggestionCard(
                            suggestion: s,
                            isFavorite: c.isFavorite(s.id),
                            isSaved: c.isSavedSuggestion(s),
                            onAddToBucket: c.isSavedSuggestion(s)
                                ? null
                                : () async {
                                    final added = await c.addToBucket(s);
                                    _toast(
                                      added
                                          ? '${s.title} added to your Bucket List.'
                                          : 'That place is already saved.',
                                    );
                                  },
                            onFavorite: () => c.toggleFavorite(s.id),
                            onDetails: () => _showDetails(s),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6),
                        child: Text(
                          'Cards marked "Verified" are real, named places with a source link. '
                          'Cards marked "DateMate idea" are generated on-device from your preferences.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      PrimaryGradientButton(
                        label: "Can't Decide? Pick for Us",
                        icon: Icons.auto_awesome,
                        onPressed: c.currentSuggestions.isEmpty || c.generating
                            ? null
                            : _pickForUs,
                      ),
                      const SizedBox(height: 26),
                      const Divider(),
                      const SizedBox(height: 18),
                      PlaceBrowseSection(
                        key: ValueKey(_browseToken),
                        controller: widget.controller,
                        moodOverride: mood,
                        onOpen: _showDetails,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNavBar(currentIndex: 1, onTap: widget.onNavTap ?? (_) {}),
          ],
        ),
      ),
    );
  }
}

class _PlaceDetailsSheet extends StatelessWidget {
  final DateSuggestion suggestion;
  final AppController controller;
  final VoidCallback onSaved;

  const _PlaceDetailsSheet({
    required this.suggestion,
    required this.controller,
    required this.onSaved,
  });

  Future<void> _open(String value) async {
    if (value.isEmpty) return;
    await launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * .92,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    PlaceImage(
                      placeName: suggestion.title,
                      category: suggestion.category,
                      seedKey: suggestion.placeId,
                      assetPath: suggestion.imageUrl,
                      height: 205,
                      borderRadius: 0,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withValues(alpha: .82),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            suggestion.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _badge(Icons.payments_outlined, suggestion.price),
                  _badge(
                    Icons.schedule_outlined,
                    suggestion.openingHours.split(' · ').first,
                  ),
                  _badge(Icons.auto_awesome_rounded, 'DateMate match'),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                icon: Icons.location_on_rounded,
                title: 'Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 112,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.softGradient,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: _MapPatternPainter()),
                          ),
                          const Center(
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 42,
                              color: AppColors.gradientEnd,
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Location preview',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      suggestion.address,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: suggestion.googleMapsUrl.isEmpty
                            ? null
                            : () => _open(suggestion.googleMapsUrl),
                        icon: const Icon(Icons.map_outlined, size: 17),
                        label: const Text('Open this place in Google Maps'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                icon: Icons.info_outline_rounded,
                title: 'About this date',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.subtitle,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.payments_outlined,
                      'Planning cost',
                      suggestion.price,
                    ),
                    _infoRow(
                      Icons.schedule_outlined,
                      'Hours',
                      suggestion.openingHours,
                    ),
                    _infoRow(
                      Icons.verified_outlined,
                      'Why it matched',
                      suggestion.recommendationReason,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (suggestion.menuUrl.isNotEmpty ||
                  suggestion.officialWebsiteUrl.isNotEmpty)
                _sectionCard(
                  icon: Icons.link_rounded,
                  title: 'Useful links',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (suggestion.menuUrl.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _open(suggestion.menuUrl),
                          icon: const Icon(Icons.restaurant_menu, size: 16),
                          label: const Text('Menu'),
                        ),
                      if (suggestion.officialWebsiteUrl.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _open(suggestion.officialWebsiteUrl),
                          icon: const Icon(Icons.language, size: 16),
                          label: const Text('Official site'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              PrimaryGradientButton(
                label: 'Add to Bucket List',
                icon: Icons.favorite_rounded,
                onPressed: () async {
                  final added = await controller.addToBucket(suggestion);
                  if (context.mounted) Navigator.pop(context);
                  if (added) onSaved();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.blush,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.gradientEnd),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: AppColors.outline),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.gradientEnd),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        child,
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gradientEnd),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.rose.withValues(alpha: .28)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
