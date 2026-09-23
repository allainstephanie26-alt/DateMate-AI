import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/date_suggestion_card.dart';
import '../widgets/primary_gradient_button.dart';
import '../widgets/selectable_chip.dart';

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

  @override
  void initState() {
    super.initState();
    mood = widget.controller.mood;
    if (widget.controller.currentSuggestions.isEmpty &&
        widget.controller.couple != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.controller.generateSuggestions(mood),
      );
    }
  }

  Future<void> _generate() async {
    await widget.controller.generateSuggestions(mood);
    if (mounted) _toast('Fresh ideas generated from your saved preferences.');
  }

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );

  Future<void> _pickForUs() async {
    final ideas = widget.controller.currentSuggestions;
    if (ideas.isEmpty) return;
    final pick = ideas[DateTime.now().microsecond % ideas.length];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tonight\'s pick',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              pick.title,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${pick.location} · ${pick.price}',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            PrimaryGradientButton(
              label: 'Add this to Bucket List',
              icon: Icons.add,
              onPressed: () async {
                final added = await widget.controller.addToBucket(pick);
                if (mounted) Navigator.pop(context);
                if (mounted)
                  _toast(
                    added
                        ? 'Added to your Bucket List.'
                        : 'That date is already saved.',
                  );
              },
            ),
          ],
        ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Date Recommendation',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontSize: 21),
                              ),
                              Text(
                                'Fresh ideas based on what you both saved',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.gradientEnd,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.outline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
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
                                ['Chill', 'Foodie', 'Adventurous', 'Cheap date']
                                    .map(
                                      (m) => SelectableChip(
                                        label: m,
                                        selected: mood == m,
                                        onTap: () async {
                                          setState(() => mood = m);
                                          await _generate();
                                        },
                                      ),
                                    )
                                    .toList(),
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
                                c.couple?.budget == null ||
                                        c.couple!.budget <= 0
                                    ? 'Budget not set'
                                    : '₱${c.couple!.budget.round()}',
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
                                      ? 'Choose locations'
                                      : c.couple!.locations.join(', '),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PrimaryGradientButton(
                            label: c.generating
                                ? 'Generating ideas...'
                                : 'Generate suggestions',
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
                              Text('Finding ideas that fit you both...'),
                            ],
                          ),
                        ),
                      )
                    else if (c.currentSuggestions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.gradientEnd,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Save your couple preferences first, then generate your first set of date ideas.',
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
                          onAddToBucket: () async {
                            final added = await c.addToBucket(s);
                            _toast(
                              added
                                  ? '${s.title} added to your Bucket List.'
                                  : 'That date is already saved.',
                            );
                          },
                          onFavorite: () => c.toggleFavorite(s.id),
                        ),
                      ),
                    const SizedBox(height: 2),
                    PrimaryGradientButton(
                      label: "Can't decide? Pick for us",
                      icon: Icons.shuffle,
                      onPressed: c.currentSuggestions.isEmpty || c.generating
                          ? null
                          : _pickForUs,
                    ),
                  ],
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
