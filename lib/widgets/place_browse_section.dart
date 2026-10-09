import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import 'app_card.dart';
import 'place_grid_tile.dart';

class PlaceBrowseSection extends StatefulWidget {
  const PlaceBrowseSection({
    super.key,
    required this.controller,
    required this.moodOverride,
    required this.onOpen,
  });

  final AppController controller;
  final String moodOverride;
  final ValueChanged<DateSuggestion> onOpen;

  @override
  State<PlaceBrowseSection> createState() => PlaceBrowseSectionState();
}

class PlaceBrowseSectionState extends State<PlaceBrowseSection> {
  final List<DateSuggestion> _items = [];
  int _page = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadMore();
  }

  void loadMore() {
    if (_loading) return;
    setState(() => _loading = true);
    final next = widget.controller.browsePlaces(
      page: _page,
      moodOverride: widget.moodOverride,
      excludeIds: _items.map((e) => e.id).toSet(),
    );
    if (!mounted) return;
    setState(() {
      _items.addAll(next);
      _page++;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse places',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'An unlimited, scrollable catalog generated from your preferences — no place-search API needed.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AppBadge(
              label: '${_items.length} loaded',
              icon: Icons.grid_view_rounded,
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .72,
          ),
          itemBuilder: (_, i) {
            final s = _items[i];
            return PlaceGridTile(
              suggestion: s,
              isSaved: c.isSavedSuggestion(s),
              onTap: () => widget.onOpen(s),
              onSave: () async {
                final added = await c.addToBucket(s);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added
                          ? '${s.title} added to your Bucket List.'
                          : 'Already saved.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 14),
        Center(
          child: OutlinedButton.icon(
            onPressed: _loading ? null : loadMore,
            icon: _loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gradientEnd,
                    ),
                  )
                : const Icon(Icons.expand_more_rounded, size: 17),
            label: Text(_loading ? 'Loading...' : 'Load more places'),
          ),
        ),
      ],
    );
  }
}
