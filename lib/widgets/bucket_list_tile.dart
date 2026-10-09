import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'place_image.dart';

class BucketListTile extends StatelessWidget {
  final BucketListItem item;
  final VoidCallback onToggle;
  final VoidCallback onReview;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  const BucketListTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onReview,
    required this.onDelete,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final done = item.status == BucketListStatus.done;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: .20),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.pinkText,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen ?? onReview,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              border: Border.all(color: Colors.white.withValues(alpha: .09)),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: AppShadows.soft,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    PlaceImage(
                      placeName: item.name,
                      category: item.category,
                      seedKey: item.id,
                      assetPath: item.imageUrl,
                      aiIdea:
                          item.imageUrl.isEmpty &&
                          item.subtitle != 'Added manually',
                      height: 122,
                      borderRadius: 0,
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: .66),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onToggle,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  done
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: done
                                      ? AppColors.success
                                      : AppColors.pinkText.withValues(
                                          alpha: .6,
                                        ),
                                  size: 27,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
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
                                    fontSize: 14.5,
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
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: done
                                  ? AppColors.successBg
                                  : AppColors.blush,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              done ? 'Done' : 'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: done
                                    ? AppColors.success
                                    : AppColors.pinkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (done) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (item.rating != null)
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < item.rating!.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 16,
                                  color: AppColors.gold,
                                ),
                              ),
                            if (item.note != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '"${item.note}"',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.muted,
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
        ),
      ),
    );
  }
}
