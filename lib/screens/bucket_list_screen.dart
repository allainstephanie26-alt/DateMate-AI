import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/bucket_list_tile.dart';

class BucketListScreen extends StatefulWidget {
  final AppController controller;
  final ValueChanged<int> onNavTap;
  const BucketListScreen({
    super.key,
    required this.controller,
    required this.onNavTap,
  });
  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  String filter = 'All';

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _addItem() async {
    final name = TextEditingController();
    final category = TextEditingController(text: 'Other');
    final price = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a date idea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget / price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (save == true) {
      await widget.controller.addManualBucket(
        name.text,
        category.text,
        price.text,
      );
      _message('Added to your Bucket List.');
    }
    name.dispose();
    category.dispose();
    price.dispose();
  }

  Future<void> _review(BucketListItem item) async {
    double rating = item.rating ?? 5;
    final note = TextEditingController(text: item.note ?? '');
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text('Review ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setDialog(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFD9A441),
                      size: 30,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: note,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How was your date?',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save review'),
            ),
          ],
        ),
      ),
    );
    if (save == true) {
      await widget.controller.reviewBucket(item.id, rating, note.text);
      _message('Review saved.');
    }
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.controller.bucketItems;
    final visible = filter == 'Pending'
        ? all.where((i) => i.status == BucketListStatus.pending).toList()
        : filter == 'Completed'
        ? all.where((i) => i.status == BucketListStatus.done).toList()
        : all;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date Bucket List',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 21),
                            ),
                            Text(
                              '${all.length} saved · changes persist automatically',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _addItem,
                        tooltip: 'Add date',
                        icon: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.gradientEnd,
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: ['All', 'Pending', 'Completed']
                          .map(
                            (tab) => Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => filter = tab),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: filter == tab
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      color: filter == tab
                                          ? AppColors.gradientEnd
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Nothing here yet. Add or generate a date idea.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (_, i) {
                        final item = visible[i];
                        return BucketListTile(
                          item: item,
                          onToggle: () =>
                              widget.controller.toggleBucket(item.id),
                          onReview: () => _review(item),
                          onDelete: () async {
                            await widget.controller.deleteBucket(item.id);
                            _message('Removed from Bucket List.');
                          },
                        );
                      },
                    ),
            ),
            AppBottomNavBar(currentIndex: 2, onTap: widget.onNavTap),
          ],
        ),
      ),
    );
  }
}
