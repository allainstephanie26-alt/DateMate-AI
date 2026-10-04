import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_page_header.dart';
import '../widgets/primary_gradient_button.dart';
import '../widgets/selectable_chip.dart';
import '../data/catalog_data.dart';

class CouplePreferencesScreen extends StatefulWidget {
  const CouplePreferencesScreen({
    super.key,
    required this.controller,
    required this.onNavTap,
    required this.onSaved,
  });

  final AppController controller;
  final ValueChanged<int> onNavTap;
  final VoidCallback onSaved;

  @override
  State<CouplePreferencesScreen> createState() =>
      _CouplePreferencesScreenState();
}

class _CouplePreferencesScreenState extends State<CouplePreferencesScreen> {
  late Set<String> foods;
  // (reactive-listener fields declared after initState below)
  late Set<String> activities;
  late Set<String> locations;
  late String currency;
  bool _saved = false;

  final locationController = TextEditingController();
  final budgetController = TextEditingController();
  final codeController = TextEditingController();

  static const foodChoices = [
    'Korean BBQ',
    'Milk tea',
    'Pasta',
    'Ramen',
    'Vegetarian',
    'Silog',
    'Cafe',
    'Dessert',
    'Food',
    'Japanese',
    'Thai',
    'Pizza',
    'Steak',
    'Ice cream',
  ];

  static const activityChoices = [
    'Cafe hopping',
    'Movies',
    'Night market',
    'Museum',
    'Arcade',
    'Picnic',
    'Walk',
    'Culture',
    'Adventurous',
    'Beach',
    'Photography',
    'Live music',
    'Shopping',
    'Art',
  ];

  /// Automatically determines the budget currency from
  /// the location typed by the user.
  ///
  /// This does not require a currency dropdown.
  static String currencyForLocation(String value) {
    final text = value.toLowerCase();

    if (RegExp(r'\b(singapore|sg)\b').hasMatch(text)) {
      return 'SGD';
    }

    if (RegExp(r'\b(south korea|korea|seoul|kr)\b').hasMatch(text)) {
      return 'KRW';
    }

    if (RegExp(r'\b(japan|tokyo|osaka|jp)\b').hasMatch(text)) {
      return 'JPY';
    }

    if (RegExp(r'\b(thailand|bangkok|th)\b').hasMatch(text)) {
      return 'THB';
    }

    if (RegExp(
      r'\b(france|paris|germany|italy|rome|euro|eu)\b',
    ).hasMatch(text)) {
      return 'EUR';
    }

    if (RegExp(r'\b(united kingdom|uk|london|england)\b').hasMatch(text)) {
      return 'GBP';
    }

    if (RegExp(
      r'\b(united states|usa|new york|california|america)\b',
    ).hasMatch(text)) {
      return 'USD';
    }

    // Default for locations not recognized by the simple
    // local currency detector.
    return 'PHP';
  }

  @override
  void initState() {
    super.initState();

    final c = widget.controller.couple;

    foods = {...(c?.foods ?? <String>{})};
    activities = {...(c?.activities ?? <String>{})};
    locations = {...(c?.locations ?? <String>{})};

    locationController.text = c?.locations.isNotEmpty == true
        ? c!.locations.first
        : '';

    currency =
        c?.budgetCurrency ?? currencyForLocation(locationController.text);

    budgetController.text = c == null || c.budget <= 0
        ? ''
        : c.budget.round().toString();
    _saved = c != null && c.locations.isNotEmpty && c.budget > 0;

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    locationController.dispose();
    budgetController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void toggle(Set<String> group, String label) {
    setState(() {
      _saved = false;
      if (group.contains(label)) {
        group.remove(label);
      } else {
        group.add(label);
      }
    });
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> save() async {
    final location = locationController.text.trim();

    final detectedCurrency = currencyForLocation(location);

    final budget = double.tryParse(budgetController.text.trim()) ?? 0;

    if (location.isEmpty) {
      message('Add a preferred location so DateMate knows where to search.');
      return;
    }

    if (budget <= 0) {
      message('Enter your maximum budget per date.');
      return;
    }

    setState(() {
      currency = detectedCurrency;
      locations = {location};
      _saved = false;
    });

    await widget.controller.savePreferences(
      foods: foods,
      activities: activities,
      locations: locations,
      budget: budget,
      budgetCurrency: detectedCurrency,
    );

    if (!mounted) return;

    setState(() => _saved = true);

    message(
      widget.controller.cloud.enabled
          ? 'Preferences saved and synced.'
          : 'Preferences saved to this device.',
    );
  }

  Future<void> join() async {
    final ok = await widget.controller.joinCouple(codeController.text);

    if (!mounted) return;

    message(
      ok
          ? 'Partner linked successfully.'
          : (widget.controller.errorMessage ?? 'Could not link partner.'),
    );

    if (ok) {
      final c = widget.controller.couple;

      setState(() {
        foods = {...(c?.foods ?? <String>{})};
        activities = {...(c?.activities ?? <String>{})};
        locations = {...(c?.locations ?? <String>{})};

        locationController.text = c?.locations.isNotEmpty == true
            ? c!.locations.first
            : '';

        currency =
            c?.budgetCurrency ?? currencyForLocation(locationController.text);

        budgetController.text = c == null || c.budget <= 0
            ? ''
            : c.budget.round().toString();
        _saved = c != null && c.locations.isNotEmpty && c.budget > 0;
      });

      codeController.clear();
    }
  }

  Future<void> addCustom(String type, Set<String> target) async {
    final field = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(type == 'food' ? 'Add a food' : 'Add an activity'),
          content: TextField(
            controller: field,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Type your own choice'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, field.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    field.dispose();

    if (value != null && value.trim().isNotEmpty) {
      setState(() {
        target.add(value.trim());
        _saved = false;
      });
    }
  }

  Future<void> editName() async {
    final field = TextEditingController(
      text: widget.controller.currentUser?.name ?? '',
    );

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Your name'),
          content: TextField(
            controller: field,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, field.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    field.dispose();

    if (value != null && value.isNotEmpty) {
      await widget.controller.updateName(value);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final couple = c.couple;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                children: [
                  AppPageHeader(
                    title: 'Couple Preferences',
                    subtitle:
                        'Tell DateMate where you want to go and what you enjoy.',
                    onBack: widget.onSaved,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _headerAction(
                          Icons.sync_rounded,
                          c.cloud.enabled
                              ? () async {
                                  await c.refreshFromCloud();

                                  if (mounted) {
                                    message('Synced with the cloud.');
                                  }
                                }
                              : null,
                          'Sync',
                        ),
                        _headerAction(
                          Icons.edit_outlined,
                          editName,
                          'Edit name',
                        ),
                        _headerAction(Icons.logout_rounded, () async {
                          await c.logout();

                          if (mounted) {
                            widget.onSaved();
                          }
                        }, 'Log out'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _partnerCard(couple),

                  const SizedBox(height: 14),

                  if (couple?.memberIds.length != 2) ...[
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: codeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Partner code',
                                prefixIcon: Icon(Icons.link_rounded),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: join,
                            child: const Text('Link'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  _preferenceCard(
                    title: 'Food you love',
                    subtitle:
                        'Selected foods become required matching filters.',
                    icon: Icons.restaurant_menu_rounded,
                    selected: foods,
                    options: foodChoices,
                    onAdd: () => addCustom('food', foods),
                  ),

                  const SizedBox(height: 12),

                  _preferenceCard(
                    title: 'Activities you enjoy',
                    subtitle: 'Select what you actually want to do together.',
                    icon: Icons.local_activity_outlined,
                    selected: activities,
                    options: activityChoices,
                    onAdd: () => addCustom('activity', activities),
                  ),

                  const SizedBox(height: 12),

                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.gradientEnd,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Where do you want to go?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Type a city, or tap one below. DateMate matches it against its verified places and its unlimited local idea generator — no place-search API required.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 11),

                        TextField(
                          controller: locationController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            setState(() {
                              currency = currencyForLocation(value);
                              _saved = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'e.g. Clark City, Pampanga',
                          ),
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: CatalogData.cityNames.map((city) {
                            final selected =
                                locationController.text.trim().toLowerCase() ==
                                city.toLowerCase();
                            return SelectableChip(
                              label: city,
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  locationController.text = city;
                                  currency = currencyForLocation(city);
                                  _saved = false;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blush,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.currency_exchange_rounded,
                                size: 17,
                                color: AppColors.gradientEnd,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Budget currency: $currency',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 15,
                                color: AppColors.gradientEnd,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: budgetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {
                            if (_saved) setState(() => _saved = false);
                          },
                          decoration: InputDecoration(
                            prefixText: '$currency  ',
                            labelText: 'Maximum budget per date',
                            hintText: 'Enter your amount',
                            helperText:
                                'Budget stays user-entered; DateMate filters verified prices when available.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  PrimaryGradientButton(
                    label: _saved ? 'Saved' : 'Save preferences',
                    icon: _saved ? Icons.check_rounded : Icons.favorite_rounded,
                    onPressed: _saved ? null : save,
                  ),

                  const SizedBox(height: 9),

                  Center(
                    child: Text(
                      c.cloud.enabled
                          ? 'Your preferences sync through Supabase.'
                          : 'Your preferences are stored locally. Supabase sync is optional.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            AppBottomNavBar(currentIndex: 3, onTap: widget.onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _partnerCard(dynamic couple) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.glow,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your couple space',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Share the code with your partner to sync your date plan.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: Text(
                  couple?.code ?? '—',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: couple == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: couple.code));
                        message('Code copied.');
                      },
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Copy'),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            couple?.memberIds.length == 2
                ? couple!.names.join(' & ')
                : 'Waiting for your partner to join.',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _preferenceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Set<String> selected,
    required List<String> options,
    required VoidCallback onAdd,
  }) {
    final all = {...options, ...selected};

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.gradientEnd, size: 19),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Custom'),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: all
                .map(
                  (label) => SelectableChip(
                    label: label,
                    selected: selected.contains(label),
                    onTap: () => toggle(selected, label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback? onTap, String tooltip) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: .07),
        foregroundColor: AppColors.pinkText,
        disabledForegroundColor: AppColors.muted.withValues(alpha: .4),
        side: BorderSide(color: Colors.white.withValues(alpha: .13)),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}
