import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme.dart';
import 'place_image.dart';

/// A compact card for the unlimited, scrollable place catalog. Every tile is
/// fully tappable (opens details) and carries its own quick-save button, so
/// the couple never has to open a place just to bucket-list it.
class PlaceGridTile extends StatefulWidget {
  const PlaceGridTile({
    super.key,
    required this.suggestion,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
  });

  final DateSuggestion suggestion;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  @override
  State<PlaceGridTile> createState() => _PlaceGridTileState();
}

class _PlaceGridTileState extends State<PlaceGridTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: Container(
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
                      placeName: suggestion.title,
                      category: suggestion.category,
                      seedKey: suggestion.placeId,
                      assetPath: suggestion.imageUrl,
                      aiIdea:
                          suggestion.imageUrl.isEmpty && !suggestion.verified,
                      height: 100,
                      borderRadius: 0,
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Material(
                        color: widget.isSaved
                            ? Colors.transparent
                            : AppColors.primaryDark.withValues(alpha: .62),
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: .35),
                          ),
                        ),
                        child: InkWell(
                          onTap: widget.onSave,
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: widget.isSaved
                                  ? AppColors.buttonGradient
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isSaved
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 15,
                              color: widget.isSaved
                                  ? Colors.white
                                  : AppColors.pinkText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (suggestion.verified)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        suggestion.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        suggestion.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pinkText,
                        ),
                      ),
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
