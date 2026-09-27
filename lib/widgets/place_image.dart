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
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_camera_back_outlined,
              color: Colors.white70,
              size: 36,
            ),
            const SizedBox(height: 6),
            Text(
              'Place photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
