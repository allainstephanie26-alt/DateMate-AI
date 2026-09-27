import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'place_image.dart';

class BucketListTile extends StatelessWidget {
  final BucketListItem item;
  final VoidCallback onToggle;
  final VoidCallback onReview;
  final VoidCallback onDelete;
  const BucketListTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onReview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = item.status == BucketListStatus.done;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9D8DE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.primary),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PlaceImage(
                  placeName: item.name,
                  source: item.imageUrl,
                  height: 118,
                  borderRadius: 0,
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
                      color: Colors.black.withValues(alpha: .48),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 34),
                        icon: Icon(
                          done ? Icons.check_circle : Icons.circle_outlined,
                          color: done ? AppColors.success : AppColors.outline,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.category} · ${item.price}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: done ? AppColors.success : AppColors.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          done ? 'Done' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: done
                                ? const Color(0xFF1C3A26)
                                : const Color(0xFF7A3B1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (done) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (item.rating != null)
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < item.rating!.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFD9A441),
                            ),
                          ),
                        if (item.note != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"${item.note}"',
                              style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        TextButton(
                          onPressed: onReview,
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
