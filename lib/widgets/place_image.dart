import 'package:flutter/material.dart';

import '../services/place_image_service.dart';
import '../theme.dart';

class PlaceImage extends StatefulWidget {
  const PlaceImage({
    super.key,
    required this.placeName,
    this.source = '',
    this.height = 180,
    this.borderRadius = 18,
  });

  final String placeName;
  final String source;
  final double height;
  final double borderRadius;

  @override
  State<PlaceImage> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<PlaceImage> {
  String? _remoteUrl;
  bool _loading = false;

  bool get _isNetworkSource =>
      widget.source.startsWith('http://') ||
      widget.source.startsWith('https://');

  bool get _isAssetSource => widget.source.startsWith('assets/');

  @override
  void initState() {
    super.initState();
    _loadFallbackIfNeeded();
  }

  @override
  void didUpdateWidget(covariant PlaceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeName != widget.placeName ||
        oldWidget.source != widget.source) {
      _remoteUrl = null;
      _loadFallbackIfNeeded();
    }
  }

  Future<void> _loadFallbackIfNeeded() async {
    if (_isNetworkSource) return;
    setState(() => _loading = true);
    final url = await PlaceImageService.findImage(widget.placeName);
    if (!mounted) return;
    setState(() {
      _remoteUrl = url;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isNetworkSource) {
      child = Image.network(
        widget.source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (_isAssetSource) {
      child = Image.asset(
        widget.source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _remoteOrFallback(),
      );
    } else {
      child = _remoteOrFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: child,
      ),
    );
  }

  Widget _remoteOrFallback() {
    if (_remoteUrl != null) {
      return Image.network(
        _remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (_loading) {
      return Stack(
        children: [
          _fallback(),
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final name = widget.placeName.trim();
    final initial = name.isEmpty ? 'D' : name.substring(0, 1).toUpperCase();
    final lower = name.toLowerCase();
    final icon =
        lower.contains('ramen') ||
            lower.contains('restaurant') ||
            lower.contains('food')
        ? Icons.restaurant_rounded
        : lower.contains('cafe') || lower.contains('coffee')
        ? Icons.local_cafe_rounded
        : lower.contains('museum') || lower.contains('gallery')
        ? Icons.museum_rounded
        : lower.contains('park') || lower.contains('garden')
        ? Icons.park_rounded
        : Icons.place_rounded;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -26,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .10),
              ),
            ),
          ),
          Positioned(
            left: -28,
            bottom: -38,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .30),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'DateMate place preview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .78),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
