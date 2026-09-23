import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/primary_gradient_button.dart';
import '../widgets/selectable_chip.dart';

class CouplePreferencesScreen extends StatefulWidget {
  final AppController controller;
  final ValueChanged<int> onNavTap;
  final VoidCallback onSaved;

  const CouplePreferencesScreen({
    super.key,
    required this.controller,
    required this.onNavTap,
    required this.onSaved,
  });

  @override
  State<CouplePreferencesScreen> createState() =>
      _CouplePreferencesScreenState();
}

class _CouplePreferencesScreenState extends State<CouplePreferencesScreen> {
  late Set<String> foods;
  late Set<String> activities;
  late Set<String> locations;
  double budget = 0;
  final codeController = TextEditingController();

  static const foodChoices = [
    'Korean BBQ',
    'Milk tea',
    'Pasta',
    'Ramen',
    'Vegetarian',
    'Silog',
    'Cafe',
  ];
  static const activityChoices = [
    'Cafe hopping',
    'Movies',
    'Night market',
    'Museum',
    'Arcade',
    'Picnic',
    'Walk',
  ];
  static const locationChoices = [
    'Angeles City',
    'Clark',
    'Mabalacat',
    'San Fernando',
    'Nearby',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.controller.couple;
    foods = {...(c?.foods ?? <String>{})};
    activities = {...(c?.activities ?? <String>{})};
    locations = {...(c?.locations ?? <String>{})};
    budget = c?.budget ?? 0;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void toggle(Set<String> group, String label) => setState(
    () => group.contains(label) ? group.remove(label) : group.add(label),
  );

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> save() async {
    await widget.controller.savePreferences(
      foods: foods,
      activities: activities,
      locations: locations,
      budget: budget,
    );
    if (!mounted) return;
    message(
      widget.controller.cloud.enabled
          ? 'Preferences saved and synced.'
          : 'Preferences saved to your device.',
    );
    widget.onSaved();
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
        budget = c?.budget ?? 0;
      });
      codeController.clear();
    }
  }

  Future<void> addCustom(String type, Set<String> target) async {
    final field = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Add ${type == 'food'
              ? 'a food'
              : type == 'activity'
              ? 'an activity'
              : 'a location'}',
        ),
        content: TextField(
          controller: field,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Type your own choice'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, field.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    field.dispose();
    if (value != null && value.trim().isNotEmpty)
      setState(() => target.add(value.trim()));
  }

  Future<void> editName() async {
    final field = TextEditingController(
      text: widget.controller.currentUser?.name ?? '',
    );
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, field.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    field.dispose();
    if (value != null && value.isNotEmpty)
      await widget.controller.updateName(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final couple = c.couple;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                                'Couple Preferences',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontSize: 21),
                              ),
                              Text(
                                'Set what you both like',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: c.cloud.enabled
                              ? () async {
                                  await c.refreshFromCloud();
                                  if (mounted)
                                    message('Synced with the cloud.');
                                }
                              : null,
                          tooltip: 'Sync now',
                          icon: const Icon(
                            Icons.sync,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: editName,
                          tooltip: 'Edit name',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await c.logout();
                            if (mounted) {
                              setState(() {});
                              widget.onSaved();
                            }
                          },
                          tooltip: 'Log out',
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFFF6C9D0)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Partner link code',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  couple?.code ?? '—',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 26,
                                        letterSpacing: 2,
                                      ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: couple == null
                                    ? null
                                    : () {
                                        Clipboard.setData(
                                          ClipboardData(text: couple.code),
                                        );
                                        message('Code copied.');
                                      },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide.none,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            couple?.memberIds.length == 2
                                ? 'Partner linked. ${couple!.names.join(' & ')} share this couple space.'
                                : 'Share this code with your partner, then link their account below.',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (couple?.memberIds.length == 2) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              color: AppColors.gradientEnd,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                couple!.names.join(' & '),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.sync,
                              size: 17,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (couple?.memberIds.length != 2) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: codeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'Partner code',
                                  prefixIcon: Icon(Icons.link),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: join,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Link'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _groupLabel('Food we love', () => addCustom('food', foods)),
                    _chips(foods, foodChoices),
                    const SizedBox(height: 16),
                    _groupLabel(
                      'Activities we enjoy',
                      () => addCustom('activity', activities),
                    ),
                    _chips(activities, activityChoices),
                    const SizedBox(height: 16),
                    _groupLabel(
                      'Preferred locations',
                      () => addCustom('location', locations),
                    ),
                    _chips(locations, locationChoices),
                    const SizedBox(height: 16),
                    _label('Budget per date'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('₱0'),
                              Text(
                                budget <= 0 ? 'Not set' : '₱${budget.round()}',
                              ),
                            ],
                          ),
                          Slider(
                            value: budget.clamp(0.0, 3000.0).toDouble(),
                            min: 0,
                            max: 3000,
                            divisions: 12,
                            activeColor: AppColors.gradientEnd,
                            label: budget <= 0
                                ? 'Not set'
                                : '₱${budget.round()}',
                            onChanged: (value) =>
                                setState(() => budget = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryGradientButton(
                      label: 'Save our preferences',
                      icon: Icons.favorite,
                      onPressed: save,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        c.cloud.enabled
                            ? 'Changes sync for both partners.'
                            : 'Saved locally now; configure Firebase for live multi-device sync.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(currentIndex: 3, onTap: widget.onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _groupLabel(String text, VoidCallback onAdd) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            child: Row(
              children: [
                Icon(Icons.add, size: 15, color: AppColors.gradientEnd),
                SizedBox(width: 2),
                Text(
                  'Add custom',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gradientEnd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _chips(Set<String> selected, List<String> options) {
    final combined = {...options, ...selected};
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: combined
          .map(
            (label) => SelectableChip(
              label: label,
              selected: selected.contains(label),
              onTap: () => toggle(selected, label),
            ),
          )
          .toList(),
    );
  }
}
